function outStruct = isModelRefTargetUpToDate( topModel, aFunc )

arguments
    topModel{ mustBeTextScalar, mustBeNonempty }
    aFunc{ mustBeA( aFunc, 'function_handle' ) }%#ok<INUSA>
end

stat = loc_setup( topModel );
oc = onCleanup( @(  )loc_cleanup( topModel, stat ) );

evalin( 'base', 'mathworks_slbuild_testing = [];' );
log = evalc( 'aFunc()' );%#ok<NASGU>

statVar = evalin( 'base', 'mathworks_slbuild_testing' );

outStruct = [  ];
if ~isempty( statVar )
    fNames1 = fields( statVar );

    for i = 1:numel( fNames1 )
        fname = fNames1{ i };
        origStruct = statVar.( fname );

        index = numel( outStruct ) + 1;
        for j = 1:numel( origStruct.mdlrefs )
            outStruct( index ).Model = string( origStruct.mdlrefs( j ) );%#ok<*AGROW>
            outStruct( index ).IsTargetUpToDate = origStruct.status( j ) ==  ...
                Simulink.ModelReference.internal.ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE;
            outStruct( index ).Reason = string( origStruct.reason( j ) );
            index = index + 1;
        end
    end
    outStruct = struct2table( outStruct );
end

oc.delete(  );
end

function stat = loc_setup( topModel, stat )
stat.isBDLoaded = bdIsLoaded( topModel );
load_system( topModel );
stat.df = Simulink.PreserveDirtyFlag( topModel );
stat.rebuildSetting = get_param( topModel, 'UpdateModelReferenceTargets' );
stat.rebuildMsgSetting = get_param( topModel, 'CheckModelReferenceTargetMessage' );
set_param( topModel, 'UpdateModelReferenceTargets', 'AssumeUpToDate' );
set_param( topModel, 'CheckModelReferenceTargetMessage', 'warning' );

stat.msgID = 'Simulink:modelReference:OutOfDate';
warnStatus = warning( 'query', stat.msgID );
stat.warnState = warnStatus.state;
warning( 'off', stat.msgID );
end

function loc_cleanup( topModel, stat )
evalin( 'base', 'clear mathworks_slbuild_testing' );
if ~stat.isBDLoaded
    close_system( topModel, 0 );
else
    set_param( topModel, 'CheckModelReferenceTargetMessage', stat.rebuildMsgSetting );
    set_param( topModel, 'UpdateModelReferenceTargets', stat.rebuildSetting );
end
warning( stat.warnState, stat.msgID );
stat.df.delete(  );
end

