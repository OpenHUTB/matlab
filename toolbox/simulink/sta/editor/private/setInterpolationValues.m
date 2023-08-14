
function dsEl=setInterpolationValues(dsEl)




    if isa(dsEl,'timeseries')


        if isenum(dsEl.Data)||islogical(dsEl.Data)


            dsEl.DataInfo.Interpolation=tsdata.interpolation('zoh');

        else

            dsEl.DataInfo.Interpolation=tsdata.interpolation('linear');
        end

    elseif isstruct(dsEl)


        numEl=numel(dsEl);


        for kEl=1:numEl

            leafNames=fieldnames(dsEl(kEl));


            if~isempty(leafNames)


                for kField=1:length(leafNames)
                    dsEl(kEl).(leafNames{kField})=setInterpolationValues(dsEl(kEl).(leafNames{kField}));
                end
            end
        end

    end
