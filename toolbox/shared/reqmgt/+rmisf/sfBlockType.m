function type=sfBlockType(obj)

    try
        slObj=get_param(obj,'Object');
        switch class(slObj)
        case 'Stateflow.EMChart'
            type=getString(message('Slvnv:rmi:resolveobj:EmbeddedMATLABBlock'));
        case 'Stateflow.TruthTableChart'
            type=getString(message('Slvnv:rmi:resolveobj:TruthTableBlock'));
        case 'Stateflow.ReactiveTestingTableChart'
            type=getString(message('Slvnv:rmi:resolveobj:TestSequence'));
        case 'Stateflow.StateTransitionTableChart'
            type=getString(message('Slvnv:rmi:resolveobj:StateTransitionTable'));
        case 'Simulink.SubSystem'
            if sfprivate('is_reactive_testing_table_chart_block',slObj.Handle)
                type=getString(message('Slvnv:rmi:resolveobj:TestSequence'));
            else
                type=legacySfBlockType(slObj);
            end
        otherwise
            type=getString(message('Slvnv:rmi:resolveobj:StateflowDiagram'));
        end
    catch ex %#ok<NASGU,CTCH>
        type='';
    end
end


function result=legacySfBlockType(myObj)

    try
        result=myObj.SFBlockType;
        switch result
        case 'Chart'
            result='Stateflow diagram';
        otherwise

        end
    catch ex %#ok<NASGU,CTCH>
        result='Stateflow diagram';
    end
end

