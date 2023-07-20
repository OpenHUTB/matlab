function[DataTypeInfo,CastingUsed,DataTypeStruct]=getDataTypeInfoAsString(scenarioids)











    repo=starepository.RepositoryUtility();
    DataTypeInfo=cell(1,length(scenarioids));
    DataTypeStruct=struct;
    CastingUsed=false;

    if~isnumeric(scenarioids)
        return;
    end

    for k=1:length(scenarioids)
        signals=repo.getChildrenIds(scenarioids(k));
        DataTypes=cell(1,length(signals));
        DataTypes(:)={'double'};
        for sigId=1:length(signals)
            castToDataType=getMetaDataByName(repo,signals(sigId),'CastToDataType');
            if~isempty(castToDataType)
                CastingUsed=true;
                DataTypes{sigId}=castToDataType;
            end
        end
        if CastingUsed
            [uniqueDT,~,Loc]=unique(DataTypes);
            configstruct=struct;
            configstruct.DataType=uniqueDT;
            configstruct.Signals=cell(1,length(uniqueDT));
            signalidStr=cell(1,length(uniqueDT));
            for id=1:length(uniqueDT)
                indices=find(ismember(Loc,id));
                configstruct.Signals{id}=num2cell(indices');
                signalIds=cellfun(@(x)num2str(x),configstruct.Signals{id},'UniformOutput',false);
                signalidStr{id}=['{',strjoin(cellstr(signalIds),','),'}'];
            end
            returnDataTypeStr=['spreadsheetDataTypeConfig(',num2str(k),').DataType = {','''',strjoin(configstruct.DataType,''','''),'''};'];
            returnSignalStr=sprintf('spreadsheetDataTypeConfig(%s).Signals = {...\n%s\n};',num2str(k),strjoin(signalidStr,',...\n'));
            DataTypeStruct(k).DataType=configstruct.DataType;
            DataTypeStruct(k).Signals=configstruct.Signals;
            DataTypeInfo{k}=sprintf('%s\n%s',returnDataTypeStr,returnSignalStr);
        end
    end

end

