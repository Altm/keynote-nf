(* ************************************************************
 MOZILLA PUBLIC LICENSE STATEMENT
 -----------------------------------------------------------
 The contents of this file are subject to the Mozilla Public
 License Version 1.1 (the "License"); you may not use this file
 except in compliance with the License. You may obtain a copy of
 the License at http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS
 IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 implied. See the License for the specific language governing
 rights and limitations under the License.

 The Original Code is "gf_strings.pas".

 The Initial Developer of the Original Code is Marek Jedlinski
 <eristic@lodz.pdi.net> (Poland).
 Portions created by Marek Jedlinski are
 Copyright (C) 2000, 2001. All Rights Reserved.
 -----------------------------------------------------------
 Contributor(s):
 -----------------------------------------------------------
 History:
 -----------------------------------------------------------
 To do:
 -----------------------------------------------------------
 Released: 20 August 2001
 -----------------------------------------------------------
 URLs:

 - original author's software site:
 http://www.lodz.pdi.net/~eristic/free/index.html
 http://go.to/generalfrenetics

 Email addresses (at least one should be valid)
 <eristic@lodz.pdi.net>
 <cicho@polbox.com>
 <cicho@tenbit.pl>

************************************************************ *)

unit gf_strings;

interface
uses SysUtils, Windows, Classes;

procedure DelimTextToStrs(
  AStrs: TStrings;
  const Value: string;
  const AchDelim : Char );

function StrToCSVText( const aStr : string; const aDelim : char; const QuoteAll : boolean ) : string;
procedure CSVTextToStrs(
  aList : TStrings;
  const aStr : string;
  const aDelim : char );

procedure SplitString( aList : TStrings; aStr : string; const aDelim : char );

function CountChars( const ch : char; const s : string ) : integer;
procedure CharToChar( var s : string; const oldchar, newchar : char );
function RemoveAccelChar( const s : string ) : string;
procedure CollapseSpaces( var s : string );
function TrimPunct( s : string ) : string;

function TailMatch( const LongerString, ShorterString : string ) : boolean;
procedure UnquoteString( var s : string );
function StringsToString( const AStrs : TStrings; const aDelim : char; const WrapWithDelim : boolean ) : string;

function MatchMask(source, pattern: String): Boolean;
procedure StripControlChars( var s : string );
function GetWordChars : string;

function ExpandMetaChars( line : string ) : string;

implementation
uses gf_misc;

function ExpandMetaChars( line : string ) : string;
var
  i, linelen : integer;
  wasmeta : boolean;
  ch : char;
begin
  result := '';

  if ( line = '' ) then exit;
  linelen := length( line );
  wasmeta := false;

  if ( linelen > 1 ) then
  begin
    if (( line[1] = '"' ) and ( line[linelen] = '"' )) then
    begin
      delete( line, linelen, 1 );
      delete( line, 1, 1 );
      dec( linelen, 2 );
    end;
  end;

  for i := 1 to linelen do
  begin
    ch := line[i];
    case ch of
      '\' : begin               
        if wasmeta then
        begin
          result := result + ch;
          wasmeta := false;
        end
        else
          wasmeta := true;
      end;
      'n' : begin
        if wasmeta then
          result := result + #13
        else
          result := result + ch;
        wasmeta := false;
      end;
      't' : begin
        if wasmeta then
          result := result + #9
        else
          result := result + ch;
        wasmeta := false;
      end;
      else
      begin
        wasmeta := false;
        result := result + ch;
      end;
    end;
  end;
end; // ExpandMetaChars

procedure StripControlChars( var s : string );
var
  i, l : integer;
