function LoadSysExtInterfMask( varargin )

blkH = varargin{ 1 };
isDummy = varargin{ 2 };
helpBtnCmd = varargin{ 3 };



if strcmpi( get_param( bdroot( blkH ), 'LibraryType' ), 'BlockLibrary' );return ;end 

instanceData = get_param( blkH, 'InstanceData' );
instanceDataNames = {  };
if ~isempty( instanceData )

[ instanceDataValues{ 1:length( instanceData ) } ] = instanceData.Value;
[ instanceDataNames{ 1:length( instanceData ) } ] = instanceData.Name;

end 


maskObj = Simulink.Mask.get( blkH );
if ( isempty( maskObj ) )
if ( isDummy );return ;end 
maskObj = Simulink.Mask.create( blkH );
end 
maskObj.Help = helpBtnCmd;
maskObj.IconOpaque = 'off';
maskObj.SelfModifiable = 'on';
maskObj.IconUnits = 'normalized';


if ( isDummy )
maskObj.Display = '';
elseif isempty( maskObj.Display )




sysDispStr = regexprep( maskObj.Type, '\s\[(Model\sExchange|Co\-Simulation),\sv(1|2)\.0\]$', '' );
maskObj.Display = [ 'disp(''', sysDispStr, ''');' ];
end 


paramToRemove = {  };
for i = 1:max( length( instanceDataNames ), length( maskObj.Parameters ) )

if ( i <= length( instanceDataNames ) && i <= length( maskObj.Parameters ) )


maskObj.Parameters( i ).Type = 'edit';
maskObj.Parameters( i ).TypeOptions = { '' };
maskObj.Parameters( i ).Name = instanceDataNames{ i };
maskObj.Parameters( i ).Value = instanceDataValues{ i };
maskObj.Parameters( i ).Evaluate = 'off';
elseif ( i <= length( instanceDataNames ) )

maskObj.addParameter( 'Type', 'edit', 'TypeOptions', { '' }, 'Name',  ...
instanceDataNames{ i }, 'Prompt', instanceDataNames{ i }, 'Value',  ...
instanceDataValues{ i }, 'Evaluate', 'off' );
elseif ( i <= length( maskObj.Parameters ) )

paramToRemove = [ paramToRemove, { maskObj.Parameters( i ).Name } ];
end 
end 

for i = paramToRemove
maskObj.removeParameter( i{ 1 } );
end 









end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpbOOkha.p.
% Please follow local copyright laws when handling this file.

