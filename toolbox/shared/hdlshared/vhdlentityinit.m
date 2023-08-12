function [ lib, pkg, decl, entity_end ] = vhdlentityinit( nname )






lib = 'LIBRARY IEEE;\nUSE IEEE.std_logic_1164.all;\nUSE IEEE.numeric_std.ALL;\n';
pkg = '';
decl = [ 'ENTITY ', nname, ' IS\n' ];
entity_end = [ '\nEND ', nname, ';\n\n\n' ];



% Decoded using De-pcode utility v1.2 from file /tmp/tmpGLKLn6.p.
% Please follow local copyright laws when handling this file.

