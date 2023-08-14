

classdef DiscreteIntegratorUniformPortDataTypesConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'DiscreteIntegratorUniformPortDataTypes',...
            aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=DiscreteIntegratorUniformPortDataTypesConstraint()
            obj.setEnum('DiscreteIntegratorUniformPortDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            hasReset=~strcmpi(aObj.ParentBlock().getParam('ExternalReset'),'none');
            hasExternalIC=strcmpi(aObj.ParentBlock().getParam('InitialConditionSource'),'external');

            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if isempty(compiledPortDataTypes)
                numIn=0;
                numOut=0;
            else
                numIn=numel(compiledPortDataTypes.Inport);
                numOut=numel(compiledPortDataTypes.Outport);
            end

            if numIn>0
                signalDataType=compiledPortDataTypes.Inport(1);
            elseif numOut>0
                signalDataType=compiledPortDataTypes.Outport(1);
            end




            for i=1:numIn
                inDataType=compiledPortDataTypes.Inport{i};

                if((i~=2)&&...
                    ~strcmpi(signalDataType,inDataType))
                    out=aObj.getIncompatibility();
                    return;
                elseif(i==2)


                    if(~hasReset&&hasExternalIC&&...
                        ~strcmpi(signalDataType,inDataType))
                        out=aObj.getIncompatibility();
                        return;
                    end
                end
            end

            outDataType=compiledPortDataTypes.Outport{1};
            if~strcmpi(outDataType,signalDataType)
                out=aObj.getIncompatibility();
            end
        end

        function errCode=getErrorCode(aObj)%#ok
            errCode='DiscreteIntegratorUniformPortDataTypesConstraintRecAction';
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            [SubTitle,Information,StatusText,~]=getSpecificMAStrings@slci.compatibility.Constraint(aObj,status);%#ok
            RecAction=DAStudio.message(['Slci:compatibility:',aObj.getErrorCode()]);
        end

    end
end
