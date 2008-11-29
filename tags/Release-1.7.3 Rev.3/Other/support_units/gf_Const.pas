unit gf_const;
{$I gf_base.inc}

(* -----------------------------------------------------------------
gf_inc.pas, support unit for all General Frenetics software
updated: 23 October 1999

Copyright (c) 1999 General Frenetics, Discorp. All rights reserved.

Author:     marek jedlinski; General Frenetics, Discorp.
E-mail:     <marekjed@users.sourceforge.net>
Web URL:    http://keynote.prv.pl

------------------------------------------------------------------ *)

interface
uses Graphics;

const
  // VANITY INFO FOR ALL SOFTWARE
  Program_URL     = 'http://keynote.prv.pl';
  Program_Email   = 'marekjed@users.sourceforge.net';
  Program_License = 'This program is Freeware';
  Program_Credit  = 'Copyright (c) Marek Jedlinski, 2000-2002';


const
   // APP NOTIFY IDs FOR ALL SOFTWARE
   AppNotifyValue_KOOKIE59    = 0555;
   AppNotifyValue_KOOKIE60    = 1555;
   AppNotifyValue_VISITURL10  = 2555;
   AppNotifyValue_VISITURL20  = 3555;
   AppNotifyValue_PHONEDECK10 = 4555;
   AppNotifyValue_INJECTURL20 = 5555;
   AppNotifyValue_OUBLIETTE10 = 6555;
   AppNotifyValue_KEYNOTE10   = 7555;

const
   // UNIQUE APP NAMES FOR ALL SOFTWARE
   UniqueAppName_KOOKIE59    = 'GFKookieJar59';
   UniqueAppName_VISITURL10  = 'GFVisitURL10';
   UniqueAppName_VISITURL20  = 'GFVisitURL20';
   UniqueAppName_PHONEDECK10 = 'GFPhoneDeck10';
   UniqueAppName_DCKPORT     = 'GFDCKPort10';
   UniqueAppName_INJECTURL20 = 'GFInjectURL10';
   UniqueAppName_OUBLIETTE10 = 'GFOubliette10';
   UniqueAppName_KEYNOTE10   = 'GFKeyNote10';
   UniqueAppName_KNTVIEW10   = 'GFKNTView10';
   UniqueAppName_KOOKIEJAR60 = 'GFKookieJar60';

const
  FILTER_ALLFILES    = 'All files (*.*)|*.*';
  FILTER_EXECUTABLES = 'Programs|*.exe;*.com';

const
  _GF_CLWINDOW = $D0D0D0;
  _GF_NAVY     = clNavy;
  _GF_PURPLE   = clPurple;
  _GF_BLUE     = clBlue;
  _GF_BLACK    = clBlack;


implementation

end.
