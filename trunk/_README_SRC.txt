==============================================
KeyNote NF: SOURCE CODE README
==============================================

KeyNote NF source code is hosted by Google Code, to get the code see here: 
 http://code.google.com/p/keynote-nf/source/checkout 

I have the following structure at home:
 KeyNote_NF
   Complementos  (with 3rd_party_distributable, kn_scratchpad, kntconvert)
   Output
      Bin
      Dcu
   src
   zip  	 (with binary realeases, zip versions of kntconvert, etc)

Project is configured so that 'Output' is at the same level that 'src'.
Only "src" is under version control and it hangs from Trunk.


IMPORTANT. USE OF SUBVERSION:
=========
In the case of commiting to subversion, clients must be configured 
to ignore certain files and folders. I use Tortoise, and in the 
"Global Ignore Pattern" I have set the following value:

*.identcache *.~* *.dcu *.dsk *.dll *.exe *.bdsproj.local  */ModelSupport_keynote 
 ModelSupport_keynote */__history __history



============================================================
Updated: 13 Nov 2007
Version: 1.7.0
Developer: Daniel Prado Velasco  (dprado.keynote@gmail.com)
============================================================

A partir del c�digo fuente facilitado por Marek Jedlinski,
correspondiente a la versi�n 1.6.5 he realizado las correcciones
necesarias para poder compilarlo con Delphi 2006.
Entre otras cosas me ha sido necesario localizar por Internet 
algunas de las units de terceros que no estaban incluidos en
el c�digo fuente.
Este c�digo se sigue distribuyendo bajo las condiciones de la
Mozilla Public License (MPL), aplic�ndose a las units escritas
por Marek Jedlinski, as� como aquellas modificados o escritas por
m� (Daniel Prado). El c�digo de terceros est� regulado por sus propias
licencias.


Los proyectos "Keynote.bdsproj" y "kntutils.bdsproj" utilizan
exclusivamente los archivos situados en la carpeta �keynote_source�
as� como una gran parte de los situados en �keynote_source\3rd_party�.
Los archivos originalmente en 'modified_3rdparty_units', 'misc_files'
y 'support_units' se han mantenido en �Other�. Algunos ya estaban 
tambi�n en la carpeta keynote_source; otros se han tenido en cuenta
a la hora de actualizar algunas units en '3rd_party'.

Tanto en este proyecto como en �kntutil.bdsproj� est�n explicitadas
las carpetas de b�squeda de las units (no se ha definido como
configuraci�n del IDE)

Aparte de las correcciones necesarias para la compilaci�n en Delphi 2006
y al margen de los cambios realizados para a�adir nuevas funcionalidades
o corregir algunos errores, he hecho la siguiente modificaci�n con
vistas a facilitar la comprensi�n del c�digo (as� como a agilizar el
mantenimiento del modelo que permite crear la versi�n Architect de Delphi):
He fragmentado el archivo kn_main.pas en varios archivos, en base a un
criterio de funcionalidad (posiblemente haga algunos cambios m�s):
kn_Global.pas, kn_BookmarksMng.pas, kn_ConfigFileMng.pas, kn_NoteMng.pas, ...
(kn_...Mng.pas)


Units y componentes de terceros
------------------------------
En la carpeta '3rd_party' se han descomprimido los archivos de la carpeta
3rd_party_distributable, reemplazando aquellos ficheros incluidos en 
modified_3rdparty_units (modificados por marek)

Se han hecho peque�as modificaciones a algunos ficheros para poder ser
compilados en Delphi 2006. Se ha aprovechado uno de los fichero DFS.INC,
ligeramente modificado para contemplar nuevas versiones de Delphi; para
ello se ha copiado a las carpetas de otros componentes y se ha a�adido
la l�nea {$I DFS.INC} a los ficheros .pas necesarios.

Las modificaciones se han marcado con el comentario: // [dpv]

Antes de abrir los proyectos Keynote es preciso instalar los componentes
de terceros en los que se apoya:

*La mayor�a de los componentes se ha incluido dentro de un paquete denominado 
'_PaqueteTerceros'

*RX Library 2.75 port to Delphi 2006 (Win32), v1.0 (by Oleg Fedorov)
   --> 'rx275d2006. Seguir las indicaciones del fichero readme.txt para su 
       instalaci�n
