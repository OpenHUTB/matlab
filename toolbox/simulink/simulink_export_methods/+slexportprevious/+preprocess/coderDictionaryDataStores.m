function coderDictionaryDataStores(obj)





    newRules={};
    verobj=obj.ver;

    if isR2007bOrEarlier(verobj)


        import slexportprevious.rulefactory.*
        ruleRoot='<BlockParameterDefaults';
        ruleEnd='>';
        newRules{end+1}=[ruleRoot,removeInBlockType('DataStoreName','DataStoreMemory'),ruleEnd];
        newRules{end+1}=[ruleRoot,removeInBlockType('InitialValue','DataStoreMemory'),ruleEnd];
        newRules{end+1}=[ruleRoot,removeInBlockType('RTWStateStorageClass','DataStoreMemory'),ruleEnd];
        newRules{end+1}=[ruleRoot,removeInBlockType('VectorParams1D','DataStoreMemory'),ruleEnd];
        newRules{end+1}=[ruleRoot,removeInBlockType('DataStoreName','DataStoreRead'),ruleEnd];
        newRules{end+1}=[ruleRoot,removeInBlockType('SampleTime','DataStoreRead'),ruleEnd];
        newRules{end+1}=[ruleRoot,removeInBlockType('DataStoreName','DataStoreWrite'),ruleEnd];
        newRules{end+1}=[ruleRoot,removeInBlockType('SampleTime','DataStoreWrite'),ruleEnd];


        blocks=obj.findBlocksOfType('DataStoreMemory');
        for i=1:length(blocks)
            block=blocks{i};
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(block);
            dataStoreName=get_param(block,'DataStoreName');
            defDataStoreName='A';
            if strcmp(dataStoreName,defDataStoreName)
                newRules{end+1}=slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'DataStorename',defDataStoreName);%#ok
            end
            initialValue=get_param(block,'InitialValue');
            defInitialValue='0';
            if strcmp(initialValue,defInitialValue)
                newRules{end+1}=slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'InitialValue',defInitialValue);%#ok
            end
            storageClass=get_param(block,'RTWStateStorageClass');
            defRTWStateStorageClass='Auto';
            if strcmp(storageClass,defRTWStateStorageClass)
                newRules{end+1}=slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'RTWStateStorageClass',defRTWStateStorageClass);%#ok
            end
            vectorParams1D=get_param(block,'VectorParams1D');
            defVectorParams1D='on';
            if strcmp(vectorParams1D,defVectorParams1D)
                newRules{end+1}=slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'VectorParams1D',defVectorParams1D);%#ok
            end
        end


        blocks=obj.findBlocksOfType('DataStoreRead');
        for i=1:length(blocks)
            block=blocks{i};
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(block);
            dataStoreName=get_param(block,'DataStoreName');
            defDataStoreName='A';
            if strcmp(dataStoreName,defDataStoreName)
                newRules{end+1}=slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'DataStoreName',defDataStoreName);%#ok
            end
            sampleTime=get_param(block,'SampleTime');
            defSampleTime='-1';
            if strcmp(sampleTime,defSampleTime)
                newRules{end+1}=slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'SampleTime',defSampleTime);%#ok
            end
        end


        blocks=obj.findBlocksOfType('DataStoreWrite');
        for i=1:length(blocks)
            block=blocks{i};
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(block);
            dataStoreName=get_param(block,'DataStoreName');
            defDataStoreName='A';
            if strcmp(dataStoreName,defDataStoreName)
                newRules{end+1}=slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'DataStoreName',defDataStoreName);%#ok
            end
            sampleTime=get_param(block,'SampleTime');
            defSampleTime='-1';
            if strcmp(sampleTime,defSampleTime)
                obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'SampleTime',defSampleTime));
            end
        end
    end

    obj.appendRules(newRules);

end

