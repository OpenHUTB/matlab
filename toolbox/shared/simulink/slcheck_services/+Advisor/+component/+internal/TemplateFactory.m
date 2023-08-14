classdef TemplateFactory
    methods(Static)
        function template=createTemplate(component)

            templateID=Advisor.component.internal.TemplateFactory.getTemplateID(component);

            [templateFile,bdName]=...
            Advisor.component.internal.TemplateFactory.getFile(component);

            if component.Type==Advisor.component.Types.Model||...
                component.Type==Advisor.component.Types.ProtectedModel
                templateType=component.Type;
            else
                templateType=Advisor.component.Types.LibraryBlock;
            end

            template=Advisor.component.Template();
            template.ID=templateID;
            template.File=templateFile;
            template.Type=templateType;
            template.Name=template.ID;
            template.ParentName=bdName;
        end

        function templateID=getTemplateID(component)
            if component.Type==Advisor.component.Types.Model||...
                component.Type==Advisor.component.Types.ProtectedModel
                templateID=component.ID;
            else
                assert(~isempty(component.ReferenceBlock),'Expecting library Template');
                templateID=component.ReferenceBlock;
            end
        end
    end

    methods(Static,Access=private)
        function[file,bdName]=getFile(component)
            if component.Type==Advisor.component.Types.Model||...
                component.Type==Advisor.component.Types.ProtectedModel

                bdName=component.ID;
            else
                bdName=strtok(component.ReferenceBlock,'/');
                assert(~isempty(bdName),'Do not call for none templated components');
            end

            if~component.Type==Advisor.component.Types.ProtectedModel&&...
                bdIsLoaded(bdName)
                file=get_param(bdName,'FileName');
            else
                file=Simulink.loadsave.resolveFile(bdName);
            end
        end
    end
end