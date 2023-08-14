function Name=findPortName(this,varargin)






    prop=properties(this);

    for i=1:length(prop)
        if isa(this.(prop{i}),class(eda.internal.component.(varargin{1})))
            Name=prop{i};
            return;
        end

    end

