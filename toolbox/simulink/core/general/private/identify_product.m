function product = identify_product( basecode )









persistent xml_obj;

if isempty( xml_obj )
xml_obj = Simulink.MissingProductXMLCache( 'mathworks_products.xml', 'Product', 'BaseCode' );
end 

if contains( basecode, "," )

basecode = strsplit( basecode, "," );
product = strings( size( basecode ) );
for i = 1:numel( basecode )
product( i ) = xml_obj.query( basecode{ i }, '' );
end 
else 
product = xml_obj.query( basecode, '' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpsjMn_e.p.
% Please follow local copyright laws when handling this file.

