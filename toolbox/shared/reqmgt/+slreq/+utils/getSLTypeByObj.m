function out=getSLTypeByObj(slObj)






    out='simulink-block';

    if isa(slObj,'Simulink.Block')
        if~isa(slObj,'Simulink.SubSystem')
            if isa(slObj,'Simulink.Assertion')
                out='simulink-assertion';
            else
                out='simulink-block';
            end
        else

            objH=slObj.Handle;
            if slprivate('is_stateflow_based_block',objH)
                switch slObj.SFBlockType
                case 'Test Sequence'
                    out='simulink-testseq';
                case 'Truth Table'
                    out='simulink-truthtable';
                case 'MATLAB Function'
                    out='simulink-eml';
                otherwise
                    out='simulink-chart';
                end
            elseif any(strcmp(slreq.data.Link.verification_mask_types,slObj.MaskType))
                out='simulink-assertion';
            elseif slObj.isLinked||slObj.isMasked
                if contains(slObj.getDisplayIcon,'BlockIcon.png')
                    out='simulink-block';
                else
                    out='simulink-subsystem';
                end
            elseif strcmp(slObj.SimulinkSubDomain,'ArchitectureAdapter')
                out='simulink-block';
            else
                out='simulink-subsystem';
            end
        end
    elseif isa(slObj,'Stateflow.Object')
        switch class(slObj)
        case 'Stateflow.State'
            chartType=slObj.chart;
            if isa(chartType,'Stateflow.ReactiveTestingTableChart')
                out='simulink-testseq';
            else
                out='simulink-state';
            end
        case 'Stateflow.Box'
            out='simulink-statebox';
        case 'Stateflow.Function'
            out='simulink-sfgraphfcn';
        case 'Stateflow.Transition'
            chartId=sfprivate('getChartOf',slObj.Id);
            if Stateflow.ReqTable.internal.isRequirementsTable(chartId)
                out='simulink-specblock';
            else
                out='simulink-transition';
            end
        case 'Stateflow.SLFunction'
            out='simulink-sfslfcn';
        case 'Stateflow.TruthTable'
            out='simulink-truthtable';
        case 'Stateflow.SimulinkBasedState'
            out='simulink-actionstate';
        case 'Stateflow.EMFunction'
            out='simulink-emlaction';
        case 'Stateflow.Annotation'
            if slObj.IsImage
                out='simulink-image';
            else
                out='simulink-annotation';
            end
        case 'Stateflow.ReactiveTestingTableChart'
            out='simulink-testseq';
        otherwise


            out='simulink-state';
        end
    elseif isa(slObj,'Simulink.BlockDiagram')
        out='simulink-model';
    elseif isa(slObj,'Simulink.Annotation')
        if strcmpi(slObj.IsImage,'on')
            out='simulink-image';
        elseif strcmpi(slObj.AnnotationType,'area_annotation')
            out='simulink-area-annotation';
        else
            out='simulink-annotation';
        end
    elseif isa(slObj,'Simulink.fault.Fault')
        out='faultanalyzer-fault';
    elseif isa(slObj,'Simulink.fault.Conditional')
        out='faultanalyzer-conditional';
    end
end
