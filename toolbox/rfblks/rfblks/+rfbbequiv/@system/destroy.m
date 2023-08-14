function h=destroy(h,destroyData)





    models=get(h,'Models');
    nmodels=length(models);
    for i=1:nmodels
        model=models{i};
        if isa(model,'rfbbequiv.linear')
            delete(model)
        end
    end

    ckt=get(h,'OriginalCkt');
    if isa(ckt,'rfckt.cascade')
        delete(ckt)
    end
