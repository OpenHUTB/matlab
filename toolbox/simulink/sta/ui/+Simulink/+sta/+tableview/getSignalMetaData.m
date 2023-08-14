function msg=getSignalMetaData(signalID,rootSignalID)



    repoUtil=starepository.RepositoryUtility;

    dataTypeStr=repoUtil.getMetaDataByName(signalID,'DataType');

    if strcmpi(dataTypeStr,'logical')

        dataTypeStr='boolean';

    end

    isFixDT=repoUtil.getMetaDataByName(signalID,'isFixDT');

    if isempty(isFixDT)
        isFixDT=false;
        parentID=repoUtil.repo.getSignalParent(signalID);
        parentFixed=false;
        if~isempty(parentID)&&parentID~=0
            parentFixed=repoUtil.getMetaDataByName(parentID,'isFixDT');

            if isempty(parentFixed)
                parentFixed=false;
            end
        end

        isFixDT=isFixDT||parentFixed;
    end



    typeLineage=Simulink.sta.editor.getTypeLineage(signalID,{});

    IS_MULTIDIM=any(~cellfun(@isempty,strfind(typeLineage,'multidim')));
    IS_NDIM=any(~cellfun(@isempty,strfind(typeLineage,'ndim')));
    IS_DATA_ARRAY=any(~cellfun(@isempty,strfind(typeLineage,'dataarray')));
    IS_FUNCTIONCALL=any(~cellfun(@isempty,strfind(typeLineage,'functioncall')));
    IS_NON_SCALAR_TIMETABLE=any(~cellfun(@isempty,strfind(typeLineage,'non_scalar_sl_timetable')));

    childIDsInOrder=[];

    if IS_MULTIDIM
        signalType='nonscalar';
        isscalar_value=false;

        childIDsInOrder=getChildrenIDsInSiblingOrder(repoUtil,rootSignalID);
        dataColumnHeaders=cell(1,length(childIDsInOrder));

        for kHeader=1:length(dataColumnHeaders)
            strLabel=repoUtil.getSignalLabel(childIDsInOrder(kHeader));

            dataColumnHeaders{kHeader}=[DAStudio.message('sl_web_widgets:tableview:Data'),strLabel(strfind(strLabel,'('):end)];
        end
    elseif IS_DATA_ARRAY
        signalType='dataarray';
        isscalar_value=false;

        childIDsInOrder=getChildrenIDsInSiblingOrder(repoUtil,rootSignalID);
        dataColumnHeaders=cell(1,length(childIDsInOrder));

        for kHeader=1:length(dataColumnHeaders)
            strLabel=repoUtil.getSignalLabel(childIDsInOrder(kHeader));

            dataColumnHeaders{kHeader}=[DAStudio.message('sl_web_widgets:tableview:Data'),'(:,',num2str(kHeader+1),')'];
        end
    elseif IS_NDIM||IS_NON_SCALAR_TIMETABLE
        signalType='nonscalar';
        isscalar_value=false;

        childIDsInOrder=getChildrenIds(repoUtil,rootSignalID);

        dataColumnHeaders=cell(1,length(childIDsInOrder));

        for kHeader=1:length(dataColumnHeaders)
            dataColumnHeaders{kHeader}=[DAStudio.message('sl_web_widgets:tableview:Data'),repoUtil.getMetaDataByName(...
            childIDsInOrder(kHeader),'NDimIdxStr')];
        end

    elseif IS_FUNCTIONCALL
        signalType='functioncall';
        isscalar_value=false;

        childIDsInOrder=getChildrenIDsInSiblingOrder(repoUtil,signalID);
        dataColumnHeaders={DAStudio.message('sl_web_widgets:tableview:FunctionCallData')};
    else
        signalType='timeseries';
        isscalar_value=false;

        childIDsInOrder=getChildrenIDsInSiblingOrder(repoUtil,signalID);
        dataColumnHeaders={DAStudio.message('sl_web_widgets:tableview:Data')};
    end





    root_ComplexStr=getMetaDataByName(repoUtil,rootSignalID,'SignalType');
    plotted_ComplexStr=getMetaDataByName(repoUtil,signalID,'SignalType');



    msg.signalID=signalID;
    msg.rootSignalID=rootSignalID;
    msg.isscalar=isscalar_value;
    msg.IS_FIXDT=isFixDT;
    msg.SignalType=signalType;
    msg.complexity=root_ComplexStr;
    msg.numdatacolumns=length(childIDsInOrder);
    msg.DataTypeStr=dataTypeStr;
    msg.datacolumnheaders=dataColumnHeaders;

    if msg.numdatacolumns==0
        msg.numdatacolumns=1;
    end
