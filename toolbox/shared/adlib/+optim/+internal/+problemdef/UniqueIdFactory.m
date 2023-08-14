classdef(Sealed)UniqueIdFactory<handle


















    properties(SetAccess=immutable)

        Name;
    end

    properties(SetAccess=private)

        NumIds=0;
    end

    methods

        function obj=UniqueIdFactory
            obj.Name="pdef"+replace(matlab.lang.internal.uuid(),"-","0");
        end


        function id=nextId(obj)
            obj.NumIds=obj.NumIds+1;


            id=obj.Name+"_"+obj.NumIds;
        end
    end
end
