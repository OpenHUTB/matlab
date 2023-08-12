function vhdlpackageaddtypedef( typedef )





if hdlgetparameter( 'vhdl_package_required' ) == 0
vhdlpackageinit;
end 
if any( findstr( hdlgetparameter( 'vhdl_package_type_defs' ), typedef ) ) == 0

hdlsetparameter( 'vhdl_package_type_defs',  ...
[ hdlgetparameter( 'vhdl_package_type_defs' ), typedef ] );
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpleZhcD.p.
% Please follow local copyright laws when handling this file.

