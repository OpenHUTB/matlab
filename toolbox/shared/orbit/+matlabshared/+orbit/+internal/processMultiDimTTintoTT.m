function ttOut=processMultiDimTTintoTT(ttObj,dim)






%#codegen

    timeLength=height(ttObj);
    columnNames=ttObj.Properties.VariableNames;
    numColumns=numel(columnNames);
    for idx=1:numColumns
        data{idx}=ttObj.(columnNames{idx});
        dataSize=size(data{idx});

        if~all(ismember([timeLength,dim],dataSize))
            error(message(...
            'shared_orbit:orbitPropagator:SatelliteScenarioInvalidTTDimensions',...
            dim));
        end

        if ismatrix(data{idx})

            data{idx}={squeeze(data{idx})};

        else
            numSats=dataSize(dataSize~=timeLength&dataSize~=dim);

            if isempty(numSats)

                numSats=dim;
                data{idx}=permute(data{idx},...
                [find(dataSize==timeLength),...
                flip(find(dataSize==dim))]);
                warning(message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioAmbiguousTTDimensions',dim));
            else

                data{idx}=permute(data{idx},...
                [find(dataSize==timeLength),...
                find(dataSize==dim),...
                find(dataSize==numSats)]);
            end


            dataLoc=squeeze(num2cell(data{idx},2));


            data{idx}=arrayfun(@(x)vertcat(dataLoc{:,x}),1:numSats,'Uniform',false);
        end
    end


    data=[data{:}];
    ttOut=timetable(ttObj.Properties.RowTimes,data{:});
end
