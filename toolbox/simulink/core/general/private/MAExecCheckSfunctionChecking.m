function result = MAExecCheckSfunctionChecking( system )








result = '';
passString = [ '<p /><font color="#008000">', DAStudio.message( 'Simulink:tools:MAPassedMsg' ), '</font>' ];
model = bdroot( system );
hScope = get_param( system, 'Handle' );
hModel = get_param( model, 'Handle' );
mdladvObj = Simulink.ModelAdvisor.getModelAdvisor( system );
mdladvObj.setCheckResultStatus( false );

if ( hScope == hModel )




sfuncHandles = find_system( hModel, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'LookUnderMasks', 'all', 'BlockType', 'S-Function' );
sfuncHandles = mdladvObj.filterResultWithExclusion( sfuncHandles );
allSfunNames = get_param( sfuncHandles, 'FunctionName' );
if ( ~iscell( allSfunNames ) )
allSfunNames = { allSfunNames };
end 
[ sfunNames, a, b ] = unique( allSfunNames );
slist = [  ];

if ( ~iscell( sfunNames ) )
sfunNames = { sfunNames };
end 


for i = 1:length( sfunNames )
slist( i ).name = sfunNames{ i };
slist( i ).blockHandles = {  };
slist( i ).blockNames = {  };
end 

for i = 1:length( sfuncHandles )
slist( b( i ) ).blockNames{ end  + 1 } = [ get_param( sfuncHandles( i ), 'Parent' ), '/', get_param( sfuncHandles( i ), 'Name' ) ];
slist( b( i ) ).blockHandles{ end  + 1 } = sfuncHandles( i );
end 


workdir = fullfile( matlabroot, 'work' );

for i = length( slist ): - 1:1


loc = which( slist( i ).name );
interestFlag = 1;

if ( exist( loc ) ~= 3 )
interestFlag = 0;
end 


parent = get_param( slist( i ).blockHandles{ 1 }, 'parent' );
try 
isStateflow = is_stateflow_based_block( parent );
if isStateflow
interestFlag = 0;
end 
catch 
end 


if ( strncmp( matlabroot, loc, length( matlabroot ) ) && ~strncmp( workdir, loc, length( workdir ) ) )
interestFlag = 0;
end 



if ~interestFlag
slist = [ slist( 1:i - 1 ), slist( i + 1:end  ) ];
end 
end 

if ( length( slist ) )

scc_val = get_param( hModel, 'ConsistencyChecking' );
abc_val = get_param( hModel, 'ArrayBoundsChecking' );
scc_flag = 1;
abc_flag = 1;

if ( ~max( strcmp( scc_val, { 'error', 'warning' } ) ) )

scc_flag = 0;
end 

if ( ~max( strcmp( abc_val, { 'error', 'warning' } ) ) )

abc_flag = 0;
end 


if ( scc_flag && abc_flag )
result = [ result, ' <p /> ', passString ];
mdladvObj.setCheckResultStatus( true );
else 
encodedModelName = modeladvisorprivate( 'HTMLjsencode', get_param( hModel, 'Name' ), 'encode' );
encodedModelName = [ encodedModelName{ : } ];

if scc_flag
scc_msg = passString;
else 
scc_msg = DAStudio.message( 'Simulink:tools:MASetSolverDataInconsistencyToWarning', encodedModelName );
end 

if abc_flag
abc_msg = passString;
else 
abc_msg = DAStudio.message( 'Simulink:tools:MASetArrayBoundsCheckingToWarning', encodedModelName );
end 

ma = Simulink.ModelAdvisor.getModelAdvisor( hModel );
sfunTable = buildMASfunTable( slist, ma );

result = [ result,  ...
DAStudio.message( 'Simulink:tools:MAMsgCheckSfunctions' ) ...
, ' <p />', sfunTable,  ...
' <p /> ', scc_msg, ' <p /> ', abc_msg,  ...
' <p /> ', DAStudio.message( 'Simulink:tools:MADiagHasPerformanceHit', 'none' ) ];

mdladvObj.setCheckResultStatus( false );
end 

else 
result = [ ' <p /> ', passString ];
mdladvObj.setCheckResultStatus( true );
return ;
end 

else 
result = [ '<p /> ', passString ];
mdladvObj.setCheckResultStatus( true );
end 
result = { result };

end 




function retval = buildMASfunTable( slist, ma )


nl = sprintf( '\n' );
sfunTable = [ nl, '<table border="1" cellpadding="2">' ];

sfunTable = [ sfunTable, '[<tr><td><b>ID</b></td><td><b>S-Function</b></td><td><b>', DAStudio.message( 'ModelAdvisor:engine:Block' ), '</b></td></tr>]' ];


for i = 1:length( slist )
sfunTable = [ sfunTable, '<tr> <td align="right">', num2str( i ), '</td><td><!-- mdladv_ignore_start -->', which( slist( i ).name ), '<!-- mdladv_ignore_finish --> </td><td> ', blockref( slist( i ).blockNames{ 1 } ), '</td></tr>', nl ];
if length( slist( i ).blockNames ) > 1
sfunTable = [ sfunTable, '<tr><td>&#160;</td><td>&#160;</td><td>', blockref( slist( i ).blockNames{ 2 } ), '</td></tr>', nl ];
if length( slist( i ).blockNames ) > 2
sfunTable = [ sfunTable, '<tr><td>&#160;</td><td>&#160;</td><td> ...</td></tr>', nl ];
end 
end 
end 


sfunTable = [ sfunTable, ' </table>' ];

if ( length( slist ) < 9 )
retval = sfunTable;
else 
tableLink = saveTable( sfunTable, ma );
retval = sprintf( tableLink, 1 );
end 

end 



function refstring = blockref( block )

nl = sprintf( '\n' );
dispBlkName = regexprep( block, nl, ' ' );
codeBlkName = modeladvisorprivate( 'HTMLjsencode', block, 'encode' );
codeBlkName = [ codeBlkName{ : } ];
refstring = [ '<a href="matlab:modeladvisorprivate(''hiliteSystem'',''', codeBlkName, ''');"> ', dispBlkName, '</a>' ];

end 


function tableLink = saveTable( table, ma )

workDir = ma.getWorkDir;
filename = fullfile( workDir, 'sfunTable.html' );
if ( exist( filename, 'file' ) )
notfound = 1;
while notfound
filename = fullfile( workDir, [ 'sfunTable', num2str( notfound ), '.html' ] );
if ( exist( filename, 'file' ) )
notfound = notfound + 1;
else 
notfound = 0;
end 
end 
end 

FILE = fopen( filename, 'w' );

fwrite( FILE, table, 'char' );

fclose( FILE );


tableLink = [ '<a href="file://', filename, '#%d">S-function Table</a>' ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpU0pUqF.p.
% Please follow local copyright laws when handling this file.

