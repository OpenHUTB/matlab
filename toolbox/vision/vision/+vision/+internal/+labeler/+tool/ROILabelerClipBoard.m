classdef ROILabelerClipBoard<handle
    properties

CopiedROIs
    end




    methods

        function add(this,rois)

            purge(this);

            for i=numel(rois):-1:1
                this.CopiedROIs{end+1}=rois{i};
            end

        end


        function purge(this)
            this.CopiedROIs={};
        end


        function renameAttribute(this,attribData,newName)
            isLabelSelected=isempty(attribData.SublabelName);
            for i=1:length(this.CopiedROIs)
                if~isempty(this.CopiedROIs{i})
                    obj=this.CopiedROIs{i};
                    if isLabelSelected

                        if strcmp(obj.Label,attribData.LabelName)
                            for j=1:numel(obj.AttributeNames)
                                if strcmp(obj.AttributeNames{j},attribData.Name)
                                    obj.AttributeNames{j}=newName;
                                end
                            end
                        end
                    elseif~isLabelSelected&&~isempty(obj.parentName)
                        if strcmp(obj.Label,attribData.SublabelName)&&...
                            strcmp(obj.parentName,attribData.LabelName)
                            for j=1:numel(obj.AttributeNames)
                                if strcmp(obj.AttributeNames{j},attribData.Name)
                                    obj.AttributeNames{j}=newName;
                                end
                            end
                        end
                    end
                    this.CopiedROIs{i}=obj;
                end
            end
        end


        function rename(this,newItemInfo,oldItemInfo)
            for i=1:length(this.CopiedROIs)
                if~isempty(this.CopiedROIs{i})
                    obj=this.CopiedROIs{i};
                    if oldItemInfo.IsLabelItemSelected

                        if strcmp(obj.Label,oldItemInfo.LabelName)
                            obj.Label=newItemInfo.Label;
                            obj.Tag=newItemInfo.Label;
                        end

                        if strcmp(obj.parentName,oldItemInfo.LabelName)
                            obj.parentName=newItemInfo.Label;
                        end
                    elseif~oldItemInfo.IsLabelItemSelected&&~isempty(obj.parentName)
                        if strcmp(obj.Label,oldItemInfo.SublabelName)&&...
                            strcmp(obj.parentName,oldItemInfo.LabelName)
                            obj.Label=newItemInfo.Sublabel;
                            obj.Tag=newItemInfo.Sublabel;
                        end
                    end
                    this.CopiedROIs{i}=obj;
                end
            end
        end


        function colorChange(this,newItemInfo,oldItemInfo)
            for i=1:length(this.CopiedROIs)
                if~isempty(this.CopiedROIs{i})
                    obj=this.CopiedROIs{i};
                    if oldItemInfo.IsLabelItemSelected

                        if isequal(size(oldItemInfo.Color),[3,1])
                            oldItemInfo.Color=oldItemInfo.Color';
                        end
                        if isequal(obj.Color,oldItemInfo.Color)
                            obj.Color=newItemInfo.Color;
                        end
                    elseif~oldItemInfo.IsLabelItemSelected&&~isempty(obj.parentName)

                        if isequal(obj.Color,oldItemInfo.Color)
                            obj.Color=newItemInfo.Color;
                        end
                    end
                    this.CopiedROIs{i}=obj;
                end
            end
        end


        function roiVisibilityChange(this,newItemInfo)
            for i=1:length(this.CopiedROIs)
                if~isempty(this.CopiedROIs{i})
                    obj=this.CopiedROIs{i};
                    if isa(newItemInfo,'vision.internal.labeler.ROILabel')
                        labelName=newItemInfo.Label;
                    else
                        labelName=newItemInfo.Sublabel;
                    end
                    if isequal(obj.Label,labelName)
                        obj.Visible=newItemInfo.ROIVisibility;
                    end
                    this.CopiedROIs{i}=obj;
                end
            end
        end


        function rois=contents(this)
            rois=this.CopiedROIs;
        end


        function TF=isempty(this)
            TF=isempty(this.CopiedROIs);
        end


        function refresh(this)
            refreshedROIs={};
            for idx=1:length(this.CopiedROIs)
                if~isempty(this.CopiedROIs{idx})
                    refreshedROIs{end+1}=this.CopiedROIs{idx};%#ok<AGROW>
                end
            end

            purge(this);
            this.CopiedROIs=refreshedROIs;
        end


        function refreshUIDs(this)



            numROIs=numel(this.CopiedROIs);
            isIDChanged=false(numROIs,1);


            for inx=1:numROIs
                thisroi=this.CopiedROIs{inx};

                if isempty(thisroi)

                    continue
                end


                newID=vision.internal.getUniqueID();


                oldID=this.CopiedROIs{inx}.selfUID;
                this.CopiedROIs{inx}.selfUID=newID;
                isIDChanged(inx)=true;


                for pidx=1:numROIs
                    if isequal(this.CopiedROIs{pidx}.parentUID,oldID)
                        this.CopiedROIs{pidx}.parentUID=newID;
                        this.CopiedROIs{pidx}.UserData{3}=newID;
                        isIDChanged(pidx)=true;
                    end
                end
            end


            for inx=1:numROIs
                thisroi=this.CopiedROIs{inx};
                if isempty(thisroi)

                    continue
                end
                if~isIDChanged(inx)
                    newSelfID=vision.internal.getUniqueID();
                    this.CopiedROIs{inx}.selfUID=newSelfID;
                end
            end
        end

    end
end