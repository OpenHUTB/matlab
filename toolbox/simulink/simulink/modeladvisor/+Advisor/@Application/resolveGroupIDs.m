function instIDs=resolveGroupIDs(this,names)








    instIDs=cell(size(names));

    if strcmp(this.AnalysisRoot,'empty')
        DAStudio.error('Advisor:base:App_NotInitialized');
    end


    if~this.TaskManager.IsInitialized
        this.TaskManager.initialize(this.AnalysisRootComponentId);
    end

    status=0;

    if isempty(this.RootMAObj)

        [~,status]=this.updateModelAdvisorObj(this.AnalysisRootComponentId,true);
    end

    if status==0
        nodes=this.RootMAObj.TaskAdvisorCellArray;

        for n=1:length(nodes)
            node=nodes{n};



            if isa(node,'ModelAdvisor.Group')&&~strncmp(node.ID,'_SYSTEM_By Product_',19)
                match=strcmp(node.ID,names);

                if(~any(match)&&strncmp(node.ID,'_SYSTEM_By Task_',16))
                    match=strcmp(node.ID(17:end),names);
                end

                if(any(match))
                    instIDs{match}=node.ID;
                end
            end
        end
    end



    for n=1:length(instIDs)
        if isempty(instIDs{n})
            instIDs{n}='';
        end
    end
end

