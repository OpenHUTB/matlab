function [ product, basecode ] = identify_block_type( type )










persistent xml_obj;

if isempty( xml_obj )
xml_obj = Simulink.MissingProductXMLCache( 'block_type_map.xml', 'BlockType', 'Name' );
end 

basecode = xml_obj.query( type, 'ProductCode' );
if basecode ~= ""
if ~contains( basecode, "," )
product = identify_product( basecode );
else 
product = string( DAStudio.message( 'Simulink:ProxyBlock:BlockText_RequiredProduct' ) );
end 
else 
product = "";
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmph1E4Q0.p.
% Please follow local copyright laws when handling this file.

