

classdef NegativeBlockParameterConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fParameterName='';
        fUnsupportedValues={};
    end

    methods(Access=protected)

        function setParameterName(aObj,aParameterName)
            aObj.fParameterName=aParameterName;
        end

        function out=getUnsupportedValues(aObj)
            out=aObj.fUnsupportedValues;
        end

        function addUnsupportedValue(aObj,aUnsupportedValue)
            aObj.fUnsupportedValues{end+1}=aUnsupportedValue;
        end

        function setUnsupportedValues(aObj,aUnsupportedValues)
            for i=1:numel(aUnsupportedValues)
                aObj.addUnsupportedValue(aUnsupportedValues{i});
            end
        end
    end

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'UnsupportedBlockParameterValueNeg',...
            aObj.ParentBlock.getName(),aObj.getParameterName(),...
            aObj.getListOfStrings(aObj.getUnsupportedValues,false));
        end

    end

    methods

        function out=getID(aObj)
            out=aObj.getParameterName;
        end

        function out=getParameterName(aObj)
            out=aObj.fParameterName;
        end

        function obj=NegativeBlockParameterConstraint(aFatal,aParameterName,varargin)
            obj.setFatal(aFatal);
            obj.setParameterName(aParameterName);
            for i=1:nargin-2
                obj.addUnsupportedValue(varargin{i});
            end
            obj.setCompileNeeded(0);
            obj.setEnum('NegativeBlockParameter');
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            Information=DAStudio.message('Slci:compatibility:NegativeBlockParameterConstraintInfo',aObj.getParameterName());
            SubTitle=DAStudio.message('Slci:compatibility:NegativeBlockParameterConstraintSubTitle',aObj.getParameterName(),strrep(class(aObj.ParentBlock),'slci.simulink.',''));
            RecAction=DAStudio.message('Slci:compatibility:NegativeBlockParameterConstraintRecAction',aObj.getParameterName(),aObj.getListOfStrings(aObj.getUnsupportedValues,true));
            StatusText=DAStudio.message(['Slci:compatibility:NegativeBlockParameterConstraint',status],aObj.getParameterName());
        end

        function out=check(aObj)
            out=[];
            parameterName=aObj.getParameterName();
            parameterValue=aObj.ParentBlock().getParam(parameterName);
            unsupportedValues=aObj.getUnsupportedValues();
            for idx=1:numel(unsupportedValues)
                if any(strcmpi(parameterValue,unsupportedValues{idx}))
                    out=aObj.getIncompatibility();
                    return
                end
            end
        end

    end
end
