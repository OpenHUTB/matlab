function harnessList = getHarnessList( systemMdl, listOption, ownerH, NV )
arguments
    systemMdl;
    listOption = 'all';
    ownerH = [  ];
    NV.HarnessName( 1, 1 )string = "";
end

try
    if ~strcmp( get_param( systemMdl, 'type' ), 'block_diagram' )

        DAStudio.error( 'Simulink:Commands:ArgMustBeBlockDiagram', 1 );
    end
catch ME
    ME.throwAsCaller(  );
end

if ~ismember( listOption, { 'all', 'active', 'deleted', 'loaded' } )
    DAStudio.error( 'Simulink:Harness:InvalidStatusForHarnessList' );
elseif ~strcmp( listOption, 'all' ) && ~isempty( ownerH )
    DAStudio.error( 'Simulink:Harness:InvalidOwnerForHarnessList' )
end

switch listOption
    case 'active'
        harnessList = Simulink.harness.internal.getActiveHarness( systemMdl );
    case 'deleted'
        harnessList = Simulink.harness.internal.getDeletedHarnesses( systemMdl );
    case 'loaded'
        harnessList = Simulink.harness.internal.getLoadedHarnesses( systemMdl );
    case 'all'
        if NV.HarnessName.strlength > 0
            harnessList = Simulink.harness.internal.getHarnessByName( systemMdl, NV.HarnessName );
        elseif isempty( ownerH )
            harnessList = Simulink.harness.internal.getAllHarnesses( systemMdl );
        else
            harnessType = Simulink.harness.internal.validateOwnerHandle( systemMdl, ownerH );
            switch harnessType
                case 'Simulink.BlockDiagram'
                    harnessList = Simulink.harness.internal.getBDHarnesses( systemMdl );
                case { 'Simulink.SubSystem' ...
                        , 'Simulink.SFunction' ...
                        , 'Simulink.MSFunction' ...
                        , 'Simulink.MATLABSystem' ...
                        , 'Simulink.FMU' ...
                        , 'Simulink.CCaller' ...
                        , 'Simulink.CFunction' ...
                        , 'Simulink.SimscapeBlock' ...
                        , 'Simulink.ModelReference' }
                    harnessList = Simulink.harness.internal.getBlockHarnesses( systemMdl, ownerH );
                otherwise
                    assert( false, 'unknown harnessType %s', harnessType );
            end
        end
    otherwise
        assert( false, 'unknown listOption %s', listOption );
end

if isstruct( harnessList ) && slfeature( 'RLSTestHarness' ) == 0
    harnessList = rmfield( harnessList, 'functionInterfaceName' );
end

end

