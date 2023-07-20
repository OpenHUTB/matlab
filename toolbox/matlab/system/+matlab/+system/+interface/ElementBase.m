classdef(Abstract)ElementBase<matlab.mixin.Heterogeneous



%#codegen



    properties(Access=protected)
        Name string{mustBeNonempty}="default"
    end

    methods
        function obj=ElementBase(name)
            coder.allowpcode('plain');

            obj.Name=string(name);
        end
    end
end