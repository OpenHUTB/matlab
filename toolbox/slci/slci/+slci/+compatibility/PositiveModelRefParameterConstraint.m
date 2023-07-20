


classdef PositiveModelRefParameterConstraint<slci.compatibility.PositiveModelParameterConstraint

    methods
        function obj=PositiveModelRefParameterConstraint(aFatal,aParameterName,varargin)
            obj=obj@slci.compatibility.PositiveModelParameterConstraint(aFatal,aParameterName,varargin{:});
        end

        function out=check(aObj)
            out=[];
            if aObj.ParentModel().getCheckAsRefModel()
                out=check@slci.compatibility.PositiveModelParameterConstraint(aObj);
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if~aObj.ParentModel().getCheckAsRefModel()
                param=aObj.getParameterName;
                ui=DAStudio.message(['Slci:configsetMA:',param,'Prompt']);
                SubTitle=DAStudio.message('Slci:compatibility:SLCISubTitleStr',['''',ui,'''']);
                Information=DAStudio.message('Slci:compatibility:TopModelInlineParamsConstraintInfo');
                StatusText=DAStudio.message('Slci:compatibility:TopModelInlineParamsConstraintPass');
                RecAction='';
            else
                [SubTitle,Information,StatusText,RecAction]=...
                getSpecificMAStrings@slci.compatibility.PositiveModelParameterConstraint(aObj,status,varargin{:});
            end
        end

    end
end

