

classdef DiscreteIntegratorInportDataTypesConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'DiscreteIntegratorInPortDataTypes',...
            aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=DiscreteIntegratorInportDataTypesConstraint()
            obj.setEnum('DiscreteIntegratorInportDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            hasReset=aObj.ParentBlock().getParam('ExternalReset');
            hasExternalIC=aObj.ParentBlock().getParam('InitialConditionSource');

            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if isempty(compiledPortDataTypes)
                numIn=0;
            else
                numIn=numel(compiledPortDataTypes.Inport);
            end
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            if numIn==numel(portHandles.Inport)
                for i=1:numIn
                    inDataType=compiledPortDataTypes.Inport{i};

                    if((i~=2)&&...
                        ~(strcmpi('single',inDataType)||...
                        strcmpi('double',inDataType)))
                        out=aObj.getIncompatibility();
                    elseif(i==2)

                        if(~strcmpi(hasReset,'none')&&...
                            ~strcmpi('boolean',inDataType))




                            continue;

                        elseif(strcmpi(hasExternalIC,'external')&&...
                            ~(strcmpi('single',inDataType)||...
                            strcmpi('double',inDataType))&&...
                            (numIn==2))
                            out=aObj.getIncompatibility();
                        end
                    end
                end
            end
        end

        function errCode=getErrorCode(aObj)%#ok
            errCode='DiscreteIntegratorInportDataTypesConstraintRecAction';
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            [SubTitle,Information,StatusText,~]=getSpecificMAStrings@slci.compatibility.Constraint(aObj,status);
            RecAction=DAStudio.message(['Slci:compatibility:',aObj.getErrorCode()]);
        end

    end
end
