



classdef PreLookupIndexDataTypeConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fIndexTypes={};
    end

    methods(Access=protected)


        function out=getIndexTypes(aObj)
            out=aObj.fIndexTypes;
        end


        function setIndexTypes(aObj,aIndexTypes)
            aObj.fIndexTypes=aIndexTypes;
        end

    end

    methods


        function out=getDescription(aObj)%#ok
            out='For a PreLookup block, the Index type must be of uint32.';
        end


        function obj=PreLookupIndexDataTypeConstraint(aIndexTypes)
            obj.setEnum('PreLookupIndexDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.setIndexTypes(aIndexTypes);
        end


        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');

            indexDataTypeOut=compiledPortDataTypes.Outport(1);


            if~any(strcmpi(indexDataTypeOut,aObj.getIndexTypes()))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
                return;
            end

        end

    end
end
