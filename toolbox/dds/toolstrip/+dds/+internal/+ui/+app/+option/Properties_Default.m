



classdef Properties_Default<dds.internal.ui.app.base.OptionBase
    methods
        function obj=Properties_Default(env)





            id='Properties_Default';
            obj@dds.internal.ui.app.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardDefaultDictProperties');
            obj.Value='xml';
            obj.Answer=false;
        end

        function out=isEnabled(obj)
            out=true;
        end

        function ret=onNext(obj)
            if obj.Answer
                obj.Env.start_spin();
                c=onCleanup(@()obj.Env.stop_spin());
                try
                    newDDName=[get_param(obj.Env.ModelHandle,'Name'),'.sldd'];
                    ddConn=dds.internal.simulink.Util.createFromDefaultDDSXml(newDDName);
                catch ex

                    ret=-1;
                    errordlg(ex.message,...
                    obj.Env.Gui.Title,'replace');
                    return
                end
                obj.Env.DDConn=ddConn;

                obj.Env.ImportProperties=false;
            end
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('dds:toolstrip:uiWizardDefaultDictPropertiesHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


