



classdef Properties_Import<dds.internal.ui.app.base.OptionBase
    methods
        function obj=Properties_Import(env)





            id='Properties_Import';
            obj@dds.internal.ui.app.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardImportProperties');
            obj.Value='xml';
            obj.Answer=false;
        end

        function out=isEnabled(obj)
            out=true;
        end

        function ret=onNext(obj)
            ret=0;
        end

        function msg=getOptionMessage(obj)
            if(obj.Env.VendorSupportsIDLAndXML)
                obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardImportIDLXMLProperties');
            else
                obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardImportProperties');
            end
            msg=obj.OptionMessage;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                if(obj.Env.VendorSupportsIDLAndXML)
                    msg=DAStudio.message('dds:toolstrip:uiWizardImportIDLXMLPropertiesHelp');
                else
                    msg=DAStudio.message('dds:toolstrip:uiWizardImportPropertiesHelp');
                end
            else
                msg=obj.HintMessage;
            end
        end
    end
end


