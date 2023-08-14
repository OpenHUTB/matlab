function[tsArray,numSats]=processMultiDimTSintoCellArrayOfTS(tsObj,dim)





%#codegen

    timeLength=tsObj.Length;
    tsSize=size(tsObj.Data);

    if ismatrix(tsObj.Data)
        validateDimensions(timeLength,dim,size(tsObj.Data));
        numSats=1;

        tsObj.Data=permute(tsObj.Data,...
        [find(tsSize==timeLength),...
        find(tsSize==dim)]);

        tsArray={tsObj};

    else
        validateDimensions(timeLength,dim,tsSize);
        numSats=tsSize(tsSize~=timeLength&tsSize~=dim);

        if isempty(numSats)

            numSats=dim;
            tsObjData=permute(tsObj.Data,...
            [find(tsSize==timeLength),...
            flip(find(tsSize==dim))]);
            warning(message(...
            'shared_orbit:orbitPropagator:SatelliteScenarioAmbiguousTSDimensions',dim));
        else

            tsObj.IsTimeFirst=false;
            tsObjData=permute(tsObj.Data,...
            [find(tsSize==timeLength),...
            find(tsSize==dim),...
            find(tsSize==numSats)]);
        end



        tsArray=cell(numSats,1);
        for idx=1:numSats


            tsArray{idx}=timeseries(tsObj);

            tsArray{idx}.TimeInfo=tsObj.TimeInfo;

            tsArray{idx}.Data=squeeze(tsObjData(:,:,idx));
        end
    end
end

function validateDimensions(timeLength,expectedDataLength,inputSize)
    if~all(ismember([timeLength,expectedDataLength],inputSize))
        error(message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidTSDimensions',...
        expectedDataLength));
    end
end
