




classdef ROIUndoRedoParamsPixel<handle&vision.internal.labeler.tool.UndoRedo

    properties(SetAccess=private)
TimeIndex
LabelMatrix
Placeholder
    end

    methods

        function this=ROIUndoRedoParamsPixel(timeIndex,labelMatrix,placeholder)
            this.TimeIndex=timeIndex;
            this.LabelMatrix=labelMatrix;
            this.Placeholder=placeholder;
        end


        function flag=isequal(obj1,obj2)
            flag=(isequal(obj1.LabelMatrix{1},obj2.LabelMatrix{1})&&...
            isequal(obj1.Placeholder,obj2.Placeholder));
        end


        function obj=rename(obj,newItemInfo,oldItemInfo)


            if isempty(obj.Placeholder{1})

                return;
            elseif isfield(obj.Placeholder{1},'Label')

                if isequal(obj.Placeholder{1}.Label,oldItemInfo.Label)
                    obj.Placeholder{1}.Label=newItemInfo.Label;
                end
            else


                if isequal(obj.Placeholder{1}.GrabCutPolygon.Color,oldItemInfo.Label)
                    obj.Placeholder{1}.GrabCutPolygon.Label=newItemInfo.Label;
                end
            end
        end


        function obj=colorChange(obj,newItemInfo,oldItemInfo)






            if(isequal(size(oldItemInfo.Color),[3,1]))
                oldItemInfo.Color=oldItemInfo.Color';
            end

            if isempty(obj.Placeholder{1})

                return;
            elseif isfield(obj.Placeholder{1},'Color')

                if isequal(obj.Placeholder{1}.Color,oldItemInfo.Color)
                    obj.Placeholder{1}.Color=newItemInfo.Color;
                end
            else

                if isequal(obj.Placeholder{1}.GrabCutPolygon.Color,oldItemInfo.Color)
                    obj.Placeholder{1}.GrabCutPolygon.Color=newItemInfo.Color;
                end
            end
        end


        function obj=labelVisibility(obj,newItemInfo)

            if isempty(obj.Placeholder{1})

                return;
            elseif isfield(obj.Placeholder{1},'Visible')

                if isequal(obj.Placeholder{1}.Label,newItemInfo.Label)
                    obj.Placeholder{1}.Visible=newItemInfo.ROIVisibility;
                end
            else

                if isequal(obj.Placeholder{1}.GrabCutPolygon.Label,newItemInfo.Label)
                    obj.Placeholder{1}.GrabCutPolygon.Visible=newItemInfo.ROIVisibility;
                end
            end

        end

        function execute(~)
        end


        function undo(~)
        end
    end
end