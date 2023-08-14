classdef UndoRedoManagerShape<vision.internal.labeler.tool.UndoRedoManagerShape




    methods

        function initializeUndoBuffer(thisObj,index)




            if thisObj.shouldResetUndoRedo(index)
                thisObj.resetUndoRedoBuffer();
            end


            thisObj.executeCommand(...
            lidar.internal.labeler.tool.ROIUndoRedoParams(...
            index,{},{},{},{},{},{},{},{}));

        end
    end
end
