function findVarsDoMESearch( varargin )








if nargin == 1

assert( ischar( varargin{ 1 } ) );
context = varargin{ 1 };

obj = get_param( context, 'Object' );
while ~isa( obj, 'Simulink.BlockDiagram' )
obj = obj.getParent;
end 


update = 'no';
wks = obj.ModelWorkspace;
if ( ~wks.hasCachedVarUsageInfo || strcmp( get_param( obj.getFullName, 'Dirty' ), 'on' ) )
doCompile = findVarsCompileQuestDialog( getFullName( obj ) );

if doCompile
update = 'yes';
else 
return ;
end 
end 


loc_findUsedVars( context, update );
else 

assert( nargin == 2 );

srcName = varargin{ 1 };
scopeName = varargin{ 2 };

assert( ischar( srcName ) && ischar( scopeName ) );


mdls = find_system( 'type', 'block_diagram' );
showDialog = false;
isDataSrcUsed = false;
mdlsNeedCompile = {  };
for i = 1:numel( mdls )
allDataDicts = slprivate( 'getAllDataDictionaries', mdls{ i } );

if any( ismember( allDataDicts, srcName ) )
isDataSrcUsed = true;

mdlObj = get_param( mdls{ i }, 'Object' );
if ~mdlObj.isLibrary && ( ~mdlObj.ModelWorkspace.hasCachedVarUsageInfo )
showDialog = true;
mdlsNeedCompile{ end  + 1 } = mdls{ i };%#ok
end 
end 
end 


update = 'no';
if ( ~isDataSrcUsed )

update = 'yes';
elseif ( showDialog )

doCompile = findVarsCompileQuestDialog( mdlsNeedCompile );
if doCompile
update = 'yes';
else 

return ;
end 
end 


dataSrc = [ scopeName, ' (', srcName, ')' ];


loc_findUnusedVars( dataSrc, update );
end 
end 


function loc_findUsedVars( context, update )
me = daexplr;


daexplr( me.getRoot, 'view', me.getRoot );


me.search( getString( message( 'modelexplorer:DAS:ME_FOR_REFERENCED_VARIABLES' ) ), true, context, update );
end 

function loc_findUnusedVars( dataSrc, update )
me = daexplr;


me.search( getString( message( 'modelexplorer:DAS:ME_FOR_UNUSED_VARIABLES' ) ), true, dataSrc, update );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSNXtMh.p.
% Please follow local copyright laws when handling this file.

