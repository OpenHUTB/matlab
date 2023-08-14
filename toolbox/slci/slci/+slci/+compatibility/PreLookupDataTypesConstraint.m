



classdef PreLookupDataTypesConstraint<slci.compatibility.SupportedDataTypesConstraint

    methods


        function out=getDescription(aObj)%#ok
            out='For a PreLookup block, the data inports, breakpoint data '+...
            'and fraction outport must be of a uniform floating-point '+...
            'data type (double, single)';
        end


        function obj=PreLookupDataTypesConstraint(aSupportedTypes)
            obj.setEnum('PreLookupDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.setSupportedTypes(aSupportedTypes);
        end


        function result=supportedType(aObj,dt,~)
            result=any(strcmp(dt,aObj.fSupportedTypes));
        end


        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');

            numIn=numel(compiledPortDataTypes.Inport);
            numOut=numel(compiledPortDataTypes.Outport);
            inputDataType=compiledPortDataTypes.Inport(1);




            if~aObj.supportedType(inputDataType)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
                return;
            end


            breakpointDataTypeStr=aObj.ParentBlock().getParam('BreakpointDataTypeStr');
            if numIn<2...
                &&~strcmpi(breakpointDataTypeStr,'Inherit: Same as input')...
                &&~strcmp(breakpointDataTypeStr,inputDataType)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
                return;
            end


            for i=2:numIn
                if~strcmpi(compiledPortDataTypes.Inport{i},inputDataType)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
            for i=2:numOut
                if~strcmpi(compiledPortDataTypes.Outport{i},inputDataType)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end

    end
end
