


classdef PositiveBlockParameterConstraint<slci.compatibility.Constraint

    properties(Access=protected)
        fParameterName='';
        fSupportedValues={};
    end

    methods(Access=protected)

        function setParameterName(aObj,aParameterName)
            aObj.fParameterName=aParameterName;
        end

        function out=getSupportedValues(aObj)
            out=aObj.fSupportedValues;
        end

        function addSupportedValue(aObj,aSupportedValue)
            aObj.fSupportedValues{end+1}=aSupportedValue;
        end

        function setSupportedValues(aObj,aSupportedValues)
            for i=1:numel(aSupportedValues)
                aObj.addSupportedValue(aSupportedValues{i});
            end
        end

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'UnsupportedBlockParameterValuePos',...
            aObj.ParentBlock.getName(),aObj.getParameterName(),...
            aObj.getListOfStrings(aObj.getSupportedValues,false));
        end


        function blockType=getBlockType(~,parentBlock)
            blockClass=class(parentBlock);
            blockType=regexprep(blockClass,'slci.compatibility.(\w+)Block','$1');
            try
                blockType=slci.compatibility.BlocktypeToName(blockType);
            catch
                switch lower(blockType)
                case 'lookup_n_d'
                    blockType='Lookup Table';
                case 's_function'
                    blockType='S-Function';
                otherwise

                end
            end
        end

    end

    methods

        function out=getID(aObj)
            out=aObj.getParameterName;
        end

        function out=getParameterName(aObj)
            out=aObj.fParameterName;
        end

        function obj=PositiveBlockParameterConstraint(aFatal,aParameterName,varargin)
            obj.setFatal(aFatal);
            obj.setParameterName(aParameterName);
            for i=1:nargin-2
                obj.addSupportedValue(varargin{i});
            end
            obj.setCompileNeeded(0);
            obj.setEnum('PositiveBlockParameter');
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            Information=DAStudio.message('Slci:compatibility:PositiveBlockParameterConstraintInfo',aObj.getParameterName());
            SubTitle=DAStudio.message('Slci:compatibility:PositiveBlockParameterConstraintSubTitle',...
            aObj.getParameterName(),aObj.getBlockType(aObj.ParentBlock()));
            recActionStr=aObj.getListOfStrings(aObj.getSupportedValues,true);
            if isempty(recActionStr)
                recActionStr='''''';
            end
            RecAction=DAStudio.message('Slci:compatibility:PositiveBlockParameterConstraintRecAction',aObj.getParameterName(),recActionStr);
            StatusText=DAStudio.message(['Slci:compatibility:PositiveBlockParameterConstraint',status],aObj.getParameterName());
        end

        function out=check(aObj)
            out=[];
            parameterName=aObj.getParameterName();
            parameterValue=aObj.ParentBlock().getParam(parameterName);
            supportedValues=aObj.getSupportedValues();
            if(iscell(parameterValue))
                isCompatible=true;
                for idx=1:numel(parameterValue)
                    if~any(strcmpi(parameterValue{idx},supportedValues))
                        isCompatible=false;
                        break;
                    end
                end
                if~isCompatible
                    out=aObj.getIncompatibility();
                end
            else
                for idx=1:numel(supportedValues)
                    if strcmpi(parameterValue,supportedValues{idx})
                        return
                    end
                end
                out=aObj.getIncompatibility();
            end
        end

    end
end
