
---

Versión: 1.7.8 -  fecha: 02/nov/2009

Mejoras:
  * [Issue #175](https://code.google.com/p/keynote-nf/issues/detail?id=#175): Nuevo formato de archivo KeyNote: comprimido
  * [Issue #72](https://code.google.com/p/keynote-nf/issues/detail?id=#72): Posibilidad de añadir texto a una alarma, y otros cambios menores

Errores corregidos:
  * [Issue #162](https://code.google.com/p/keynote-nf/issues/detail?id=#162): Los cambios al último nodo no son salvados en notas encriptadas de tipo árbol si el foco no es desplazado a otro nodo
  * [Issue #163](https://code.google.com/p/keynote-nf/issues/detail?id=#163): 'Pegar como Web Clip' no está mostrando la URL origen
  * [Issue #166](https://code.google.com/p/keynote-nf/issues/detail?id=#166): La entrada de datos en teclado internacional no está funcionando al renombrar nodos del árbol (en línea)
  * [Issue #169](https://code.google.com/p/keynote-nf/issues/detail?id=#169): Buscar siguiente manteniendo pulsada la tecla INTRO podría llegar a modificar el contenido del archivo
  * [Issue #178](https://code.google.com/p/keynote-nf/issues/detail?id=#178): El programa puede tardar al guardar y salir, congelando la pantalla
  * [Issue #189](https://code.google.com/p/keynote-nf/issues/detail?id=#189): Los cambios sobre un nodo se pierden si se crea una nueva antes de seleccionar otro nodo o nota


---

Versión: 1.7.7 -  fecha: 18/oct/2009

Mejoras:

  * [Issue #139](https://code.google.com/p/keynote-nf/issues/detail?id=#139): Hacer KeyNote NF compatible con Unicode <br> Con anterioridad, dentro de esta misma versión, aunque con el mismo objetivo:<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#40'>Issue #40</a>: Las operaciones Buscar y Reemplazar no funcionan con caracteres Unicode (chino, por ejemplo)<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#54'>Issue #54</a>: 'Pegar como texto' y 'Pegar como Web Clip' no funcionan con caracteres Unicode<br>
</li></ul><ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#73'>Issue #73</a>: Permitir habilitar o desabilitar las ventanas modales de alarmas<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#29'>Issue #29</a>: Sonido opcional en Alarmas<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#135'>Issue #135</a>: Insertar URL: Eliminar auto pegado desde el portapapeles<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#158'>Issue #158</a>: Incluir soporte para el protocolo URL Notes<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#118'>Issue #118</a>: KeyNote debería soportar rutas relativas en el archivo de configuración y en la línea de comandos</li></ul>

<ul><li>Incluída una traducción parcial al francés por Picou (picou.keynote@gmail.com)<br>
</li><li>Incluída una traducción parcial al chino simplificado por xbeta (<a href='http://xbeta.info'>http://xbeta.info</a>) <br> En ambos casos no se incluye la traducción del archivo de consejos (.tip)</li></ul>

Errores corregidos:<br>
<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#155'>Issue #155</a>: Error en Captura de Portapapeles en nota no activa (no visible)<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#141'>Issue #141</a>: Captura de Portapapeles repite dos veces el texto copiado, cuando se copia desde ciertos programas<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#62'>Issue #62</a>: KeyNote NF no abre correctamente en modo maximizado<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#58'>Issue #58</a>: El botón Minimizar no funciona correctamente en ocasiones<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#153'>Issue #153</a>: Dificultad de visualización en ventana de edición de hiperenlace<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#63'>Issue #63</a>: No funcionan los hiperenlaces con caracteres Unicode<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#115'>Issue #115</a>: Problema al hacer clic con el botón derecho sobre una URL<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#149'>Issue #149</a>: Añadir nodo hermano no siempre añade un nodo hermano<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#127'>Issue #127</a>: La macro StyleApply no aplica el estilo especificado. Las teclas modificadoras no funcionan en macros, tampoco<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#125'>Issue #125</a>: El cursor salta al último hiperenlace de la nota cada vez que ésta es salvada<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#122'>Issue #122</a>: No funcionan los enlaces Keynote hacia otros archivos<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#116'>Issue #116</a>: Los cambios en un nodo espejo se pierden tras salvar si el nodo original está seleccionado (en otra nota)<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#101'>Issue #101</a>: No funciona la importación archivos arrastrando hacia el árbol<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#96'>Issue #96</a>: Search -> Find... sólo funciona en una nota, no busca en todas las notas<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#74'>Issue #74</a>: El árbol de la pantalla de opciones es editable<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#71'>Issue #71</a>: Un nodo puede perder su marca de verificación al moverlo, en una situación especial<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#70'>Issue #70</a>: La barra de estado no refleja correctamente el estado modificación del archivo <br> <br> Mientras estuvo la Beta 2 disponible se corrigieron las siguientes incidencias identificadas:<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#152'>Issue #152</a>: "Permitir una única instancia" no funciona en 1.7.7 Beta2<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#150'>Issue #150</a>: La exportación desde un nodo tipo árbol no incluye los encabezados<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#140'>Issue #140</a>: Las notas no aparecen en 1.7.7 Beta 2 para los archivos encriptados</li></ul>

<hr />
Versión: 1.7.6 -  fecha: 27/abr/2009<br>
<br>
<ul><li>Incorporada una traducción al alemán por Klaus Utech  (<a href='http://www.klausutech.com'>http://www.klausutech.com</a>).<br>
<blockquote>Basta con descargar el archivo 'German_Translation_Release_1.7.6.1.rar' y copiar los archivos 'keynote.german.lng' y 'keynote.german.tip' a la carpeta 'Lang', y reemplazar 'keynote.lan' con el incluido en el archivo zip. <br>  Nota: La pantalla con las opciones de configuración no está aún traducida. Igualmente, el archivo .tip (Sugerencia del día) tampoco está traducido, es simplemente una copia de la versión inglesa.</blockquote></li></ul>

<hr />
Versión: 1.7.6 -  fecha: 15/mar/2009<br>
<br>
Mejoras:<br>
<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#57'>Issue #57</a>: Nuevo tipo de nodos virtuales: enlaces a otros nodos (nodos 'espejo')<br>
<ul><li>Puede crear nodos 'espejo' del tal manera que compartan el mismo contenido, alarma y estado (checked). De esa manera puede organizar su información simultáneamente según diferentes criterios.<br>
</li><li>Con nodos 'espejo' puede tener tareas repartidas en varias notas y al mismo tiempo incluidas en otra común. Podrá tener una visión global de la principales cosas por hacer, priorizarlas y clasificarlas en un jerarquía independiente de aquella en la que los nodos 'reales' residen.<br>
</li></ul></li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#48'>Issue #48</a>: Ctr+Shift+TAB, antes de seleccionar la nota previa, pasar el foco al árbol<br>
</li><li>Incluida una traducción al holandés por Ennovy y Plankje (<a href='http://forum.goeiedageven.nl/'>http://forum.goeiedageven.nl/</a>)</li></ul>

Errores corregidos:<br>
<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#59'>Issue #59</a>: Algunos hiperenlaces pueden provocar que el archivo KNT crezca de manera desorbitada (crecimiento geométrico..)<br>
<ul><li>En la página correspondiente a la incidencia puede encontrar más información sobre el tipo de hiperenlace problemático.<br>
</li><li>Se ha definido una nueva opción de línea de comandos (-clean) para limpiar/reparar un archivo que tenga ese problema (o que lo pueda tener latente, por contener hiperenlaces de ese tipo)<br>
</li></ul></li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#50'>Issue #50</a>: Menú contextual sobre Pestaña y Export...</li></ul>

<hr />
Versión: 1.7.5 -  fecha: 31/ene/2009<br>
<br>
Mejoras:<br>
<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#23'>Issue #23</a>: Versión multilanguage de KeyNote NF (nueva opción de configuración) Se incluye en esta versión un fichero con una traducción parcial al español (castellano). Esta sirve de ejemplo de cómo realizar la traducción. En la descripción de la incidencia hay más información.<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#31'>Issue #31</a>: Al pulsar TAB o SHIFT-TAB sobre múltiples líneas se obtiene el mismo comportamiento que en notepad++<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#32'>Issue #32</a>: Ctrl+UP/DOWN permiten desplazar el documento hacia arriba o hacia abajo, sin mover el cursor.<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#38'>Issue #38</a>: Al pulsar INICIO el cursor se desplaza hacia la primera posición de texto (no espacio) de la línea.</li></ul>

Errores corregidos:<br>
<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#24'>Issue #24</a>: No se mostraba el contenido de los nodos en equipos sin la DLL MSFTEDIT.DLL<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#26'>Issue #26</a>: El nuevo formato de hiperenlace (<a href='https://code.google.com/p/keynote-nf/issues/detail?id=12'>issue 12</a>) no funcionaba sobre notas marcadas como "Plain text only"<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#27'>Issue #27</a>: Conversión incorrecta de hiperenlaces internos con prefijo "<a href='file:///?'>file:///?</a>" hacia el nuevo formato<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#42'>Issue #42</a>: La sangría de primera línea no funcionaba como debería. Ahora la sangría funciona como en MS Word: La sangría de primera línea es relativa a la sangría izquierda, no al revés. Y puede ser positiva o negativa.<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#36'>Issue #36</a>: Shift+Ctr+` (Reducir Sangría de primera línea) no hacía nada. Se estaba ignorando Shift+Ctr.<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#33'>Issue #33</a>: Las combinaciones AltGr+C/V/X eran ignoradas<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#28'>Issue #28</a>: Al tener activada la opción "One instance only" la segunda instancia se cerraba con una excepción.<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#41'>Issue #41</a>: Los nombres de archivos se guardaban siempre en minúsculas<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#39'>Issue #39</a>: La búsqueda podía no funcionar sobre la versión descargada desde SVN</li></ul>

<hr />
Versión: 1.7.4 Rev.2 -  date: 02/Jan/2009<br>
<br>
Errores corregidos:<br>
<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#20'>Issue #20</a>: Pegar desde teclado con Shift-Insert: está funcionando como "Paste as Text" (sin formato)<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#21'>Issue #21</a>: Cambiar el estilo de fuente de una selección, sin perder estilos ya aplicados</li></ul>

<hr />
Versión: 1.7.4 -  fecha: 29/Dic/2008  (Renombrado como KeyNote NF)<br>
<br>
Mejoras:<br>
<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#12'>Issue #12</a>: Mejora en la gestión de hipervínculos. Para las nuevas versiones del control Rich Edit se usa el comando RTF: <code> {\field{\*\fldinst{HYPERLINK "hyperlink"}}{\fldrslt{\cf1\ul textOfHyperlink</code> }}} Ahora los hipervínculos pueden mostrar textos diferentes a la propia URL.<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#7'>Issue #7</a>: Mejora y generalización del manejo de las teclas usuales del portapapeles:  Ctrl-C, CTRL-V, Ctrl-X / Ctrl-Ins, Shift-Ins, Shift-Supr.  Mediante estas funciones es posible también copiar y pegar nodos y subárboles, así como moverlos (cortar y pegar) dentro del archivo.</li></ul>


Errores corregidos:<br>
<br>
<ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#10'>Issue #10</a>: Modificar 'First Indent' en una selección de múltiples líneas. Resuelto de una manera más correcta, utilizando PFM_OFFSETINDENT en el control RichEdit, en lugar de PFM_STARTINDENT. Ahora funciona de manera correcta, además de no "consumir" los "deshacer".<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#9'>Issue #9</a>: Al pulsar Intro sobre una línea vacía con estilo de lista (viñetas o numerada) debería eliminarse el estilo de lista de esa línea.<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#13'>Issue #13</a>: Comportamiento de listas (viñetas o lista numerada): La indentación no se establece siempre de la manera esperada.<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#14'>Issue #14</a>: El menú contextual correspondiente a las notas (pestañas) no aparecía bajo el cursor<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#15'>Issue #15</a>: Se está permitiendo introducir RETURN incluso en modo de sólo lectura<br>
</li><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#16'>Issue #16</a>: Error al salvar el archivo tras haber eliminado previamente un nodo con hijos ocultos<br>
</li></ul><ul><li><a href='https://code.google.com/p/keynote-nf/issues/detail?id=#18'>Issue #18</a>: Al insertar un nodo éste puede no mostrarse en la posición correcta si el hermano previo está oculto</li></ul>

<hr />
03 octubre 2008 - version 1.7.3.3<br>
<br>
<ul><li>Corregido problema con la inserción de URL o enlace a fichero: al hacer click en ellos no se recuperaba más que una parte de la dirección. El origen de este error estaba relacionado con el hecho de que el control RTF que se está usando es Unicode. Al corregirlo, se ha solucionado el problema que impedía utilizar la opción "Show word count in status bar". Ahora el comportamiento de la barra de estado es el habitual en KeyNote.</li></ul>

<hr />
02 octubre 2008 - version 1.7.3.2<br>
<br>
<ul><li>La corrección al problema de Pegar no había sido correcta. Podía generar excepciones por el comportamiento un tanto especial de "msftedit.dll". Realizado de una manera diferente. Ahora ya no llega a ser necesario abrir la ventana modal PasteSpecial.</li></ul>

<hr />
30 septiembre 2008 - version 1.7.3<br>
<br>
<ul><li>Corregido problema con las búsquedas: Al utilizar "msftedit.dll" los mensajes EM_FINDTEXTEX no funcionan correctamente. Se ha tenido que recurrir a EM_FINDTEXTEXW, que utiliza cadenas de búsqueda en Unicode.<br>
</li><li>Solucionado problema que ocurría en ocasiones con la acción de pegar: sin razón aparente en ciertas ocasiones el comando Pegar es ignorado, mientras que sigue funcionando el pegado especial. Se ha incluido la detección de esta situación y la siguientes acciones: primeramente se intenta un pegado Rich Text Format, si a pesar de ello esto fallara (algo ya muy raro), se abrirá directamente la ventana modal de pegado especial, con lo que incomodidad es mínima.</li></ul>

<hr />
27 septiembre 2008 - version 1.7.2<br>
<br>
<ul><li>Tablas: A partir de ahora se pueden visualizar y utilizar correctamente las tablas en RTF.<br>
<ul><li>Esta mejora está disponible para Windows XP SP1 y superior, a través de "msftedit.dll"<br>
</li><li>Por el momento, el diseño de estas tablas debe realizarse a través de otros programas, como Excel o Word, copiándolas y pegándolas a continuación dentro de un fichero keynote.<br>
</li><li>Esta funcionalidad es por ahora incompatible con la opción "Show word count in status bar" por lo que la opción (probablemente apenas utilizada) simplemente se está ignorando.<br>
</li></ul></li><li>Mejoras menores en el tratamiento de las alarmas:<br>
<ul><li>Es posible cerrar la ventana modal pulsando ESC<br>
</li><li>Al posponer una alarma, se selecciona automáticamente otra alarma visible y se mantiene como valor por defecto la opción aplicada a la anterior alarma.<br>
</li></ul></li><li>Corregida excepción que se producía en la acción "Delete Style Definition". Este error fue introducido al migrar a la nueva versión de KeyNote.</li></ul>


<hr />
23 julio 2008 - version 1.7.1 (Rev. 4)<br>
<ul><li>Controlada excepción producida al abrir KeyNote con la cola de impresión parada (servidor RPC parado).</li></ul>

<hr />
16 julio 2008 - version 1.7.1 (Rev. 3)<br>
<ul><li>Corregido error relativo al establecimiento de alarmas: se producía una excepción al abrir un documento con alarmas desde otro también con alarmas (o al reabrir un documento al ser modificado desde fuera)</li></ul>

<hr />
25 November 2007 - version 1.7.1<br>
<ul><li>Añadida la posibilidad de establecer alarmas, asociadas a nodos</li></ul>

<hr />
13 November 2007 - version 1.7.0<br>
<ul><li>Corregido un error que podía afectar tanto a las búsquedas como a las exportaciones o al envío de email. En algunas raras ocasiones el contenido de un nodo podía provocar que el mecanismo de búsqueda se "bloqueara" en ese nodo:  el contenido del nodo es volcado sobre un control auxiliar; para algunos contenidos (muy pocos y raros) una vez volcados en el control auxiliar éste no podía ser limpiado ni reemplazado. Se ha adoptado una solución de compromiso: cuando esto ocurre simplemente se elimina y se vuelve a crear nuevamente el control.<br> Lo extraño es que este comportamiento se daba con cualquier control temporal que se crease (TRxRichEdit,   TRichEdit, TTabRichEdit), pero no si como control auxiliar se usaba ActiveNote.Editor u otro editor de otras pestañas. No he llegado a encontrar ninguna propiedad establecida en ActiveNote.Editor que justifique la diferencia de comportamiento.<br>
</li><li>Cambiado el comportamiento de ESCAPE en la ventana Scratch. En lugar de pasar el foco al control de edición de la nota, minimiza KeyNote.<br>
</li><li>Se mantiene la posibilidad de seleccionar Checkboxes para todos los nodos (View/Tree Checkboxes -- Ahora View/All nodes Checkboxes) y se añade la de poder mostrar Checkboxes sólo en los nodos hijos de uno dado. (Children Checkbox)<br>
</li><li>Corregido el error que hacía que se perdiera la marca de check al mover un nodo. Ahora se mantiene tanto si se realiza mediante drag and drop como con Shift, también se respeta si se trasfiere el nodo (o subárbol).<br> Nota: De momento, si se mueve un nodo con Checkbox hacia otro que no muestra checkboxes para sus hijos tampoco se mostrará en éste (aunque la marca de check no se habrá perdido)<br>
</li><li>Añadida la capacidad de ocultar nodos. Esto puede conseguirse de dos formas<br>
<ul><li>Activando un modo que oculta automáticamente los nodos chequeados (Show or Hide checked nodes)<br>
</li><li>Filtrando los nodos de una nota o todas las notas en base a los criterios de búsqueda (Filter Tree Note)<br>
</li></ul><blockquote>En las búsquedas (y filtrados) es posible indicar si se quiere o no considerar también los nodos ocultos. Al seguir un favorito que apunte a un nodo oculto éste se hará visible. Los nodos ocultos (por estar chequeados y aplicado el botón Check Hidden Nodes o bien por haber sido filtrados) no impiden realizar cualquiera de las funciones que se pueden aplicar a un árbol.