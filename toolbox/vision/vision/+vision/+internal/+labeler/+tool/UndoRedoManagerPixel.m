



classdef UndoRedoManagerPixel<vision.internal.labeler.tool.UndoRedoManager
    methods

        function initializeUndoBuffer(thisObj,index,labelmatrix,placeholder)




            if thisObj.shouldResetUndoRedo(index)
                thisObj.resetUndoRedoBuffer();
            end


            thisObj.executeCommand(...
            vision.internal.labeler.tool.ROIUndoRedoParamsPixel(...
            index,{labelmatrix},{placeholder}));
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