begin
  l := length( s );
  for i := l downto 1 do
  begin
    if ( s[i] < #32 ) then
      delete( s, i, 1 );
  end;
end; // StripControlChars

function TailMatch( const LongerString, ShorterString : string ) : boolean;
var
  llonger, lshorter : integer;
begin
  llonger := length( LongerString );
  lshorter := length( shorterstring );

  if ( lshorter > llonger ) then
  begin
    result := false;
    exit;
  end;

  {
  'abcdxxx' 7
  '    xxx' 3, pos 5
  }

  result := ( copy( LongerString, succ( llonger - lshorter ), lshorter ) = ShorterString );
end; // TailMatch

function TrimPunct( s : string ) : string;
var
  slen : integer;
begin
  while ( s <> '' ) do
  begin
    if IsCharAlphaNumericA( s[1] ) then
      break
    else
      delete( s, 1, 1 );
  end;
  slen := length( s );
  while ( slen > 0 ) do
  begin
    if IsCharAlphaNumericA( s[slen] ) then
      break
    else
    begin
      delete( s, slen, 1 );
      dec( slen );
    end;
  end;
  result := s;
end; // TrimPunct


function StrToCSVText(
  const aStr : string;
  const aDelim : char;
  const QuoteAll : boolean ) : string;
// aDelim MUST NOT be double quote '"'
var
  qp : integer;
  MustQuote : boolean;
begin
  if ( aStr = '' ) then
  begin
    if QuoteAll then
      result := '""';
    exit;
  end;

  MustQuote := ( pos( aDelim, aStr ) > 0 );
  result := aStr;

  if ( pos( '"', result ) > 0 ) then
  begin
    MustQuote := true;
    qp := 1;
    repeat
      if ( result[qp] <> '"' ) then
      begin
        inc( qp );
      end
      else
      begin
        insert( '"', result, qp );
        inc( qp, 2 );
      end;
    until ( qp > length( result ));
  end;

  if ( MustQuote or QuoteAll ) then
    result := '"' + result + '"';

end; // StrToCSVText


procedure CSVTextToStrs(
  aList : TStrings;
  const aStr : string;
  const aDelim : char );
// DelimTextToStrs relies on all strings being wrapped in quotes,
// but this is not a requirement for delimited fields in a CSV file.
// (Otherwise, DelimTextToStrs breaks on every space, in addition to
// breaking on delimiter characters)
// This routine does what DelimTextToStrs does but ONLY breaks on
// the delimiter char. Only those strings must be quoted which contain
// quotes or contain the delimiter character.
var
  s : string;
  InQuotes : boolean;
  p, l : integer;
  ch, prevch : char;
begin

  if ( aStr = '' ) then exit;
  s := '';
  p := 0;
  prevch := #0;
  l := length( aStr );
  InQuotes := false;

  aList.BeginUpdate; // so that we can feed e.g. ListBox.Items to this routine
  try
    while ( p < l ) do
    begin
      inc( p );
      ch := aStr[p];
      if ( ch = aDelim ) then
      begin
        if ( InQuotes and ( prevch <> '"' )) then
        begin
          s := s + ch;
        end
        else
        begin
          aList.Add( s );
          s := '';
          InQuotes := false;
          // prevch := #0;
        end;
      end
      else
      if ( ch = '"' ) then
      begin
        if ( prevch = '"' ) then
        begin
          // dooubled quotes are "escaped",
          // i.e. they're real quote characters
          // rather than group words
          s := s + '"';
          ch := #0;
        end
        else
        begin
          if ( InQuotes or ( s <> '' )) then
          begin
            if InQuotes then
            begin
              // nothing; we will see what to do
              // when we get the next char
              if ( p = l ) then
                Ch := aDelim; // otherwise we'll lose the last field if it is a blank string
            end
            else
            begin
              // IMPOSSIBLE: the string was not
              // quoted, so it can't contain
              // embedded quote characters
              raise EConvertError.Create( 'Unmatched double quote in string at pos ' + inttostr( p ));
            end;
          end
          else
          begin
            InQuotes := true;
            ch := #0;
          end;
        end;
      end
      else
      begin
        s := s + ch;
      end;
      prevch := ch;
    end;
    if (( s <> '' ) or ( prevch = aDelim )) then
      aList.Add( s );
  finally
    aList.EndUpdate;
  end;

end; // CSVTextToStrs

procedure SplitString( aList : TStrings; aStr : string; const aDelim : char );
var
  p : integer;
  s : string;
begin
// the simplest split routine of all:
// just splits at delimiter, does not care about anything else.
// DO NOT USE FOR PROPERLY FORMATTED CSV DATA!

  p := pos( aDelim, aStr );
  while ( p > 0 ) do
  begin
    s := copy( aStr, 1, pred( p ));
    delete( aStr, 1, p );
    if ( s <> '' ) then
      aList.Add( s );
    p := pos( aDelim, aStr );
  end;
  if ( aStr <> '' ) then
    aList.Add( aStr );
end; // SplitString

procedure DelimTextToStrs( AStrs: TStrings;
         const Value: string ;
         const AchDelim : Char );
var
  P, P1   : PChar;
  S   : string;
  chDelim   : char ;
begin
  chDelim := AchDelim ;
  AStrs.BeginUpdate;
  try
  // AStrs.Clear;
  P := PChar(Value);

  while P^ in [#1..' '] do
    P := CharNext(P);

  while P^ <> #0 do
   begin
     if ( P^ = '"' ) then
     S := AnsiExtractQuotedStr(P, '"')
     else
     begin
      P1 := P;
      while (P^ > ' ') and ( P^ <> chDelim ) do
      P := CharNext(P);

      SetString(S, P1, P - P1);
     end;

     AStrs.Add(S);

     while P^ in [#1..' '] do
     P := CharNext(P);

     if P^ = chDelim then // P^ = ',' then
    repeat
     P := CharNext(P);
    until not (P^ in [#1..' ']);

   end;  // while

  finally
    AStrs.EndUpdate;
  end;
end; // DelimTextToStrs

function CountChars( const ch : char; const s : string ) : integer;
var
  i : integer;
begin
  result := 0;
  for i := 1 to length( s ) do
    if s[i] = ch then inc( result );
end; // CountChars

procedure CharToChar( var s : string; const oldchar, newchar : char );
var
  p : integer;
begin
  if ( oldchar = newchar ) then exit;
  p := pos( oldchar, s );
  while ( p > 0 ) do
  begin
    s[p] := newchar;
    p := pos( oldchar, s );
  end;
end; // CharToChar

function RemoveAccelChar( const s : string ) : string;
var
  p : integer;
begin
  result := s;
  p := pos( '&', result );
  if ( p > 0 ) then
    delete( result, p, 1 );
end; // RemoveAccelChar

procedure CollapseSpaces( var s : string );
const
  SPCARRAY : array[1..2] of string = ( #32#32, #9#9 );
var
  i, p : integer;
begin
  for i := 1 to 2 do
  begin
    p := pos( SPCARRAY[i], s );
    while ( p > 0 ) do
    begin
      delete( s, p, 1 );
      p := pos( SPCARRAY[i], s );
    end;
  end;

end; // CollapseSpaces

procedure UnquoteString( var s : string );
var
  l : integer;
begin
  l := length( s );
  if ( l > 2 ) then
  begin
    if (( s[1] = '"' ) and ( s[l] = '"' )) then
    begin
      delete( s, l, 1 );
      delete( s, 1, 1 );
    end;
  end;
end; // UnquoteString

function StringsToString(
  const AStrs : TStrings;
  const aDelim : char;
  const WrapWithDelim : boolean ) : string;
var
  i : integer;
  s : string;
begin
  result := '';
  for i := 1 to AStrs.Count do
  begin
    s := AStrs[pred( i )];
    if ( s <> '' ) then
    begin
      if ( i = 1 ) then
        result := s
      else
        result := result + aDelim + s;
    end;
  end;

  if (( result <> '' ) and WrapWithDelim ) then
    result := Format( '%s%s%s', [aDelim, result, aDelim] );

end; // StringsToString


function MatchMask(source, pattern: String): Boolean;
{
  From: stidolph@magnet.com (David Stidolph)
  Subject: [delphi] String Pattern matching
  Date: Tue, 27 Jun 1995 10:01:18 -0400

  There are many times when you need to compare two strings, but want to use
  wild cards in the match - all last names that begin with 'St', etc.  The
  following is a piece of code I got from Sean Stanley in Tallahassee Florida
  in C.  I translated it into Delphi an am uploading it here for all to use.
  I have not tested it extensivly, but the original function has been tested
  quite thoughly.

  I would love feedback on this routine - or peoples changes to it.  I want to
  forward them to Sean to get him to release more tidbits like this.

  This function takes two strings and compares them.  The first string
  can be anything, but should not contain pattern characters (* or ?).
  The pattern string can have as many of these pattern characters as you want.
  For example: MatchStrings('David Stidolph','*St*') would return True.

  Orignal code by Sean Stanley in C
  Rewritten in Delphi by David Stidolph
}
var
  pSource: Array [0..255] of Char;
  pPattern: Array [0..255] of Char;

  function MatchPattern(element, pattern: PChar): Boolean;

    function IsPatternWild(pattern: PChar): Boolean;
    begin
      Result := StrScan(pattern,'*') <> nil;
      if not Result then Result := StrScan(pattern,'?') <> nil;
    end;

  begin
    if 0 = StrComp(pattern,'*') then
      Result := True
    else if (element^ = Chr(0)) and (pattern^ <> Chr(0)) then
      Result := False
    else if element^ = Chr(0) then
      Result := True
    else begin
      case pattern^ of
      '*': if MatchPattern(element,@pattern[1]) then
             Result := True
           else
             Result := MatchPattern(@element[1],pattern);
      '?': Result := MatchPattern(@element[1],@pattern[1]);
      else
        if element^ = pattern^ then
          Result := MatchPattern(@element[1],@pattern[1])
        else
          Result := False;
      end;
    end;
  end;

begin
  StrPCopy(pSource,source);
  StrPCopy(pPattern,pattern);
  Result := MatchPattern(pSource,pPattern);
end; // MatchMask

function GetWordChars : string;
var
  i : integer;
  ch : char;
begin
  result := '';
  for i := 33 to 255 do
  begin
    ch := chr( i );
    if IsCharAlphaA( ch ) then
      result := result + ch;
  end;
end; // GetWordChars


end.
