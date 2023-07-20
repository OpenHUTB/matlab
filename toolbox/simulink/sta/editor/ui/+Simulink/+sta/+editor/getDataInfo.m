function[dataInfo]=getDataInfo(sigID)





    repoUtil=starepository.RepositoryUtility;

    dataTypeStr=repoUtil.getMetaDataByName(sigID,'DataType');

    if strcmpi(dataTypeStr,'logical')

        dataTypeStr='boolean';

    end

    isFixDT=repoUtil.getMetaDataByName(sigID,'isFixDT');

    if isempty(isFixDT)
        isFixDT=false;
        parentID=repoUtil.repo.getSignalParent(sigID);
        parentFixed=false;
        if~isempty(parentID)&&parentID~=0
            parentFixed=repoUtil.getMetaDataByName(parentID,'isFixDT');

            if isempty(parentFixed)
                parentFixed=false;
            end
        end

        isFixDT=isFixDT||parentFixed;
    end



    typeLineage=Simulink.sta.editor.getTypeLineage(sigID,{});

    IS_MULTIDIM=any(~cellfun(@isempty,strfind(typeLineage,'multidim')));
    IS_NDIM=any(~cellfun(@isempty,strfind(typeLineage,'ndim')));
    IS_DATA_ARRAY=any(~cellfun(@isempty,strfind(typeLineage,'dataarray')));
    IS_FUNCTIONCALL=any(~cellfun(@isempty,strfind(typeLineage,'functioncall')));
    IS_NON_SCALAR_TIMETABLE=any(~cellfun(@isempty,strfind(typeLineage,'non_scalar_sl_timetable')));


    if IS_MULTIDIM||...
        IS_NDIM||...
        IS_DATA_ARRAY||...
IS_NON_SCALAR_TIMETABLE
        signalType='dataarray';
    elseif IS_FUNCTIONCALL
        signalType='functioncall';
    else
        signalType='timeseries';
    end

    dataInfo.DataTypeStr=dataTypeStr;
    dataInfo.IS_FIXDT=isFixDT;
    dataInfo.SignalType=signalType;


end

