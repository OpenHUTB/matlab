function jsonSaveValues=makeJsonSafe(dataValues)


    if isstring(dataValues)

        boolIsInf=false(1,length(dataValues));
        boolIsNaN=false(1,length(dataValues));
        boolIsComplex=false(1,length(dataValues));

        jsonSaveValues=dataValues.cellstr;
        return;
    end


    boolIsInf=isinf(dataValues);
    boolIsNaN=isnan(dataValues);
    boolIsComplex=~isreal(dataValues);


    anyIsInf=any(boolIsInf);
    anyIsNaN=any(boolIsNaN);

    jsonSaveValues=num2cell(dataValues);


    if anyIsInf
        idxInf=find(boolIsInf==1);


        for kInf=1:length(idxInf)
            jsonSaveValues{idxInf(kInf)}=num2str(jsonSaveValues{idxInf(kInf)});
        end
    end


    if anyIsNaN
        idxNaN=find(boolIsNaN==1);


        for kNaN=1:length(idxNaN)
            jsonSaveValues{idxNaN(kNaN)}=num2str(jsonSaveValues{idxNaN(kNaN)});
        end
    end


    if boolIsComplex



        if isinteger(jsonSaveValues{1})

            for kComplex=1:length(jsonSaveValues)
                jsonSaveValues{kComplex}=sprintf('%s',num2str(double(jsonSaveValues{kComplex})));
            end
        else

            for kComplex=1:length(jsonSaveValues)
                jsonSaveValues{kComplex}=num2str(jsonSaveValues{kComplex});
            end
        end


    end