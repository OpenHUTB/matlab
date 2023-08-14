

classdef SessionsController<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='SessionsController';
    end

    events
NewSessionComplete
DirtyStateChanged
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.SessionsController(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=SessionsController(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.SessionsController;

            this.Dispatcher.subscribe(...
            [SessionsController.ControllerID,'/','newsession'],...
            @(arg)cb_NewSession(this,arg));
            this.Dispatcher.subscribe(...
            [SessionsController.ControllerID,'/','closelabeler'],...
            @(arg)cb_CloseLabeler(this,arg));
        end
    end

    methods(Hidden)



        function cb_NewSession(this,args)

            wasDirty=this.Model.isDirty();


            this.Model.resetModel();


            signal.labeler.SignalUtilities.deleteAllSLRuns();


            this.notify('NewSessionComplete',signal.internal.SAEventData(struct('clientID',args.clientID)));

            if wasDirty

                this.changeAppTitle(this.Model.isDirty());

                this.notify('DirtyStateChanged',signal.internal.SAEventData(struct('clientID',str2double(args.clientID))));
            end
        end

        function cb_CloseLabeler(~,~)
            signal.labeler.Instance.gui().completeCloseOperation();
        end
    end


    methods
        function changeAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end
    end
end
