



classdef Component_Name<autosar.ui.app.base.OptionBase

    properties(Hidden,Constant)
        ID='Component_Name';
    end

    methods
        function obj=Component_Name(env)





            id=autosar.ui.app.option.Component_Name.ID;
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('RTW:autosar:autosarComponentNameStr');

            obj.Type='user_input';
            obj.Indent=1;
            obj.Value=autosar.ui.app.option.Component_Name.getDefaultComponentName(env.ModelHandle);
            obj.DepInfo=struct('Option','Component_MapToComponent','Value',true);
            obj.Answer=true;
        end

        function out=isEnabled(obj)
            if obj.Env.IsSubComponent

                out=false;
            else
                out=true;
            end
        end

        function ret=onNext(obj)




            ret=0;
            compName=obj.Value;
            modelH=obj.Env.ModelHandle;
            maxShortNameLength=get_param(modelH,'AutosarMaxShortNameLength');
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({compName},...
            'shortName',maxShortNameLength);
            if~isempty(idcheckmessage)
                ret=-1;
                errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            else
                obj.Env.ComponentName=compName;
            end
        end
    end

    methods(Static,Access=private)
        function componentName=getDefaultComponentName(modelH)

            componentName=get_param(modelH,'Name');
        end
    end
end


