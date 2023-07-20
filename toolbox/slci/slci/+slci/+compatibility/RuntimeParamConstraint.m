


classdef RuntimeParamConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fParameterName=''
    end

    methods(Access=private)

        function out=getParameterName(aObj)
            out=aObj.fParameterName;
        end

        function setParameterName(aObj,aParameterName)
            aObj.fParameterName=aParameterName;
        end

    end

    methods

        function out=getDescription(aObj)
            out=['The parameter ',aObj.getParameterName(),' must not be'...
            ,'empty, non-finite, be complex, or have two or more dimensions'...
            ,'use range selection or variable indexing on the elements of a MATLAB structure'];
        end

        function obj=RuntimeParamConstraint(aParameterName)
            obj.setParameterName(aParameterName);
            obj.setEnum('RuntimeParam');
            obj.setCompileNeeded(1);
            obj.setFatal(0);
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            if nargin==3
                failureCode=varargin{2}.getCode;
            end
            id=strrep(class(aObj),'slci.compatibility.','');

            if status
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Pass']);
            else
                StatusText=DAStudio.message(['Slci:compatibility:',id,failureCode,'MAWarn']);
            end
            RecAction=DAStudio.message(['Slci:compatibility:',id,'RecAction']);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle']);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info']);
        end

        function out=check(aObj)
            out=[];
            parameterName=aObj.getParameterName();
            isMasked=strcmp(aObj.ParentBlock().getParam('Mask'),'on');

            if isMasked





                if~strcmp(aObj.ParentBlock().getParam('BlockType'),'SubSystem')
                    parameterValue=aObj.ParentBlock().getParam(parameterName);

                    parameterName='';
                    maskNames=aObj.ParentBlock().getParam('MaskNames');
                    for idx=1:numel(maskNames)
                        if strcmp(maskNames{idx},parameterValue)
                            parameterName=parameterValue;
                            break;
                        end
                    end
                end
                if isempty(parameterName)
                    return
                end
            end
            try




                [~,~,~,unsupported]=slci.internal.parseStructureParam(...
                aObj.ParentBlock().getParam(parameterName));
                if unsupported
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'NoStructRange',...
                    parameterName,...
                    aObj.ParentBlock().getName());

                    return;
                end
                parameterValue=slResolve(...
                aObj.ParentBlock().getParam(parameterName),...
                aObj.ParentBlock().getSID());
                if isempty(parameterValue)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'EmptyParameter',...
                    parameterName,...
                    aObj.ParentBlock().getName());
                elseif~isstruct(parameterValue)

                    if any(isinf(parameterValue(:)))||...
                        any(isnan(parameterValue(:)))
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'NonFiniteParameter',...
                        parameterName,...
                        aObj.ParentBlock().getName());
                    elseif~isreal(parameterValue)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'ComplexParameter',...
                        parameterName,...
                        aObj.ParentBlock().getName());
                    end
                end
            catch ME




                if~strcmp(ME.identifier,'Simulink:Data:SlResolveNotResolved')...
                    &&~strcmp(ME.identifier,'MATLAB:UndefinedFunction')
                    rethrow(ME);
                end
            end

        end

    end
end
