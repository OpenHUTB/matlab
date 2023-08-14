



function[cvResults,isValidCvResults]=filenamesToCvDataArray(filenames,topmodels)

    import stm.internal.Coverage;
    cvResults=cvdata.empty(0,length(filenames));
    isValidCvResults=false(0,length(filenames));
    for x=1:length(filenames)
        try
            if~isempty(topmodels)
                if shouldLoad(topmodels{x})
                    load_system(topmodels{x});
                end
            end

            cvResults(x)=Coverage.loadCovObjects(filenames{x});
            isValidCvResults(x)=true;
        catch me
            stm.internal.util.warning(me.identifier,me.message);
            isValidCvResults(x)=false;
            continue;
        end

        try

            models=Coverage.getOwnerModel(cvResults(end).modelinfo);
            for y=1:length(models)
                if shouldLoad(models{y})
                    load_system(models{y});
                end
            end
        catch me
            stm.internal.util.warning(me.identifier,me.message);
        end
    end
end

function bool=shouldLoad(model)
    bool=stm.internal.Coverage.isModel(model)&&isvarname(model);
end
