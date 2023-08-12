function [ fcnIds, scriptIds ] = getIncludedFunctions( report, opts )
R36
report( 1, 1 )struct
opts.ShowUserVisibleOnly( 1, 1 )logical = true
opts.ShowInternalEntryPoints( 1, 1 )logical = ~coderapp.internal.util.isInstall(  )
end 



if ~isfield( report, 'inference' ) || isempty( report.inference )
fcnIds = [  ];
scriptIds = [  ];
return 
end 

allFcns = report.inference.Functions;
scripts = report.inference.Scripts;

scriptCount = numel( scripts );
allFcnScriptIds = [ allFcns.ScriptID ];
hasScriptFcnMask = allFcnScriptIds > 0 & allFcnScriptIds <= scriptCount;
hasScriptFcnIds = find( hasScriptFcnMask );

if ~opts.ShowUserVisibleOnly

fcnIds = hasScriptFcnIds;
scriptIds = [ allFcns( fcnIds ).ScriptID ];
return 
end 


fcnMask = hasScriptFcnMask;
fcnMask( fcnMask ) = [ scripts( allFcnScriptIds( fcnMask ) ).IsUserVisible ];

for i = find( ~fcnMask )
fcn = allFcns( i );
fcnMask( i ) = fcn.IsExtrinsic || fcn.IsAutoExtrinsic ||  ...
( ~isempty( fcn.Messages ) && any( ismember( { fcn.Messages.MsgTypeName }, { 'Fatal', 'Error' } ) ) );
end 


if isprop( report.inference, 'RootFunctionIDs' ) && ( nnz( fcnMask ) == 0 || opts.ShowInternalEntryPoints )

epIds = report.inference.RootFunctionIDs;
epIds = epIds( hasScriptFcnMask( epIds ) & ismember( allFcnScriptIds( epIds ), [ allFcns( epIds ).ScriptID ] ) );
fcnMask( epIds ) = true;
end 


scriptMask = [ scripts.IsUserVisible ];
scriptMask( setdiff( allFcnScriptIds( fcnMask ), 0 ) ) = true;
scriptIds = find( scriptMask );


fcnMask( ismember( allFcnScriptIds, scriptIds ) ) = true;
fcnIds = find( fcnMask );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjWlm8e.p.
% Please follow local copyright laws when handling this file.

