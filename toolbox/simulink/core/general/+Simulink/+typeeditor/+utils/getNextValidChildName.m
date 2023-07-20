function newName=getNextValidChildName(parent,prefix,isType)




    varIDs=parent.getRoot.NodeDataAccessor.identifyVisibleVariables;
    varNames={varIDs.Name};

    idx=[];
    newName='';
    assert(isa(parent,'Simulink.typeeditor.app.Source')||isa(parent,'Simulink.typeeditor.app.Object'));
    childCount=parent.getNumChildren;
    childNames=parent.getChildrenNames;
    while true
        if childCount==0
            if isType
                if~any(strcmp(varNames,prefix))
                    newName=prefix;
                    break;
                end
            else
                newName=prefix;
                break;
            end
        end
        newName=[prefix,num2str(idx)];
        if~any(strcmp(newName,childNames))
            if isType
                if~any(strcmp(newName,varNames))
                    break;
                end
            else
                break;
            end
        end
        if isempty(idx)
            idx=1;
        else
            idx=idx+1;
        end
    end