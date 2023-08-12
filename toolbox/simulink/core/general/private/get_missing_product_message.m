function [ msg, no_hlinks ] = get_missing_product_message( prodname, basecode, is_library )












if nargin > 2 && is_library
catalog = 'Simulink:Libraries:';
else 
catalog = 'Simulink:ProxyBlock:';
end 

if isempty( basecode )
if ~isempty( prodname )
msg = DAStudio.message( [ catalog, 'ProductNotInstalled' ], i_hyperlink( prodname, '' ) );
no_hlinks = DAStudio.message( [ catalog, 'ProductNotInstalled' ], prodname );
else 
msg = '';
end 
else 
prodname = identify_product( basecode );
if numel( prodname ) > 1
basecodes = strsplit( basecode, ',' );
msg = DAStudio.message( [ catalog, 'ProductsNotInstalled' ] );
no_hlinks = msg;
for i = 1:numel( prodname )
msg = [ msg, newline, '    ', i_hyperlink( prodname( i ), basecodes{ i } ) ];%#ok<AGROW>
no_hlinks = [ no_hlinks, newline, '    ', char( prodname( i ) ) ];%#ok<AGROW>
end 
else 
msg = DAStudio.message( [ catalog, 'ProductNotInstalled' ], i_hyperlink( prodname, basecode ) );
no_hlinks = DAStudio.message( [ catalog, 'ProductNotInstalled' ], prodname );
end 
end 

end 

function str = i_hyperlink( prodname, basecode )
str = '<a href="matlab:matlab.internal.addons.launchers.showExplorer(''AO_MODEL_RP''';
if ~isempty( basecode )
str = [ str, ',''identifier'',''', basecode, '''' ];
end 
str = [ str, ')">', char( prodname ), '</a>' ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjooIJq.p.
% Please follow local copyright laws when handling this file.

