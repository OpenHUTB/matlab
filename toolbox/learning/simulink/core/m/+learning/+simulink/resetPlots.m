



function resetPlots(mdl)



    grader_list=find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'RegExp','on','ReferenceBlock','signalChecks');

    for idx=1:length(grader_list)

        graderType=SignalCheckUtils.getGraderType(grader_list{idx});

        toFileBlock=[grader_list{idx},'/To File'];
        if getSimulinkBlockHandle(toFileBlock)~=-1
            logFileName=get_param(toFileBlock,'Filename');
            if exist(logFileName,'file')==2
                delete(logFileName);
            end
        end

        switch graderType
        case 'signal'
            SignalAssessment.writeCurrentPlot(grader_list{idx});
        case 'mlsignal'
            SignalMATLABCheck.writeCurrentPlot(grader_list{idx});
        otherwise
            assert(ismember(graderType,{'signal','mlsignal','mlmodel','sfmodel'}));
        end

    end

end
