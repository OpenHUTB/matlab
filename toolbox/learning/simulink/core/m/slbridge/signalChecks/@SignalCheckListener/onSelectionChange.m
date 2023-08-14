function onSelectionChange(this,~)




    if isempty(gcb)||~strcmp(get_param(gcb,'Selected'),'on')

        return
    end

    if contains(get_param(gcb,'ReferenceBlock'),'signalChecks')

        graderNumber=str2double(get_param(gcb,'task'));

        docked=SignalCheckUtils.findSignalDockedDialog();
        allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        for idx=1:numel(allStudios)
            if strcmp(get_param(allStudios(idx).App.blockDiagramHandle,'Name'),LearningApplication.getModelName)
                studio=allStudios(idx);
                break
            end
        end

        signalCheckComponent=studio.getComponent('GLUE2:DDG Component',learning.simulink.StudioMgr.ASSESS_PANE_ID);





        if isempty(docked)||signalCheckComponent.isVisible==0||this.openTask~=graderNumber
            learning.simulink.openDockedSignal(gcb);
            this.openTask=graderNumber;
        else
            docked.restoreFromSchema;
        end

    else



        plotAssessment=learning.assess.getAssessmentWithPlot();
        if isempty(plotAssessment)
            return;
        end

        referenceBlock=plotAssessment.ReferenceBlock;
        if isequal(referenceBlock,get_param(gcb,'ReferenceBlock'))
            showFigureWindow=false;
            plotAssessment.writePlotFigure(gcb,showFigureWindow);
            learning.simulink.refreshSignalWindows();
        end
    end

end
