















function applyComponentSelection(this,inputs)
    cm=this.ComponentManager;


    if~isempty(inputs.ids)
        if iscell(inputs.ids)
            ids=inputs.ids;
        else
            ids{1}=inputs.ids;
        end




        if this.AnalysisRootType==Advisor.component.Types.SubSystem
            for n=1:length(ids)
                if strcmp(ids{n},this.RootModel)
                    ids{n}=this.AnalysisRootComponentId;
                end


                if~cm.existComponent(ids{n})
                    DAStudio.error('Advisor:base:Components_UnknownIstanceID',ids{n});
                end
            end
        else
            for n=1:length(ids)

                if~cm.existComponent(ids{n})
                    DAStudio.error('Advisor:base:Components_UnknownIstanceID',ids{n});
                end
            end
        end


        if inputs.hierarchicalSelection


            if iscell(ids)
                if length(ids)>1
                    DAStudio.error('Advisor:base:App_CannotSelectCompHierarchy');
                end

                ids=ids{1};
            end

            selectComponentInstanceBranch(cm,ids,inputs.status);


        else


            modelcomps=getAllSelectableComponentIDs(cm);
            ids=intersect(ids,modelcomps);

            cm.setProperties(ids,'Selected',inputs.status);
        end


    elseif isempty(inputs.type)
        modelcomps=getAllSelectableComponentIDs(cm);
        cm.setProperties(modelcomps,'Selected',inputs.status);


    else

        if inputs.type==Advisor.component.Types.Model
            props.Type=Advisor.component.Types.Model;
            modelcomps=cm.getComponentsWithProperties(props,[]);
            cm.setProperties(modelcomps,'Selected',inputs.status);
        end
    end
end

function ids=getAllSelectableComponentIDs(cm)
    props.Type=Advisor.component.Types.Model;
    ids=cm.getComponentsWithProperties(props,[]);
    ids{end+1}=cm.AnalysisRootComponentID;
    ids=unique(ids);
end

function selectComponentInstanceBranch(cm,id,status)

    comp=cm.getComponent(id);

    if comp.Type==Advisor.component.Types.Model||...
        strcmp(comp.ID,cm.AnalysisRootComponentID)
        cm.setProperty(id,'Selected',status);
    end

    children=cm.getChildNodes(id);

    for n=1:length(children)
        selectComponentInstanceBranch(cm,children(n).ID,status)
    end
end
