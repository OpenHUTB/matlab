function bool=isSLTimeTable(aVar)




    if nargin>0
        aVar=convertStringsToChars(aVar);
    end

    bool=false;

    IS_TT=isa(aVar,'timetable');

    if~IS_TT
        return;
    end

    timeVarName=aVar.Properties.DimensionNames{1};
    timeVar=aVar.(timeVarName);

    varNames=aVar.Properties.VariableNames;

    if IS_TT&&length(varNames)==1&&isduration(timeVar)

        dataVar=aVar.(1);

        IS_TIME_INCREASING=~any(diff(double(seconds(timeVar)))<0);
        IS_DATA_NUMERIC_OR_LOGICAL=isnumeric(dataVar)||...
        islogical(dataVar);
        IS_STRING=isSLString(dataVar);

        IS_TIME_FINITE=all(isfinite(double(seconds(timeVar))));

        if IS_TIME_INCREASING&&(IS_DATA_NUMERIC_OR_LOGICAL||IS_STRING)&&IS_TIME_FINITE
            bool=true;
        end

        isFi_WordLength_GT_128=~isSimulinkFi(dataVar);
        if isfi(dataVar)&&isFi_WordLength_GT_128
            bool=false;
        end


        if isenum(varNames{1})&&~isStaSLEnumType(varNames{1})
            bool=false;
        end

        tssize=size(dataVar);
        dataDim=tssize(2:end);



        if prod(dataDim)>SlIOFormatUtil.SDI_REPO_CHANNEL_UPPER_LIMIT
            bool=false;
        end

    end
