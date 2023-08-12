function interfaceToMask( varargin )


interfaceXml = varargin{ 1 };
blk = varargin{ 2 };
sfcnName = varargin{ 3 };

pDef = '';
if nargin > 3
pDef = varargin{ 4 };
end 

if isempty( pDef )

[ pDef, ~ ] = getSFcnParametersFromInterface( sfcnName, interfaceXml );
end 


if ( isstruct( pDef ) && isempty( fieldnames( pDef ) ) )
return 
end 



maskObj = [  ];
if isempty( Simulink.Mask.get( blk ) )
maskObj = Simulink.Mask.create( blk );
else 




return 
end 

parameterTable = sprintf( [ '%s_parameters' ], sfcnName );
maskObj.Description = sprintf( [ 'This is the default generated mask for the S-Function ''%s''' ], sfcnName );
tableParam = maskObj.addParameter( 'Name', parameterTable, 'Type', 'customtable' );
tableParam.Value = "{}";
tableControl = maskObj.getDialogControl( parameterTable );
tableControl.addColumn( 'Name', 'Name', 'Type', 'edit', 'Enabled', 'off' );

tableControl.addColumn( 'Name', 'DataType', 'Type', 'edit', 'Enabled', 'off' );


tableControl.addColumn( 'Name', 'Dimensions', 'Type', 'edit', 'Enabled', 'off' );
tableControl.addColumn( 'Name', 'IC', 'Type', 'edit' );
valColIdx = tableControl.getNumberOfColumns(  );
dimColIdx = valColIdx - 1;
callbackStr = sprintf( [ '' ...
, 'maskObj = get_param(gcbh, ''MaskObject'');\n',  ...
'tableControl = maskObj.getDialogControl(''%s'');\n',  ...
'' ], parameterTable );
callbackStrAssign = '';
sfunParamStr = '';
pStr = 'pStr = ';
pStrFormatSpec = '''';
pStrVals = '';
initialConditions = '';
paramGet = '';
valStr = sprintf( [ "{" ] );
rowStr = '';




































if isempty( pDef )
return 
end 
for i = 1:numel( pDef )


if ~isempty( rowStr )
valStr = sprintf( [ "%s;" ], valStr );
end 
name = pDef( i ).name;
dataType = pDef( i ).dataType;
initialCondition = pDef( i ).initialCondition;

dimensions = pDef.dimensions;

rowStr = sprintf( [ "'%s', '%s', '%s', '%s'" ], name, dataType, dimensions, initialCondition );
valStr = sprintf( [ "%s %s" ], valStr, rowStr );

str = sprintf( '%s = maskObj.getParameter(''%s'');\n', name, name );
pCallBackStr = sprintf( '%s%s', callbackStr, str );
pCallBackStr = [ pCallBackStr, sprintf( 'tableControl.setValue([%s %s],%s.Value);\n', num2str( i ), num2str( valColIdx ), name ) ];
pCallBackStr = [ pCallBackStr, sprintf( 'tableControl.setValue([%s %s],[''['' num2str(size(eval(%s.Value))) '']'']);\n', num2str( i ), num2str( dimColIdx ), name ) ];
maskObj.addParameter( 'Visible', 'off', 'Name', name, 'Value', initialCondition, 'Callback', pCallBackStr );
paramGet = [ paramGet, str, sprintf( '%s.Value = tableControl.getValue([%s %s]);\n', name, num2str( i ), num2str( valColIdx ) ) ];
if isempty( pStrVals )
pStrVals = [ pStrVals, name ];
initialConditions = [ initialConditions, initialCondition ];
else 
pStrVals = [ pStrVals, ',', name ];
initialConditions = [ initialConditions, ',', initialCondition ];
end 
end 

callbackStr = sprintf( "%s%s", callbackStr, paramGet );
valStr = sprintf( [ "%s }" ], valStr );
tableParam.Value = valStr;

callbackStr = sprintf( [  ...
'%s' ...
, 'set_param(gcbh,''Parameters'',''%s'');\n' ...
 ], callbackStr, pStrVals );
tableParam.Callback = callbackStr;


initStr = sprintf( [  ...
'if isempty(get_param(gcbh,''Parameters''))\n' ...
, '\t%%set_param(gcbh,''Parameters'',''%s'');\n' ...
, 'end' ],  ...
initialConditions );
set_param( blk, 'MaskInitialization', initStr )
set_param( blk, 'Parameters', pStrVals );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzGhFU3.p.
% Please follow local copyright laws when handling this file.

