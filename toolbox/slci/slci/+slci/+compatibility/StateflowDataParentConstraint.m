


classdef StateflowDataParentConstraint<slci.compatibility.Constraint


    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow data defined inside a state or box are not supported.';
        end

        function obj=StateflowDataParentConstraint
            obj.setEnum('StateflowDataParent');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            id=strrep(class(aObj),'slci.compatibility.','');

            if status
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Pass']);
            else
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Warn']);
            end
            RecAction=DAStudio.message(['Slci:compatibility:',id,'RecAction']);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle']);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info']);
        end


        function out=check(aObj)
            out=[];
            if isa(aObj.ParentData().getParent,'slci.stateflow.SFState')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowDataParent',...
                aObj.ParentBlock().getName());
            elseif isa(aObj.ParentData().getUDDObject().getParent(),'Stateflow.Box')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowDataParent',...
                aObj.ParentBlock().getName());
            end
        end

    end
end
