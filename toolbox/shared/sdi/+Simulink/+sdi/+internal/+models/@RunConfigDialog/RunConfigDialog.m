classdef RunConfigDialog<handle





    properties(Access='protected')

        engine;
    end


    methods(Access='public')

        function this=RunConfigDialog(sdie)
            this.engine=sdie;
        end

        function out=getDefaultRunNameTemplate(this)
            out=this.engine.getDefaultRunNameTemplate();
        end

        function out=getRunNameTemplate(this)
            out=this.engine.runNameTemplate;
        end

        function setRunNameTemplate(this,templateName)
            Simulink.sdi.setRunNameTemplate(templateName);
            this.engine.runNameTemplate=templateName;
        end

        function setAppendRunOrder(this,state)
            if islogical(state)
                Simulink.sdi.setAppendRunToTop(state);
                this.engine.showRunAtTop=state;
            end
        end

        function state=getAppendRunOrder(~)
            state=Simulink.sdi.getAppendRunToTop();
        end
    end
end