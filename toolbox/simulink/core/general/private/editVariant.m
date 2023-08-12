function editVariant( ddFilePath )




if ~isempty( ddFilePath )
ddRef = Simulink.dd.open( ddFilePath );
variantStr = ddRef.getVariant;
options.Resize = 'on';
variant = inputdlg( DAStudio.message( 'SLDD:sldd:VariantCondition' ),  ...
DAStudio.message( 'SLDD:sldd:CreateVariantDictionary' ),  ...
1, { variantStr }, options );

if ~isempty( variant ) && ~isempty( variant{ : } )
ddRef.setVariant( variant{ : } );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpAd6Aiu.p.
% Please follow local copyright laws when handling this file.

