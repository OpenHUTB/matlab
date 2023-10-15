classdef URLBuilder

    properties ( Constant )
        BaseDirectory( 1, : )char = '/toolbox/sltp/editor/web/'
    end

    methods ( Static )
        function URL = buildURL( modelHandle )

            graphEditor = sltp.GraphEditor( modelHandle );

            [ index, params ] = sltp.internal.URLBuilder.getURLInformation( modelHandle );
            params = strcat( '&', params );
            params = join( params, '' );

            URL = [ graphEditor.connect( [ sltp.internal.URLBuilder.BaseDirectory, index ] ),  ...
                params{ 1 } ];
            if isDebug(  )
                disp( connector.getUrl( URL ) );
            end
        end

        function [ index, params ] = getURLInformation( modelHandle )
            arguments
                modelHandle( 1, 1 )double
            end

            modelName = get_param( modelHandle, 'name' );
            mdlstr = num2str( modelHandle, '%.15f' );

            params = {  ...
                [ 'exportFunction=', int2str( strcmp( get_param( modelHandle, 'IsExportFunctionModel' ), 'on' ) ) ],  ...
                [ 'dirty=', int2str( strcmp( get_param( modelHandle, 'Dirty' ), 'on' ) ) ],  ...
                [ 'singleTasking=', int2str( ~validSolverAndTaskingOptions( modelHandle ) ) ],  ...
                [ 'model=', mdlstr ],  ...
                [ 'modelName=', modelName ],  ...
                [ 'allowGrouping=', int2str( bitand( slfeature( 'PartitioningView' ), 4 ) ) ],  ...
                [ 'allowImportExport=', int2str( bitand( slfeature( 'PartitioningView' ), 8 ) ) ],  ...
                [ 'allowMultiPriorityGroups=', int2str( bitand( slfeature( 'PartitioningView' ), 16 ) ) ],  ...
                [ 'showSimultaneous=', int2str( bitand( slfeature( 'PartitioningView' ), 32 ) ) ],  ...
                [ 'multiCoreRTB=', int2str( slfeature( 'MultiCoreDeterRTB' ) ) ],  ...
                [ 'protectOrder=', int2str( slfeature( 'ProtectOrderOfExecution' ) ) ],  ...
                [ 'prototypeModeling=', int2str( slfeature( 'ScheduleEditorPrototypeModeling' ) ) ]
                };

            if isDebug
                index = 'index-debug.html';
                nonce = { 'snc=dev' };
                params( end  + 1 ) = nonce;
            else
                index = 'index.html';
            end
        end

    end
end

function debug = isDebug(  )
debug = slsvTestingHook( 'ScheduleEditorDebug' );
end

function valid = validSolverAndTaskingOptions( modelHandle )
if strcmp( get_param( modelHandle, 'SolverType' ), 'Fixed-step' )
    valid = strcmp( get_param( modelHandle, 'SolverMode' ), 'MultiTasking' ) ||  ...
        slfeature( 'PartitionsInSingleTaskingFixedStep' ) > 0;
else
    valid = slfeature( 'PartitionsInSingleTaskingVariableStep' ) > 0;
end
end

