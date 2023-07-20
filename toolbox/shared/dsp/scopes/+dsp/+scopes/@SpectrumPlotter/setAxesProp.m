function setAxesProp(this,propName,propValue)



    for idx=1:length(this.Axes)
        set(this.Axes(idx),propName,propValue);
    end
end
