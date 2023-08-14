



classdef UndoRedoManagerShape<vision.internal.labeler.tool.UndoRedoManager

    methods

        function initializeUndoBuffer(thisObj,index)




            if thisObj.shouldResetUndoRedo(index)
                thisObj.resetUndoRedoBuffer();
            end


            thisObj.executeCommand(...
            vision.internal.labeler.tool.ROIUndoRedoParams(...
            index,{},{},{},{},{},{},{},{}));

        end


        function addROILabelsToUndoStack(thisObj,index,roiLabelData)

            roiNames={roiLabelData.Label};
            parentNames={roiLabelData.ParentName};

            selfUIDs={roiLabelData.ID};
            parentUIDs={roiLabelData.ParentUID};

            roiPositions={roiLabelData.Position};
            roiColors={roiLabelData.Color};
            roiShapes=[roiLabelData.Shape];
            roiVisibility={roiLabelData.Visible};




            if thisObj.shouldResetUndoRedo(index)
                thisObj.resetUndoRedoBuffer();
            end



            thisObj.executeCommand(...
            vision.internal.labeler.tool.ROIUndoRedoParams(...
            index,roiNames,parentNames,...
            selfUIDs,parentUIDs,...
            roiPositions,roiColors,roiShapes,roiVisibility));


        end


        function updateLabelInUndoRedoBuffer(thisObj,newItemInfo,oldItemInfo,toUpdate)





            for i=1:length(thisObj.undoStack)
                if toUpdate(1)

                    newObj=colorChange(thisObj.undoStack{i},newItemInfo,oldItemInfo);
                elseif toUpdate(2)

                    newObj=rename(thisObj.undoStack{i},newItemInfo,oldItemInfo);
                end
                thisObj.undoStack{i}=newObj;
            end
            for i=1:length(thisObj.redoStack)
                if toUpdate(1)

                    newObj=colorChange(thisObj.redoStack{i},newItemInfo,oldItemInfo);
                elseif toUpdate(2)

                    newObj=rename(thisObj.redoStack{i},newItemInfo,oldItemInfo);
                end
                thisObj.redoStack{i}=newObj;
            end
        end


        function updateLabelVisibilityInUndoRedoBuffer(thisObj,newItemInfo)


            for i=1:length(thisObj.undoStack)
                newObj=labelVisibility(thisObj.undoStack{i},newItemInfo);
                thisObj.undoStack{i}=newObj;
            end
            for i=1:length(thisObj.redoStack)
                newObj=labelVisibility(thisObj.redoStack{i},newItemInfo);
                thisObj.redoStack{i}=newObj;
            end
        end
    end
end