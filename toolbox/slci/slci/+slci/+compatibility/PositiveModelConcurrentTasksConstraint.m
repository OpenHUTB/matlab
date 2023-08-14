

classdef PositiveModelConcurrentTasksConstraint<slci.compatibility.PositiveModelParameterConstraint
    methods
        function aObj=PositiveModelConcurrentTasksConstraint(aFatal,aParameterName,varargin)
            aObj=aObj@slci.compatibility.PositiveModelParameterConstraint(aFatal,aParameterName,varargin{:});
        end

        function out=check(aObj)
            out=[];
            EnableConcurrentExecution=aObj.ParentModel().getParam('EnableConcurrentExecution');

            if strcmpi(EnableConcurrentExecution,'on')
                out=check@slci.compatibility.PositiveModelParameterConstraint(aObj);
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            EnableConcurrentExecution=aObj.ParentModel().getParam('EnableConcurrentExecution');

            if strcmpi(EnableConcurrentExecution,'off')
                param=aObj.getParameterName;
                ui=DAStudio.message(['Slci:configsetMA:',param,'Prompt']);
                SubTitle=DAStudio.message('Slci:compatibility:SLCISubTitleStr',['''',ui,'''']);
                Information=DAStudio.message('Slci:compatibility:ConcurrentTasksConstraintInfo');
                StatusText=DAStudio.message('Slci:compatibility:ConcurrentTasksConstraintPass');
                RecAction='';
            else
                [SubTitle,Information,StatusText,RecAction]=...
                getSpecificMAStrings@slci.compatibility.PositiveModelParameterConstraint(aObj,status,varargin{:});
            end
        end
    end
end