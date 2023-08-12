function obj = create_basic_check( objType, id, checkFcn, actionFcn, options )





R36
objType
id
checkFcn
actionFcn = [  ]
options.context = 'None';
options.checkedByDefault = true;
options.style = 'StyleOne';
end 

checkId = [ 'mathworks.simscape.', id ];

messageCatalog = [ 'physmod:simscape:advisor:modeladvisor:', id ];
getMessage = @( msgId )DAStudio.message( [ messageCatalog, ':', msgId ] );

switch objType

case 'check'


obj = ModelAdvisor.Check( checkId );

obj.CallbackContext = 'None';
obj.Visible = true;
obj.Enable = true;
obj.Value = options.checkedByDefault;

obj.Group = 'Simscape';

obj.CSHParameters.MapKey = 'ma.simscape';
obj.CSHParameters.TopicID = checkId;


obj.Title = getMessage( 'Title' );
obj.TitleTips = getMessage( 'TitleTips' );


obj.setCallbackFcn( checkFcn, options.context, options.style );


if ~isempty( actionFcn )
updateAction = ModelAdvisor.Action;
updateAction.setCallbackFcn( actionFcn );
updateAction.Name = getMessage( 'ActionName' );
updateAction.Description = getMessage( 'ActionDescription' );
updateAction.Enable = true;
obj.setAction( updateAction );
end 

case 'task'

obj = ModelAdvisor.Task( checkId );
obj.setCheck( checkId );

otherwise 
obj = [  ];
pm_assert( false, [ 'Unsupported object request: ', objType ] );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpSdWwQn.p.
% Please follow local copyright laws when handling this file.

