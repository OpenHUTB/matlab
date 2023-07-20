function passStatus=gradeGeneralAssessments(interactionAssessments,userModelName)
    passStatus=-ones(1,length(interactionAssessments));
    for i=1:length(interactionAssessments)
        passStatus(i)=interactionAssessments{i}.assess(userModelName);
        if interactionAssessments{i}.hasPlot


            modelStopFcn=get_param(userModelName,'StopFcn');
            stopFcn='learning.assess.stopFunction(gcs,gcb);';
            if~strcmp(modelStopFcn(end),';')
                modelStopFcn=[modelStopFcn,';'];
            end
            newStopFcn=[modelStopFcn,stopFcn];
            set_param(userModelName,'StopFcn',newStopFcn);

            selectedBlock=gcb;
            if~strcmp(get_param(gcb,'Selected'),'on')
                selectedBlock=[];
            end
            showFigureWindow=false;
            interactionAssessments{i}.writePlotFigure(selectedBlock,showFigureWindow);


            learning.assess.updateBlockEffects(interactionAssessments{i},passStatus(i));
        end
    end
end

