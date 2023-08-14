classdef EditedProperty


    enumeration
Description
Rationale
    end

    methods
        function out=toDataPropName(this)
            out=lower(char(this));
        end

        function out=toDasPropName(this)
            out=char(this);
        end
    end
end