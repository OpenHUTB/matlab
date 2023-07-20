function ec_symbol_db_reg(dataObjectUsage,modelName)






    mpt_symbol_mapping_list=rtwprivate('rtwattic','AtticData','mpt_symbol_mapping_list');

    if isempty(mpt_symbol_mapping_list)==1
        index=1;
    else
        index=length(mpt_symbol_mapping_list)+1;
    end

    packageList={};
    symbolList={};
    for i=1:length(dataObjectUsage.DataObject)
        name=dataObjectUsage.DataObject(i).Name;
        hPort=dataObjectUsage.DataObject(i).PortHandle;
        hBlock=dataObjectUsage.DataObject(i).BlockHandle;
        identifier=dataObjectUsage.DataObject(i).Identifier;

        assert((hPort==0.0)||(hBlock==0.0));

        obj=[];
        cgModel=get_param(modelName,'CGModel');

        if dataObjectUsage.DataObject(i).IsDefaultMapped

            obj=cgModel.getDataObjectForElement(identifier);
        else
            obj=dataObjectUsage.DataObject(i).Object;
        end

        if isa(obj,'Simulink.Data')||isa(obj,'Simulink.LookupTable')||isa(obj,'Simulink.Breakpoint')
            packageList{end+1}=obj.CoderInfo.CSCPackageName;
        end
    end


    if isempty(packageList)
        mapping.packageList=packageList;
        mapping.symbolList=symbolList;
        rtwprivate('rtwattic','AtticData','mpt_symbol_mapping',mapping);

        return;
    end


    symbolList{1}='Definitions';
    symbolList{2}='Declarations';
    symbolList{3}='Defines';
    for i=1:length(mpt_symbol_mapping_list)
        packageList{end+1}=mpt_symbol_mapping_list{i}.packageName;
        symbolList{end+1}=mpt_symbol_mapping_list{i}.globalDefSym;
        symbolList{end+1}=mpt_symbol_mapping_list{i}.globalDecSym;
        symbolList{end+1}=mpt_symbol_mapping_list{i}.fileScopeSym;
    end

    packageList=unique(packageList);

    mapping.packageList=packageList;
    memSInfo.name=[];
    memSInfo.globalDefSym='GlobalVariableScalar';
    memSInfo.globalDecSym='ExternalVariableScalar';
    memSInfo.fileScopeSym='FilescopeVariableScalar';

    memPInfo.name=[];
    memPInfo.globalDefSym='GlobalCalibrationScalar';
    memPInfo.globalDecSym='ExternalCalibrationScalar';
    memPInfo.fileScopeSym='FilescopeCalibrationScalar';

    symbolList{end+1}=memSInfo.globalDefSym;
    symbolList{end+1}=memSInfo.globalDecSym;
    symbolList{end+1}=memSInfo.fileScopeSym;
    symbolList{end+1}=memPInfo.globalDefSym;
    symbolList{end+1}=memPInfo.globalDecSym;
    symbolList{end+1}=memPInfo.fileScopeSym;
    symbolList{end+1}='Define';
    symbolList=unique(symbolList);
    index=strcmp(symbolList,memSInfo.globalDefSym);
    memSInfo.globalDefSymIndex=find(index,1);
    index=strcmp(symbolList,memSInfo.globalDecSym);
    memSInfo.globalDecSymIndex=find(index,1);
    index=strcmp(symbolList,memSInfo.fileScopeSym);
    memSInfo.fileScopeSymIndex=find(index,1);

    index=strcmp(symbolList,memPInfo.globalDefSym);
    memPInfo.globalDefSymIndex=find(index,1);
    index=strcmp(symbolList,memPInfo.globalDecSym);
    memPInfo.globalDecSymIndex=find(index,1);
    index=strcmp(symbolList,memPInfo.fileScopeSym);
    memPInfo.fileScopeSymIndex=find(index,1);

    index=1;
    mapping.package={};
    for i=1:length(packageList)

        try

            pinfo.name=packageList{i};
            pinfo.memorySectionList{1}=processcsc('GetMemorySectionNames',packageList{i},'Signal');
            pinfo.memorySectionList{2}=processcsc('GetMemorySectionNames',packageList{i},'Parameter');

            pinfo.class{1}=[];
            pinfo.class{2}=[];
            pinfo.class{1}.CSCNames=processcsc('GetCSCNames',packageList{i},'Signal');
            pinfo.class{2}.CSCNames=processcsc('GetCSCNames',packageList{i},'Parameter');
            for j=1:length(pinfo.class{1}.CSCNames)
                pinfo.class{1}.csc{j}.name=pinfo.class{1}.CSCNames{j};
                for k=1:length(pinfo.memorySectionList{1})
                    pinfo.class{1}.csc{j}.memorySection{k}=memSInfo;
                    pinfo.class{1}.csc{j}.memorySection{k}.name=pinfo.memorySectionList{1}{k};
                end
                pinfo.class{1}.csc{j}.default=memSInfo;
            end
            for j=1:length(pinfo.class{2}.CSCNames)
                pinfo.class{2}.csc{j}.name=pinfo.class{2}.CSCNames{j};
                for k=1:length(pinfo.memorySectionList{2})
                    pinfo.class{2}.csc{j}.memorySection{k}=memPInfo;
                    pinfo.class{2}.csc{j}.memorySection{k}.name=pinfo.memorySectionList{2}{k};
                end
                pinfo.class{2}.csc{j}.default=memPInfo;
            end

            mapping.package{index}=pinfo;
            index=index+1;

        catch
            disp([packageList{i},' CSC does not exist. Check path.']);
        end
    end
    mapping.symbolList=symbolList;


    rtwprivate('rtwattic','AtticData','mpt_symbol_mapping',mapping);
    for i=1:length(mpt_symbol_mapping_list)
        ec_set_datasym(mpt_symbol_mapping_list{i});
    end




