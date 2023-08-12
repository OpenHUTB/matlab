function info = slsfviewmark( modelname, option, id, newvalue )

v = DAStudio.Viewmarker.getInstance;

if strcmp( option, 'closeUI' )
v.closeManagerUI(  );
elseif strcmp( option, 'background' )
try 
SLM3I.SLCommonDomain.setViewMarkersFlag( true );
v.background( id );
catch e
SLM3I.SLCommonDomain.setViewMarkersFlag( false );
rethrow( e );
end 
SLM3I.SLCommonDomain.setViewMarkersFlag( false );

elseif strcmp( option, 'snap' )
try 
SLM3I.SLCommonDomain.setViewMarkersFlag( true );
v.snap(  );
catch e
SLM3I.SLCommonDomain.setViewMarkersFlag( false );
rethrow( e );
end 
SLM3I.SLCommonDomain.setViewMarkersFlag( false );

elseif strcmp( option, 'open' )

if nargin < 3
id = '0';
end 

v.open( id, false, newvalue );

elseif strcmp( option, 'list' )
v.list(  );

elseif strcmp( option, 'getInfo' )
info = v.getInfo(  );

elseif strcmp( option, 'modifyname' )
v.modifyName( id, newvalue, modelname );

elseif strcmp( option, 'modifyannotation' )
v.modifyAnnotation( id, newvalue );

elseif strcmp( option, 'modifyannotation_model' )
v.modifyAnnotation_model( id, newvalue );

elseif strcmp( option, 'delete' )
v.deleteViewmark( id );

elseif strcmp( option, 'delete_model' )
v.deleteViewmark_model( id );

elseif strcmp( option, 'copy' )
v.copyViewmark( modelname, id );

elseif strcmp( option, 'refresh' )
v.refresh( id, newvalue );

elseif strcmp( option, 'markunavailable' )
v.markunavailable( id );
elseif strcmp( option, 'markavailable' )
v.markavailable( id );
elseif strcmp( option, 'unload' )
v.unload(  );
elseif strcmp( option, 'deletegroup' )
v.deletegroup( id );
elseif strcmp( option, 'deletegroup_model' )
v.deletegroup_model( id );
elseif strcmp( option, 'resetxml' )
v.resetXML(  );
elseif strcmp( option, 'drag_drop_update' )
v.dragDropUpdate( modelname, id, newvalue );
elseif strcmp( option, 'updateSelfie' )
v.updateSelfie( modelname );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3tm6Nn.p.
% Please follow local copyright laws when handling this file.

