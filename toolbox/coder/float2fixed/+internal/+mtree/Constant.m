




classdef Constant<handle
    properties
Name
Value
Description
    end

    methods
        function this=Constant(description,value,name)
            this.Description=description;
            this.Name=name;
            this.Value=value;
        end
    end

    methods(Static)


        function cout=CastDoubleToUnsingedInteger(cin)

            cout=cin;
            assert(isa(cin,'internal.mtree.Constant')&&isa(cin.Value,'double'),...
            'Input is not a internal.mtree.Constant double type');

            val=cin.Value;
            type=internal.mtree.Type.getIntToHold(val,size(val));
            cout.Value=type.castValueToType(val);
        end
    end
end
