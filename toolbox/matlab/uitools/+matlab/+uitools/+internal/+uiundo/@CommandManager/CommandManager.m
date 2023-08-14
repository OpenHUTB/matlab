classdef CommandManager<hgsetget




    properties(SetAccess='private',SetObservable=true)
UndoStack
RedoStack
        MaxUndoStackLength double=30;
    end

    properties
Verbose
    end

    events
CommandStackChanged
    end

    methods
        function clearStack(hObj,undoPos,redoPos)


            if nargin>=2&&~isempty(undoPos)
                hObj.UndoStack(1:undoPos)=[];
            else
                hObj.UndoStack=[];
            end
            if nargin>=3&&~isempty(redoPos)
                hObj.RedoStack(1:redoPos)=[];
            else
                hObj.RedoStack=[];
            end
            notify(hObj,'CommandStackChanged');
        end

        function undo(hObj)

            stack=hObj.UndoStack;
            len=length(stack);
            if len>0
                cmd=stack(len);
                hObj.UndoStack=stack(1:len-1);
            else
                return;
            end


            undo(cmd);


            stack=hObj.RedoStack;
            hObj.RedoStack=[stack;cmd];


            notify(hObj,'CommandStackChanged');
        end

        function redo(hObj)

            stack=hObj.RedoStack;
            len=length(stack);
            if len>0
                cmd=stack(len);
                hObj.RedoStack=stack(1:len-1);
            else
                return;
            end


            redo(cmd);


            stack=hObj.UndoStack;
            hObj.UndoStack=[stack;cmd];


            notify(hObj,'CommandStackChanged');
        end

        function[cmd]=peekundo(hObj)
            cmd=[];
            undostack=hObj.UndoStack;

            num=numel(undostack);
            if num>0
                cmd=undostack(end);
            end
        end

        function[cmd]=peekredo(hObj)
            cmd=[];
            redostack=hObj.RedoStack;

            num=numel(redostack);
            if num>0
                cmd=redostack(end);
            end
        end

        function add(hObj,cmd)

            if~isempty(hObj.Verbose)
                disp(tomcode(cmd))
            end

            stack=hObj.UndoStack;


            len=length(stack);
            if(~isempty(hObj.MaxUndoStackLength)&&len>=hObj.MaxUndoStackLength)
                stack=stack(2:end);
            end

            hObj.UndoStack=[stack;cmd];


            hObj.RedoStack=[];


            notify(hObj,'CommandStackChanged');
        end
    end
end
