function labelHelper( ax, editingLabel )




if ~isempty( ax )

service = matlab.plottools.service.MetadataService.getInstance(  );
adapter = service.getMetaDataAccessor( ax );

labelObj = adapter.get( editingLabel );

switch editingLabel
case 'XLabel'
codegenActionID = matlab.internal.editor.figure.ActionID.XLABEL_ADDED;
case 'YLabel'
codegenActionID = matlab.internal.editor.figure.ActionID.YLABEL_ADDED;
case 'ZLabel'
codegenActionID = matlab.internal.editor.figure.ActionID.ZLABEL_ADDED;
case 'Title'
codegenActionID = matlab.internal.editor.figure.ActionID.TITLE_ADDED;
end 

if isobject( labelObj )
addOneShotEditingCompleteListener( ax, editingLabel, labelObj, codegenActionID );
end 
end 

end 

function addOneShotEditingCompleteListener( ax, labelProp, labelObj, codegenActionID )



tempListenerProp = findprop( labelObj, 'TempMOLEditingListener' );
if isempty( tempListenerProp )
tempListenerProp = addprop( labelObj, 'TempMOLEditingListener' );
tempListenerProp.Transient = true;
tempListenerProp.Hidden = true;
end 

prevLabelText = labelObj.String;

labelObj.TempMOLEditingListener = event.proplistener( labelObj, labelObj.findprop( 'Editing' ),  ...
'PostSet', @( ~, ~ )editingCallback( ax, labelProp, labelObj, prevLabelText, codegenActionID ) );

labelObj.Editing = 'on';
end 

function editingCallback( ax, labelProp, labelObj, prevText, codegenActionID )

if labelObj.Editing == "off"
delete( labelObj.TempMOLEditingListener );
labelObj.TempMOLEditingListener = [  ];

service = matlab.plottools.service.MetadataService.getInstance(  );
adapter = service.getMetaDataAccessor( ax );


hFig = ancestor( labelObj, 'figure' );

newText = labelObj.String;


set( adapter, labelProp, newText )


registerUndoRedoAction( hFig, labelProp, adapter, newText, prevText );

if isprop( hFig, 'FigureCodeGenController' )
matlab.graphics.interaction.generateLiveCode( ax, codegenActionID );
end 
end 
end 

function registerUndoRedoAction( hFig, labelProp, adapter, newText, prevText )


fcn = @( labelObj, ~ )set( adapter, labelProp, newText );
invfcn = @( labelObj, ~ )set( adapter, labelProp, prevText );

cmd.Name = sprintf( 'Insert%s', labelProp );
cmd.Function = fcn;
cmd.InverseFunction = invfcn;
cmd.Varargin = { adapter, newText };
cmd.InverseVarargin = { adapter, prevText };
uiundo( hFig, 'function', cmd );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUh_0NZ.p.
% Please follow local copyright laws when handling this file.

