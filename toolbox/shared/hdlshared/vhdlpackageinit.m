function vhdlpackageinit





hdlsetparameter( 'vhdl_package_required', 1 );

hdlsetparameter( 'vhdl_package_library',  ...
'LIBRARY IEEE;\nUSE IEEE.std_logic_1164.all;\nUSE IEEE.numeric_std.ALL;\n\n' );

hdlsetparameter( 'vhdl_package_type_defs', '  -- Type Definitions\n' );
hdlsetparameter( 'vhdl_package_constants', '  -- Global Constants\n' );
hdlsetparameter( 'vhdl_package_function_headers', '  -- Global Function Headers\n' );
hdlsetparameter( 'vhdl_package_functions', '  -- Global Function Definitions\n' );





% Decoded using De-pcode utility v1.2 from file /tmp/tmprFTNLB.p.
% Please follow local copyright laws when handling this file.

