function namesForPasting=renameForPaste(parent,namesToFix,isType)




    tempNames=namesToFix;

    varIDs=parent.getRoot.NodeDataAccessor.identifyVisibleVariables;
    varNames={varIDs.Name};

    for idx=1:length(namesToFix)
        iter=1;
        while true
            if isempty(parent.findIdx(tempNames{idx}))
                if isType
                    if isempty(find(strcmp(varNames,tempNames{idx}),1))
                        break;
                    end
                else
                    break;
                end
            end
            tempNames{idx}=['Copy_',num2str(iter),'_of_',namesToFix{idx}];
            iter=iter+1;
        end
    end
    namesForPasting=tempNames;