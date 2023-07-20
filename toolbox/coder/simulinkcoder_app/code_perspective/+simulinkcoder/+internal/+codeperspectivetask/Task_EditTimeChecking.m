classdef Task_EditTimeChecking<simulinkcoder.internal.codeperspectivetask.BaseTask




    properties(Constant)
        ID='EditTimeChecking'
    end

    methods
        function result=turnOn(obj,input,~)
            src=simulinkcoder.internal.util.getSource(input);
            obj.refresh(src.studio);
            result=true;
        end

        function turnOff(obj,input)
            src=simulinkcoder.internal.util.getSource(input);

            h=src.editor.blockDiagramHandle;
            mdl=get_param(h,'Name');

            maflag=edittime.getAdvisorChecking(h);
            if strcmp(maflag,'on')
                editEngine=edittimecheck.EditTimeEngine.getInstance();
                editEngine.loadDefaultConfiguration(mdl);
                editEngine.enableMA(mdl);
            end
        end

        function refresh(obj,studio)
            h=studio.App.getActiveEditor.blockDiagramHandle;
            mdl=get_param(h,'Name');

            maflag=edittime.getAdvisorChecking(h);
            if strcmp(maflag,'on')
                editEngine=edittimecheck.EditTimeEngine.getInstance();
                editEngine.switchConfiguration(mdl,edittimecheck.config.Type.CODE_GENERATION);
            end
        end
    end
end