*DCPcrypt v1.3      David Barton (davebarton@bigfoot.com)
   --> 'dcpcrypt-1_3'  (Se ha instalado el paquete DCP_d4.bdsproj)

El siguiente paquete se ha instalado, aunque de momento no se ha utilizado:
- EmbeddedWB_D2005  


Dentro de la carpeta �3rd_party_distributable� se ha incluido
el c�digo fuente original de los distintos componentes y units
de terceros utilizados en KeyNote. Est�n todos los utilizados.



. . . . . . . . . . . . . . . . . . . . . . . . . .. . . . . . . . . . . . .. . . . . . .



===========================================================
KEYNOTE: SOURCE CODE README
Released: 30 June 2001
Updated: 12 Nov 2003
Version: 1.6
-----------------------------------------------------------

This is the full (or as full as possible) source code
for the KeyNote program. It is distributed under the
conditions of Mozilla Public License (MPL). See file
MPL.TXT for details. The license, of course, applies
only to units written by the author, Marek Jedlinski.
Third-party units may be regulated by their own
licenses.

-----------------------------------------------------------

DISCLAIMERS and such.

KeyNote is a work in progress. The source does contain
"dead" code and paths that lead nowhere. There are not
many, but they are there.

I am not a professional programmer. I larn things as I go.
In the process, I have re-invented the wheel many times
over, and occasionally the wheel is somewhat, well, angular.
Imperfections abound.

-----------------------------------------------------------

IF YOU NEED ASSISTANCE in compliing KeyNote, contact me.
See URls and addresses at the end of this file.


-----------------------------------------------------------

KeyNote would never have come to existence if not for
many great libraries written by other Delphi programmers.
KeyNote makes a MASSIVE use of third-party units and
components. The file "compile.txt" has a complete list
of third-party libraries required to compile KeyNote.

Important notes about third-party code:

1. In developing KeyNote, I have ONLY used third-party
units and components which are "freeware" and distributed
with full source code. All these libraries can be downloaded
for free (see Torry's Delphi Pages, the Delphi Super Page,
and Delphi Free Stuff).

2. While the third-party libraries are "free" in the common
usage of the word, they are not necessarily licensed as
"free software" or "open source software". Sometimes their
licenses may be even more open (even public domain), and
at other times, the licensing conditions may be more restrictive.
I have yet to investigate which of these third-party libraries
I can legitimately distribute with KeyNote; but you can just
download them all yourself.

3. In a few (very few) cases, I have found it necessary to
modify third-party source code. This, unfortunately, makes
it even harder to distribute those libraries. I will try to
resolve the issue as soon as possible.

-----------------------------------------------------------

CODING PRACTICES

Fair warnings. I am utterly convinced that all variables
should be initialized. (This generates tons of "value not
used" compiler hints.) I lay out code with plenty of space.
I prefer clarity over compactness. My eyesight isn't the
best in the world, and I find constructs such as
	foo:=(vara-varb)*CalcSomething(varc);
unreadable. In my source, they'll always be written	as
	foo := (( varA - varB ) * CalcSomething( varC ));
I do not write
	if not Verified then exit;
Instead, I write
	if ( not Verified ) then
		exit;
I find this much more readable, easier to follow, and
I can have a breakpoint on the 'exit;' line.


-----------------------------------------------------------

SPECIAL REQUEST

If you are interested in compiling or modifying KeyNote
source code, I would very much appreciate if you started
by taking a look at the "bugs.txt" file (installed with
KeyNote) and see if you have any ideas on how some of
the problems described there can be fixed. I have no clue
as to how these issues should be handled. Thank you.

-----------------------------------------------------------

 URLs:

 - for OpenSource development:
 http://keynote.sourceforge.net
THIS SITE IS UNUSED. It could provide a priceless resource
for the development of KeyNote, but I don't have enough time
to work on it. I'll appreciate any help with this.

 - original author's software site:
 http://www.tranglos.com

 Email addresses (at least one should be valid)
 <marekjed@pobox.com>
 <marekjed@users.sourceforge.net>
 <cicho@polbox.com>
-----------------------------------------------------------

