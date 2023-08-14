





function[selectedCompIds,subTrees]=...
    getSelectedComponentsToExecute(this)




    cm=this.ComponentManager;


    props.Selected=true;



    selectedRootInstIDs=cm.getRootComponentsWithProperties([],props);




    isModel=true(size(selectedRootInstIDs));
    newRootModels={};


    selectedSubSystemRoot=false;

    for n=1:length(selectedRootInstIDs)
        instID=selectedRootInstIDs{n};
        component=cm.getComponent(instID);


        if~isa(component,'Advisor.component.filebased.FileBasedInstance')
            selectedSubSystemRoot=true;
            isModel(n)=false;

        elseif~isa(component,'Advisor.component.filebased.Model')
            isModel(n)=false;

            while~isempty(component)&&~isa(component,'Advisor.component.filebased.Model')
                ps=cm.getParentNodes(component(1).ID);
                component=ps(1);



                if this.AnalysisRootType==Advisor.component.Types.SubSystem&&...
                    ~isempty(component)&&strcmp(component.ID,this.AnalysisRootComponentId)
                    selectedSubSystemRoot=true;
                    component=[];
                    break;
                end
            end

            if~isempty(component)
                newRootModels{end+1}=component.ID;%#ok<AGROW>
            end
        end
    end

    rootModels=[selectedRootInstIDs(isModel),newRootModels];




    rootModels=unique(rootModels);





    clear props;
    props.Selected=true;
    iprops.Type=Advisor.component.Types.Model;
    subTrees=struct('RootModel',{},'Models',{});



    if selectedSubSystemRoot
        subTrees(1).RootModel=this.RootModel;
        subTrees(1).Models=cm.getComponentsWithProperties(iprops,props);
    else
        for n=1:length(rootModels)
            instID=rootModels{n};
            subTrees(n).RootModel=instID;
            subTrees(n).Models=cm.getComponentsWithPropertiesInBranch(instID,iprops,props);
        end
    end




    clear props;
    props.Selected=true;
    selectedCompIds=cm.getComponentsWithProperties([],props);

end
