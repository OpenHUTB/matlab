function tsList=flatten(h)








    tsList={};

    if~ishandle(h)
        return;
    end


    dataElems=who(h);


    for i=1:length(dataElems)
        obj=eval(['h.',dataElems{i}]);
        if isa(obj,'Simulink.TsArray')
            if~isempty(tsList)
                tmpList=flatten(obj);
                tsList={tsList{:},tmpList{:}};
            else
                tsList=flatten(obj);
            end
        elseif isa(obj,'Simulink.Timeseries')
            tsList{end+1}=obj;
        end
    end

    return;