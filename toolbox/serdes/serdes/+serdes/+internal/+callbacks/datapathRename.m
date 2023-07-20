





function datapathRename(block)


    blockHandle=getSimulinkBlockHandle(block);
    newBlockName=get_param(blockHandle,'Name');
    oldBlockName=get_param(blockHandle,'SavedName');

    blockParts=strsplit(block,'/');
    mainSubSystem=blockParts{2};
    if strcmp(mainSubSystem,'Tx')
        otherSubSystem="Rx";
    else
        otherSubSystem="Tx";
    end
    otherTreePath=bdroot(block)+"/"+otherSubSystem;
    otherTree=serdes.internal.callbacks.getSerDesTree(otherTreePath);
    if~serdes.internal.ibisami.ami.VerifySerDesNodeName(newBlockName,false)

        error(message('serdes:callbacks:InvalidNameForAMI',newBlockName));
    elseif~isempty(otherTree)&&otherTree.containsBlock(newBlockName)
        error(message('serdes:callbacks:BlockNameInUse',otherSubSystem));
    elseif~strcmp(newBlockName,oldBlockName)


        tree=serdes.internal.callbacks.getSerDesTree(block);
        if~isempty(tree)
            tree.renameBlock(oldBlockName,newBlockName);
            maskObj=Simulink.Mask.get(blockHandle);
            parameter=maskObj.getParameter('SavedName');
            parameter.set('Value',newBlockName);
            renamed=false;






            blocks=find_system(blockHandle,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FindAll','on','LookUnderMasks','on',...
            'FollowLinks','on','Type','block');
            for blockIdx=1:size(blocks,1)
                blockHdl=blocks(blockIdx);
                blockObj=get_param(blockHdl,'Object');
                blockType=blockObj.get('BlockType');
                if strcmp(blockType,'Constant')


                    value=blockObj.get('Value');
                    newValue=regexprep(value,...
                    ['^',oldBlockName],...
                    newBlockName);
                    if~strcmp(value,newValue)
                        blockObj.set('Value',newValue);
                        renamed=true;
                    end

                    name=blockObj.get('Name');
                    newName=regexprep(name,...
                    ['^',oldBlockName],...
                    newBlockName);
                    if~strcmp(name,newName)
                        blockObj.set('Name',newName);
                        renamed=true;
                    end
                elseif strcmp(blockType,'DataStoreRead')||strcmp(blockType,'DataStoreWrite')


                    value=blockObj.get('DataStoreName');
                    newValue=regexprep(value,...
                    ['^',oldBlockName],...
                    newBlockName);
                    if~strcmp(value,newValue)
                        blockObj.set('DataStoreName',newValue);
                        elements=strsplit(blockObj.get('DataStoreElements'),'#');
                        for elementIdx=1:size(elements)
                            element=elements{elementIdx};
                            newElement=regexprep(element,...
                            ['^',oldBlockName],...
                            newBlockName);
                            if~strcmp(element,newElement)
                                elements{elementIdx}=newElement;
                            end
                        end
                        newElements=strjoin(elements,'#');
                        blockObj.set('DataStoreElements',newElements);
                        renamed=true;
                    end

                    name=blockObj.get('Name');
                    newName=regexprep(name,...
                    ['^',oldBlockName],...
                    newBlockName);
                    if~strcmp(name,newName)
                        blockObj.set('Name',newName);
                        renamed=true;
                    end
                end
            end
            if renamed
                initBlock=[get_param(block,'Parent'),'/Init'];
                serdes.internal.callbacks.deliverInfoNotification(block,'serdes:callbacks:RefreshInitRequired',...
                initBlock,block);
            end
        else
            serdes.internal.callbacks.deliverInfoNotification(blockHandle,...
            'serdes:callbacks:ModelWorkspaceMissingTree','SerDesTree');
        end
    end
end
