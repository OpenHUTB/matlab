function ImplementSysExtInterfMask( varargin )

blkH = varargin{ 1 };
isDummy = varargin{ 2 };

if strcmpi( get_param( bdroot( blkH ), 'LibraryType' ), 'BlockLibrary' )
maskLockStatus = get_param( bdroot( blkH ), 'lock' );
set_param( bdroot( blkH ), 'lock', 'off' );
maskLockCleanup = onCleanup( @(  )set_param( bdroot( blkH ), 'lock', maskLockStatus ) );
end 


maskObj = Simulink.Mask.get( blkH );

if ( isempty( maskObj ) )
if ( isDummy );return ;end 
maskObj = Simulink.Mask.create( blkH );
end 


aMaskDialogRefreshHandler = Simulink.MaskDialogRefreshHandler( maskObj );%#ok<NASGU>


if ( isDummy )
maskObj.Display = '';
return ;
end 

systemname = varargin{ 3 };
ParamStruct = varargin{ 4 };
MaskDescription = varargin{ 5 };

helpBtnCmd = varargin{ 6 };

iconImgPath = varargin{ 7 };
if ( ~isempty( varargin{ 8 } ) )
outputPortInfo = varargin{ 8 };
else 
outputPortInfo = '';
end 

if ( ~isempty( varargin{ 9 } ) )
inputPortInfo = varargin{ 9 };
else 
inputPortInfo = '';
end 

modestring = varargin{ 10 };
IntrinsicBlockParamStruct = varargin{ 11 };

maskObj.Help = helpBtnCmd;
maskObj.IconOpaque = 'off';
maskObj.SelfModifiable = 'on';
maskObj.IconUnits = 'normalized';

if ( ~isempty( modestring ) )
maskObj.Type = [ systemname, ' [', modestring, ']' ];
else 
maskObj.Type = systemname;
end 


sysDispStr = regexprep( maskObj.Type, '\s\[(Model\sExchange|Co\-Simulation),\sv(1|2)\.0\]$', '' );

stringToDisplay = {  };
if ( ~isempty( iconImgPath ) )
baseDirStr = [ Simulink.fileGenControl( 'get', 'CacheFolder' ), filesep ];
if startsWith( iconImgPath, baseDirStr )

