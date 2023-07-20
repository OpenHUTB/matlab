




classdef ROIUndoRedoParams<handle&vision.internal.labeler.tool.UndoRedo

    properties(SetAccess=private)
TimeIndex
IDs
ROINames
ParentNames
ParentUIDs
Positions
Colors
Shapes
ROIVisibility
    end

    methods

        function this=ROIUndoRedoParams(timeIndex,roiNames,parentNames,...
            selfUIDs,parentUIDs,...
            roiPositions,roiColors,roiShapes,roiVisibility)
            this.TimeIndex=timeIndex;
            this.IDs=selfUIDs;
            this.ROINames=roiNames;
            this.ParentNames=parentNames;
            this.ParentUIDs=parentUIDs;
            this.Positions=roiPositions;
            this.Colors=roiColors;
            this.Shapes=roiShapes;
            this.ROIVisibility=roiVisibility;
        end


        function flag=isequal(obj1,obj2)


            flag=(isequal(obj1.TimeIndex,obj2.TimeIndex)&&...
            isequal(obj1.IDs,obj2.IDs)&&...
            isequal(obj1.ROINames,obj2.ROINames)&&...
            isequal(obj1.ParentNames,obj2.ParentNames)&&...
            isequal(obj1.ParentUIDs,obj2.ParentUIDs)&&...
            isequal(obj1.Positions,obj2.Positions)&&...
            isequal(obj1.Colors,obj2.Colors));

        end


        function obj=rename(obj,newItemInfo,oldItemInfo)

            for i=1:numel(obj.IDs)








                if oldItemInfo.IsLabelItemSelected

                    if strcmp(obj.ROINames{i},oldItemInfo.LabelName)
                        obj.ROINames{i}=newItemInfo.Label;
                    end

                    if strcmp(obj.ParentNames{i},oldItemInfo.LabelName)
                        obj.ParentNames{i}=newItemInfo.Label;
                    end
                elseif~oldItemInfo.IsLabelItemSelected&&~isempty(obj.ParentNames{i})
                    if strcmp(obj.ROINames{i},oldItemInfo.SublabelName)&&...
                        strcmp(obj.ParentNames{i},oldItemInfo.LabelName)
                        obj.ROINames{i}=newItemInfo.Sublabel;
                    end
                end
            end
        end


        function obj=colorChange(obj,newItemInfo,oldItemInfo)




            for i=1:numel(obj.IDs)
                if oldItemInfo.IsLabelItemSelected

                    if(isequal(size(oldItemInfo.Color),[3,1]))
                        oldItemInfo.Color=oldItemInfo.Color';
                    end
                    if isequal(obj.Colors{i},oldItemInfo.Color)
                        obj.Colors{i}=newItemInfo.Color;
                    end
                elseif~oldItemInfo.IsLabelItemSelected&&~isempty(obj.ParentNames{i})

                    if isequal(obj.Colors{i},oldItemInfo.Color)
                        obj.Colors{i}=newItemInfo.Color;
                    end
                end
            end
        end


        function obj=labelVisibility(obj,newItemInfo)
            if isa(newItemInfo,'vision.internal.labeler.ROILabel')
                labelName=newItemInfo.Label;
            else
                labelName=newItemInfo.Sublabel;
            end
            for i=1:numel(obj.IDs)
                if isequal(obj.ROINames{i},labelName)
                    obj.ROIVisibility{i}=newItemInfo.ROIVisibility;
                end
            end
        end


        function execute(~)
        end


        function undo(~)
        end
    end
end