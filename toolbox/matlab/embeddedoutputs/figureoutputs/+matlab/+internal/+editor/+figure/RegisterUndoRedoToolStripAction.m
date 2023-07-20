
classdef(Abstract)RegisterUndoRedoToolStripAction<handle


    methods


        function registerUndoToolstripActions(this,axesIndex,fig,actionID,objectPrevState,objectNextState,varargin)


            cmd=matlab.uitools.internal.uiundo.FunctionCommand;
            addprop(cmd,'prevState');
            addprop(cmd,'nextState');



            cmd.prevState=objectPrevState;
            cmd.nextState=objectNextState;



            cmd.Name=sprintf('Insert%s',actionID);
            cmd.Function=@this.redoToolstripAction;
            cmd.InverseFunction=@this.undoToolstripAction;
            cmd.Varargin={axesIndex,fig,actionID,cmd,varargin{:}};
            cmd.InverseVarargin={axesIndex,fig,actionID,cmd,varargin{:}};


            uiundo(fig,'function',cmd);
        end

    end
    methods(Abstract)





        undoToolstripAction(~,axesIndex,fig,actionID,cmd,varargin)






        redoToolstripAction(~,axesIndex,fig,actionID,cmd,varargin)
    end
end