function componentInit(this)









    prop=properties(this);

    for i=1:length(prop)
        propName=prop{i};
        if isa(this.(propName),'eda.internal.component.Port')
            if isempty(this.(propName).UniqueName)
                this.(propName).UniqueName=propName;
            end
        end
    end

