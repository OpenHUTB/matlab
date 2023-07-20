function jsonSaveValues=makeJsonSafe(dataValues)



    boolIsInf=false(1,length(dataValues));
    boolIsNaN=false(1,length(dataValues));
    boolIsComplex=false(1,length(dataValues));

    if isstring(dataValues)
        jsonSaveValues=dataValues.cellstr;
        return;
    end

    if isenum(dataValues)
        jsonSaveValues=dataValues.string.cellstr;
        return;
    end

    if all(strcmpi(class(dataValues),'int64'))||...
        all(strcmpi(class(dataValues),'uint64'))

        jsonSaveValues=num2cell(dataValues);

        if isreal(dataValues)
            jsonSaveValues=convertStringsToChars(string(jsonSaveValues));
            if~iscell(jsonSaveValues)
                jsonSaveValues={jsonSaveValues};
            end
        else

            for kCell=1:length(jsonSaveValues)
                jsonSaveValues{kCell}=datacreation.internal.stringifyComplexInt64(jsonSaveValues{kCell});
            end

        end
        return;
    end

    if all(strcmpi(class(dataValues),'half'))

        jsonSaveValues=num2cell(dataValues);

        if isreal(dataValues)
            jsonSaveValues=cellfun(@double,jsonSaveValues,'UniformOutput',false);


            infVal=cellfun(@isinf,jsonSaveValues,'UniformOutput',false);
            nanVal=cellfun(@isnan,jsonSaveValues,'UniformOutput',false);


            infValBool=cell2mat(infVal);

            if any(infValBool)

                idxInfs=find(infValBool==1);

                for k=1:length(idxInfs)
                    jsonSaveValues{idxInfs(k)}=convertStringsToChars(string(jsonSaveValues{idxInfs(k)}));
                end

            end

            nanValBool=cell2mat(nanVal);
            if any(nanValBool)

                idxNaNs=find(nanValBool==1);

                for k=1:length(idxNaNs)
                    jsonSaveValues{idxNaNs(k)}='NaN';
                end
            end

            if~iscell(jsonSaveValues)
                jsonSaveValues={jsonSaveValues};
            end
            return
        else

            for kCell=1:length(jsonSaveValues)
                jsonSaveValues{kCell}=convertStringsToChars(string(double(jsonSaveValues{kCell})));
            end

        end
        return;
    end




    if~isempty(dataValues)&&isa(dataValues(1),'embedded.fi')

        dataValues=double(dataValues);
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
            jsonSaveValues{idxInf(kInf)}=convertStringsToChars(string(jsonSaveValues{idxInf(kInf)}));
        end
    end


    if anyIsNaN
        idxNaN=find(boolIsNaN==1);


        for kNaN=1:length(idxNaN)
            jsonSaveValues{idxNaN(kNaN)}='NaN';
        end
    end


    if boolIsComplex



        if isinteger(jsonSaveValues{1})

            for kComplex=1:length(jsonSaveValues)
                jsonSaveValues{kComplex}=sprintf('%s',convertStringsToChars(string(double(jsonSaveValues{kComplex}))));
            end
        else

            for kComplex=1:length(jsonSaveValues)

                if imag(jsonSaveValues{kComplex})==0

                    if real(jsonSaveValues{kComplex})==0
                        jsonSaveValues{kComplex}='0i';
                    else



                        jsonSaveValues{kComplex}=...
                        datacreation.internal.stringifyComplexInt64(dataValues(kComplex));
                    end


                else
                    jsonSaveValues{kComplex}=convertStringsToChars(string(jsonSaveValues{kComplex}));
                end

            end
        end
    else

        if~iscell(jsonSaveValues)
            jsonSaveValues={jsonSaveValues};
        end
        if any(islogical(dataValues))
            jsonSaveValues=convertStringsToChars(string(jsonSaveValues));
            jsonSaveValues=strrep(jsonSaveValues,'0',{'false'});
            jsonSaveValues=strrep(jsonSaveValues,'1',{'true'});

        end

    end
