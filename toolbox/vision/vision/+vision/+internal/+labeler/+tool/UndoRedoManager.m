



classdef UndoRedoManager<handle

    properties(SetAccess=protected)
        undoStack={};
        redoStack={};


CurrentImageIndex
    end

    events


UpdateUndoRedoQAB
    end

    methods




        function TF=executeCommand(thisObj,roiUndoRedoParamObj)

            roiUndoRedoParamObj.execute();


            if thisObj.isSameAsPrevious(roiUndoRedoParamObj)
                TF=false;
                return;
            end
            TF=true;


            thisObj.undoStack{end+1}=roiUndoRedoParamObj;


            thisObj.redoStack={};



            notify(thisObj,'UpdateUndoRedoQAB');
        end

        function flag=isSameAsPrevious(thisObj,roiUndoRedoParamObj)
            if thisObj.isUndoStackEmpty()
                flag=false;
            else
                if isequal(thisObj.undoStack{end},roiUndoRedoParamObj)
                    flag=true;
                else
                    flag=false;
                end
            end
        end


        function flag=shouldResetUndoRedo(thisObj,currentIndex)

            if thisObj.isUndoStackEmpty()
                flag=true;
            else

                timeIndex=thisObj.undoStack{end}.TimeIndex;
                flag=(timeIndex~=currentIndex);
            end
        end


        function flag=isUndoStackEmpty(thisObj)
            flag=isempty(thisObj.undoStack);
        end


        function resetUndoRedoBuffer(thisObj)
            thisObj.undoStack={};
            thisObj.redoStack={};
        end




        function flag=isUndoAvailable(thisObj,varargin)





            flag=length(thisObj.undoStack)>1;

            if flag&&(nargin==2)
                validTime=thisObj.undoStack{end}.TimeIndex;
                flag=flag&(varargin{1}==validTime);
            end
        end









        function undo(thisObj)
            assert(thisObj.isUndoAvailable());


            command=thisObj.undoStack{end};thisObj.undoStack(end)=[];

            command.undo();


            thisObj.redoStack{end+1}=command;

            notify(thisObj,'UpdateUndoRedoQAB');
        end





        function flag=isRedoAvailable(thisObj,varargin)
            flag=~isempty(thisObj.redoStack);

            if flag&&(nargin==2)
                validTime=thisObj.redoStack{end}.TimeIndex;
                flag=flag&(varargin{1}==validTime);
            end
        end







        function redo(thisObj)
            assert(isRedoAvailable(thisObj));


            command=thisObj.redoStack{end};thisObj.redoStack(end)=[];
            command.execute();


            thisObj.undoStack{end+1}=command;

            notify(thisObj,'UpdateUndoRedoQAB');
        end


        function addDuplicate(thisObj)

            thisObj.undoStack{end+1}=thisObj.undoStack{end};
        end


        function resetRedoStack(thisObj)

            thisObj.redoStack={};
        end
    end
end