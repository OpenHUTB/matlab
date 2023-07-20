

classdef SharedUtilitiesCodeStyleConstraint<slci.compatibility.Constraint

    methods

        function out=getFailingConfigurationParameter(aObj)
            out='Parentheses level'' and ''Casting modes';
        end


        function out=getDescription(aObj)%#ok
            out='Support empty ObjectivePriorities for shared utils inspection';
        end


        function obj=SharedUtilitiesCodeStyleConstraint()
            obj.setEnum('SharedUtilitiesCodeStyle');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];

            if~aObj.ParentModel.getInspectSharedUtils

                return;
            end

            mdlHdl=get_param(aObj.ParentModel().getHandle(),'Handle');


            vl=get_param(mdlHdl,'ParenthesesLevel');

            isSupported=strcmpi(vl,'Nominal');

            if isSupported

                cm=get_param(mdlHdl,'CastingMode');
                isSupported=strcmpi(cm,'Standards');
            end

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
                aObj.ParentModel().setParam('CastingMode','Standard');
                aObj.ParentModel().setParam('ParenthesesLevel','Nominal');
                out=true;
            catch
            end
        end
    end
end