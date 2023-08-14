







function instanceIDs=getCompileScope(this,modelID)

    if this.existComponent(modelID)
        instanceIDs=getNonModelChildComponentIDs(this,modelID);
    else
        DAStudio.error('Advisor:base:Components_UnknownIstanceID',modelID);
    end
end



function childIDs=getNonModelChildComponentIDs(this,instanceID)
    childIDs=cell(0,1);


    children=this.getChildNodes(instanceID);

    for n=1:length(children)
        childObj=children(n);

        if isa(childObj,'Advisor.component.filebased.Model')

        else
            childIDs{end+1}=childObj.ID;%#ok<AGROW> 

            nChildIDs=getNonModelChildComponentIDs(this,children(n).ID);

            if~isempty(nChildIDs)
                childIDs=[childIDs,nChildIDs];%#ok<AGROW>
            end
        end
    end
end