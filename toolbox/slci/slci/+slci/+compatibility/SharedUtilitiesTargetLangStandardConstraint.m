

classdef SharedUtilitiesTargetLangStandardConstraint<slci.compatibility.Constraint

    methods

        function out=getFailingConfigurationParameter(aObj)
            out='Language standard';
        end


        function out=getDescription(aObj)%#ok
            out='Support TargetLangStandard C89/C90 (ANSI) and C99 (ISO) for shared utils inspection';
        end


        function obj=SharedUtilitiesTargetLangStandardConstraint()
            obj.setEnum('SharedUtilitiesTargetLangStandard');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];

            if~aObj.ParentModel.getInspectSharedUtils

                return;
            end

            mdlHdl=get_param(aObj.ParentModel().getHandle(),'Handle');

            tls=get_param(mdlHdl,'TargetLangStandard');
            supportedValue={'C89/C90 (ANSI)','C99 (ISO)'};

            isSupported=strcmpi(tls,supportedValue);

            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end



        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            try
                aObj.ParentModel().setParam('TargetLangStandard','C89/C90 (ANSI)');
                out=true;
            catch
            end
        end
    end
end