

classdef ProductBlockNegativeParameterConstraint<slci.compatibility.NegativeBlockParameterConstraint

    methods(Access=protected)

        function out=getUnsupportedValues(aObj)
            out=getUnsupportedValues@slci.compatibility.NegativeBlockParameterConstraint(aObj);
        end

        function setUnsupportedValues(aObj,aUnsupportedValues)
            setUnsupportedValues@slci.compatibility.NegativeBlockParameterConstraint(aObj,aUnsupportedValues);
        end
    end

    methods
        function out=getDescription(aObj)%#ok
            out=['Set the parameter inputs for the listed blocks to any value but * or / for Element-wise(.*) multiplication '...
            ,'with vector or matrix input signals. The * or / setting for the inputs is valid only for scalar input signals '...
            ,'during Element-wise(.*) multiplication.'];
        end

        function obj=ProductBlockNegativeParameterConstraint(aFatal,aParameterName)
            obj=obj@slci.compatibility.NegativeBlockParameterConstraint(aFatal,aParameterName);
            obj.setEnum('ProductBlockNegativeParameter');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];%#ok
            if(strcmpi(aObj.ParentBlock().getParam('Multiplication'),'Element-wise(.*)'))





                portHandles=aObj.ParentBlock().getParam('PortHandles');
                numinports=numel(portHandles.Inport);
                portWidths=aObj.ParentBlock().getParam('CompiledPortWidths');

                inportWidth=portWidths.Inport(1);

                if((numinports==1)&&(inportWidth>1))


                    aUnsupportedValues={'1','*','/'};
                else
                    aUnsupportedValues=[];
                end
            end


            setUnsupportedValues(aObj,aUnsupportedValues);

            out=check@slci.compatibility.NegativeBlockParameterConstraint(aObj);
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            Information=DAStudio.message('Slci:compatibility:ProductBlockNegativeParameterConstraintInfo',aObj.getParameterName());
            SubTitle=DAStudio.message('Slci:compatibility:ProductBlockNegativeParameterConstraintSubTitle',aObj.getParameterName(),strrep(class(aObj.ParentBlock),'slci.simulink.',''));

            UnsupportedValuesStr=aObj.getListOfStrings(aObj.getUnsupportedValues(),true);
            RecAction=DAStudio.message('Slci:compatibility:ProductBlockNegativeParameterConstraintRecAction',aObj.getParameterName(),...
            UnsupportedValuesStr,UnsupportedValuesStr);
            StatusText=DAStudio.message(['Slci:compatibility:ProductBlockNegativeParameterConstraint',status],aObj.getParameterName());
        end

    end
end
