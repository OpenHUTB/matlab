

classdef SymbolData<handle



    properties
Name
InitialValue
Scope
Port
Origin
    end

    methods
        function obj=SymbolData(Name)


            if nargin>0


                obj.Name=Name;
            end
        end
    end
end

