function removeColorAnnotation(this,mdlName)





    modelIndex=find(strcmp(mdlName,this.modelList),1);

    if(~isempty(modelIndex)&&strcmp(this.modelLegendState{modelIndex},'on'))
        studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        st=studios(1);
        stApp=st.App;
        topLevelModel=getfullname(stApp.topLevelDiagram.handle);
        studioTab_cont=find(strcmp(topLevelModel,this.modelList),1);
        if(length(this.modelLegendState)>=studioTab_cont)
            st.hideComponent(this.ssSource{studioTab_cont}.mComponent);
            this.modelLegendState{studioTab_cont}='off';
        end
        if(isKey(this.studioDiagramMap,num2str(get_param(topLevelModel,'handle'))))
            this.studioDiagramMap(num2str(get_param(topLevelModel,'handle')))=[];
        end
        this.clearHilite(mdlName);
    end
end
