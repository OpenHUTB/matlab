function addModel(this,mdlName)



    this.modelName=mdlName;

    newModelIndex=find(strcmp(mdlName,this.modelList));
    if(isempty(newModelIndex))
        newModelIndex=length(this.modelList)+1;
        this.modelList{newModelIndex}=mdlName;
        this.modelLegendState{newModelIndex}='off';

        this.currentTabIndex=length(this.modelList)-1;
        hasExpandedVarTsBackup=this.hasExpandedVarTs;
        this.hasExpandedVarTs=cell(1,this.currentTabIndex+1);
        for n=1:this.currentTabIndex
            this.hasExpandedVarTs{n}=hasExpandedVarTsBackup{n};
        end
        this.hasExpandedVarTs{this.currentTabIndex+1}=-1;
    else
        this.currentTabIndex=newModelIndex(1)-1;
    end


    tab_cont=find(strcmp(this.modelName,this.modelList));
    tab_cont=tab_cont(1);
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    for idx=1:length(studios)
        if studios(idx).App.getActiveEditor.blockDiagramHandle~=0
            studioActiveName=getfullname(studios(idx).App.getActiveEditor.blockDiagramHandle);
            if(isequal(studioActiveName,mdlName))
                this.studio{tab_cont}=studios(idx);
                if isempty(this.studioDiagramMap)
                    this.studioDiagramMap=containers.Map;
                end
                this.studioDiagramMap(num2str(studios(idx).App.blockDiagramHandle))...
                =studios(idx).App.getActiveEditor.blockDiagramHandle;
                break;
            end
        end
    end

    if bdIsLoaded(mdlName)


        modelHandle=get_param(mdlName,'Handle');
        Simulink.addBlockDiagramCallback(modelHandle,...
        'PreClose','SampleTimeLegend',...
        @()removeModel(Simulink.SampleTimeLegend,...
        get_param(modelHandle,'Name')),...
        true);


        Simulink.addBlockDiagramCallback(modelHandle,...
        'PostNameChange','SampleTimeLegend',...
        @()changeModelName(Simulink.SampleTimeLegend,...
        mdlName,get_param(modelHandle,'Name')),...
        true);
    end
end