iconImgPath = [ '[Simulink.fileGenControl(''get'',''CacheFolder'') ''', filesep, iconImgPath( ( length( baseDirStr ) + 1 ):end  ), ''']' ];
else 
iconImgPath = [ '''', iconImgPath, '''' ];
end 

stringToDisplay = [ stringToDisplay, {  ...
[ 'if (exist(', iconImgPath, ',''file''))' ],  ...
[ '    image(', iconImgPath, ');' ],  ...
'else',  ...
[ '    disp(''', sysDispStr, ''');' ],  ...
'end',  ...
 } ];
else 
stringToDisplay = [ stringToDisplay, { [ 'disp(''', sysDispStr, ''');' ] } ];
end 

if ( ~isempty( outputPortInfo ) )
for idx = 1:length( outputPortInfo )
stringToDisplay = [ stringToDisplay, {  ...
[ 'port_label(''output'',', num2str( idx ), ',''', regexprep( outputPortInfo{ idx }, '''', '''''' ), ''');' ] } ];%#ok
end 
end 

if ( ~isempty( inputPortInfo ) )
for idx = 1:length( inputPortInfo )
stringToDisplay = [ stringToDisplay, {  ...
[ 'port_label(''input'',', num2str( idx ), ',''', regexprep( inputPortInfo{ idx }, '''', '''''' ), ''');' ] } ];%#ok
end 
end 


maskObj.Display = strjoin( stringToDisplay, '\n' );
maskObj.Description = MaskDescription;


ParamNames = [ { ParamStruct.Name }, { IntrinsicBlockParamStruct.Name } ];
ParamAliases = [ { ParamStruct.Alias }, { IntrinsicBlockParamStruct.Alias } ];
ParamValues = [ { ParamStruct.Default }, { IntrinsicBlockParamStruct.Default } ];
TypeArray = [ { ParamStruct.Type }, { IntrinsicBlockParamStruct.Type } ];
TypeOptionsArray = [ { ParamStruct.TypeOptions }, { IntrinsicBlockParamStruct.TypeOptions } ];
PromptsArray = [ { ParamStruct.Prompt }, { IntrinsicBlockParamStruct.Prompt } ];
Tunables = [ { ParamStruct.Tunable }, { IntrinsicBlockParamStruct.Tunable } ];
Evaluate = [ { ParamStruct.Evaluate }, { IntrinsicBlockParamStruct.Evaluate } ];
ReadOnly = [ { ParamStruct.ReadOnly }, { IntrinsicBlockParamStruct.ReadOnly } ];
Hidden = [ { ParamStruct.Hidden }, { IntrinsicBlockParamStruct.Hidden } ];
NeverSave = [ { ParamStruct.NeverSave }, { IntrinsicBlockParamStruct.NeverSave } ];
otherAttribs = [ { ParamStruct.others }, { IntrinsicBlockParamStruct.others } ];

numParams = length( ParamNames );
maskParamsUpdated = [  ];


instanceData = get_param( blkH, 'InstanceData' );

if ~isempty( instanceData )





[ instanceDataValues{ 1:length( instanceData ) } ] = instanceData.Value;
[ instanceDataNames{ 1:length( instanceData ) } ] = instanceData.Name;




for i = 1:numParams
idx = find( ismember( instanceDataNames, ParamNames{ i } ), 1 );
if ( isempty( idx ) );continue ;end 


ParamValues{ i } = instanceDataValues{ idx };
maskParamsUpdated( end  + 1 ) = idx;%#ok
end 
else 






maskParamValues = { maskObj.Parameters( : ).Value }';
maskParamNames = { maskObj.Parameters( : ).Name }';
maskParamTypes = { maskObj.Parameters( : ).Type }';



for i = 1:numParams
idx = find( ismember( maskParamNames, ParamNames{ i } ), 1 );
if ( isempty( idx ) );continue ;end 


if strcmp( ReadOnly{ i }, 'on' );continue ;end 

if strcmp( TypeArray{ i }, 'checkbox' )


if ~strcmp( maskParamValues{ idx }, 'on' ) && ~strcmp( maskParamValues{ idx }, 'off' )
continue ;
end 
elseif strcmp( TypeArray{ i }, 'popup' )


enumID =  - 1;
for idx2 = 1:length( TypeOptionsArray{ i } )
if strcmpi( TypeOptionsArray{ i }{ idx2 }, maskParamValues{ idx } )
enumID = idx2;
break ;
end 
end 
if ( enumID ==  - 1 );continue ;end 
end 


ParamValues{ i } = maskParamValues{ idx };
maskParamsUpdated( end  + 1 ) = idx;%#ok
end 
end 


aTableContainerName = 'BlockParametersTableControl';
aBlockParametersTable = maskObj.getDialogControl( aTableContainerName );
if isempty( aBlockParametersTable )
maskObj.addDialogControl( 'Type', 'table', 'Name', aTableContainerName );
end 


maskParams = Simulink.MaskParameter.createStandalone( numParams );

for i = 1:numParams
maskParam = maskParams( i );
maskParam.set(  ...
'Type', TypeArray{ i },  ...
'TypeOptions', TypeOptionsArray{ i },  ...
'Evaluate', Evaluate{ i },  ...
'Tunable', Tunables{ i },  ...
'Name', ParamNames{ i },  ...
'Prompt', PromptsArray{ i },  ...
'Value', ParamValues{ i },  ...
'Alias', ParamAliases{ i },  ...
'ReadOnly', ReadOnly{ i },  ...
'Internal', Hidden{ i },  ...
'NeverSave', NeverSave{ i },  ...
'Container', aTableContainerName ...
 );
end 

maskObj.set( 'Parameters', maskParams );

for i = 1:numParams

if ~isempty( otherAttribs{ i } )
maskParam = maskObj.getParameter( ParamNames{ i } );
maskParam.setAttributes( otherAttribs{ i }, true );
end 
end 

if strcmpi( get_param( bdroot( blkH ), 'LibraryType' ), 'BlockLibrary' )
maskLockCleanup.delete;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfjKvjy.p.
% Please follow local copyright laws when handling this file.

