function refreshSignalWindows

    docked=SignalCheckUtils.findSignalDockedDialog();

    if~isempty(docked)

        etab=docked.getSource;
        blkHandle=etab.blkHandle;
        if isempty(blkHandle)&&isempty(etab.matlabPassStatus)

            return
        elseif isempty(blkHandle)

            if~isempty(etab.matlabPassStatus)
                newPassStatus=learning.simulink.Application.getInstance().getPassStatus();
                etab.matlabPassStatus=newPassStatus;
            end
            docked.restoreFromSchema();
        else

            block=[get_param(blkHandle,'Parent'),'/',get_param(blkHandle,'Name')];
            interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
            taskNum=LearningApplication.getCurrentTask();
            currentAssessments=interactionAssessments{taskNum};
            hasGeneralAssessments=~isstruct(currentAssessments);

            if hasGeneralAssessments
                modelName=learning.simulink.Application.getInstance().getModelName();
                newPassStatus=learning.assess.gradeGeneralAssessments(currentAssessments(2:end),modelName);
                etab.matlabPassStatus(2:end)=newPassStatus;
            elseif~isempty(etab.matlabPassStatus)
                newPassStatus=SignalCheckUtils.getRequirements(block);
                etab.matlabPassStatus=newPassStatus;
            end




            docked.restoreFromSchema();

            fh=findobj(0,'type','Figure','-regexp','tag',get_param(block,'Parent'));
            for idx=1:numel(fh)
                SignalCheckUtils.openSignalInPlotWindow(get(fh(idx),'tag'));
            end

        end

    end

end
