function editModes = pmsl_geteditingmodes( schema, productDialogClasses, maskNames )




















pmDialogClasses = {  ...
'PMDialogs.PmCheckBox', { 'ValueBlkParam' }, {  }; ...
'PMDialogs.PmDropDown', { 'ValueBlkParam' }, {  }; ...
'PMDialogs.PmLabelSpinner', { 'ValueBlkParam' }, {  }; ...
'PMDialogs.PmUnitSelect', { 'ValueBlkParam' }, {  }; ...
'PMDialogs.PmEditUnitSelect', { 'ValueBlkParam' }, {  }; ...
'PMDialogs.PmEditDropDown', { 'ValueBlkParam' }, {  } ...
 };
allClasses = [ pmDialogClasses;productDialogClasses ];




authoringParams = l_geteditingmodes( schema );
authoringParams = intersect( authoringParams, maskNames );




editModes = l_constructRtmArray( authoringParams );


function allParams = l_geteditingmodes( lSchema )



allParams = {  };
if isfield( lSchema, 'ClassName' )
idx = find( strcmp( lSchema.ClassName, allClasses( :, 1 ) ) );
if ~isempty( idx )
pm_assert( length( idx ) == 1 );
variableParamNames = allClasses{ idx, 2 };
for paramName = variableParamNames
allParams{ end  + 1 } = lSchema.Parameters.( paramName{ 1 } );%#ok<AGROW>
end 
hardCodedParamNames = allClasses{ idx, 3 };
allParams = [ allParams, hardCodedParamNames ];
end 
end 

if ( isfield( lSchema, 'Items' ) )
children = lSchema.Items;
for child = children
allParams = [ allParams, l_geteditingmodes( child{ 1 } ) ];%#ok<AGROW>
end 
end 


end 

end 


function editModes = l_constructRtmArray( paramNames )


authoringEnum = ssc_param( 'authoring' );
editModes = [  ];
for idx = 1:length( paramNames )
editModes( idx ).maskName = paramNames{ idx };%#ok<AGROW>
editModes( idx ).editingMode = authoringEnum;%#ok<AGROW>
end 

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpzDdXCp.p.
% Please follow local copyright laws when handling this file.

