classdef Adder<handle

    properties
        Application
    end


    methods(Hidden)
        function name=getUniqueName(this,name)
            specs=getCurrentSpecifications(this);
            if isempty(specs)
                return;
            end

            rawName=name;

            rawName(regexp(rawName,'(\d+)$'):end)=[];
            indx=1;
            allNames={specs.Name};
            while any(strcmp(allNames,name))
                name=sprintf('%s%d',rawName,indx);
                indx=indx+1;
            end

        end
    end

    methods(Access=protected,Abstract)
        specs=getCurrentSpecifications(this)
    end
end


