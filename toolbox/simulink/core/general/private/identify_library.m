function [ product, basecode ] = identify_library( libname )


















persistent xml_obj;

if isempty( xml_obj )
xml_obj = Simulink.MissingProductXMLCache( 'shipping_library_map.xml', 'Library', 'Name' );
end 
basecode = xml_obj.query( libname, 'ProductCode' );
if basecode ~= ""
if ~contains( basecode, "," )
product = identify_product( basecode );
else 
product = string( DAStudio.message( 'Simulink:ProxyBlock:BlockText_RequiredProduct' ) );
end 
else 




product = string( identify_library_in_slblocksearchdb( libname ) );
basecode = "";
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0OB9fj.p.
% Please follow local copyright laws when handling this file.

