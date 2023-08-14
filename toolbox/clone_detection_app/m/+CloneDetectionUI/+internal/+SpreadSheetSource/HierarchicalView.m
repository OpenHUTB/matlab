classdef HierarchicalView<handle




    properties
        model;
        data;
        columns;
        cloneDetectionStatus;
        blockPathCategoryMap;
        m2mObj;
        colorCodes;
    end

    methods(Access=public)

        function this=HierarchicalView(model,m2mObj,blockPathCategoryMap,cloneDetectionStatus,colorCodes)
            this.model=model;
            this.blockPathCategoryMap=blockPathCategoryMap;
            this.data=[];

            this.columns={DAStudio.message('sl_pir_cpp:creator:modelHierarchySSColumn1'),...
            DAStudio.message('sl_pir_cpp:creator:modelHierarchySSColumn2')};
            this.cloneDetectionStatus=cloneDetectionStatus;
            this.m2mObj=m2mObj;
            this.colorCodes=colorCodes;
        end


        function children=getChildren(this,~)
            if~isempty(this.data)
                children=this.data;
                return;
            else
                rootChildren=this.DFS(get_param(this.model,'name'));
                children=...
                CloneDetectionUI.internal.SpreadSheetItem.HierarchicalView...
                (get_param(this.model,'Name'),Simulink.ID.getSID(this.model),...
                'Model','',rootChildren,this.blockPathCategoryMap,this.cloneDetectionStatus,...
                this.colorCodes,'');
                this.data=children;
                children=this.data;
            end
        end
    end

    methods(Access=private)

        function rootChildren=DFS(this,modelName)

            children=find_system(modelName,'MatchFilter',@Simulink.match.allVariants,...
            'IncludeCommented','on','LookUnderMasks','all','FollowLinks','on',...
            'SearchDepth',1);
            if length(children)==1
                rootChildren=[];
                return;
            end


            assert(strcmp(children(1),modelName),'Error occured while creating Model hierarchy');

            rootChildren={};
            for i=2:length(children)
                currentChild=children(i);
                type=get_param(currentChild,'BlockType');
                if strcmp(type,'SubSystem')
                    nextChildren=this.DFS(currentChild);
                    child=...
                    CloneDetectionUI.internal.SpreadSheetItem.HierarchicalView...
                    (char(get_param(currentChild,'Name')),...
                    Simulink.ID.getSID(currentChild),...
                    type,modelName,nextChildren,this.blockPathCategoryMap,...
                    this.cloneDetectionStatus,this.colorCodes,currentChild);
                elseif strcmp(type,'ModelReference')
                    modelRef=get_param(currentChild,'ModelName');
                    if~isa(this.m2mObj,'slEnginePir.acrossModelGraphicalCloneDetection')&&isempty(this.m2mObj.refModels)
                        nextChildren='';
                    else
                        nextChildren=this.DFS(modelRef);
                    end
                    child=...
                    CloneDetectionUI.internal.SpreadSheetItem.HierarchicalView...
                    ([char(get_param(currentChild,'Name')),...
                    '(',char(modelRef),')'],Simulink.ID.getSID(currentChild),...
                    type,modelName,nextChildren,this.blockPathCategoryMap,...
                    this.cloneDetectionStatus,this.colorCodes,currentChild);
                else
                    continue;
                end
                rootChildren=[rootChildren,child];
            end
        end
    end

end

