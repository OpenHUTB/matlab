










classdef AppStatistic<hgsetget

    properties(Access=public)
        Name='';
        Value=1.0;
        Expression='';
    end

    methods
        function obj=AppStatistic(name,expression)
            obj.Name=name;
            obj.Expression=expression;
        end
    end
end