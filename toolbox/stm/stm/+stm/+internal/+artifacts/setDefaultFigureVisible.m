function prevState=setDefaultFigureVisible(state)

    prevState=[];
    if isstruct(state)

        set(groot,'Default',state);
    else

        prevState=get(groot,'Default');
        set(groot,'DefaultFigureVisible',state);
    end
end
