










classdef AppSlider<hgsetget

    properties(Access=public)
        Name='';
        Object=[];
        Units='';
        Min=1;
        Max=10;
        Value=5;
    end

    methods
        function obj=AppSlider(name)
            obj.Name=name;
        end
    end
end
