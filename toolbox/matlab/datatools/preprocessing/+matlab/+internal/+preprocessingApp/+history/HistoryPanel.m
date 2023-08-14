classdef HistoryPanel<matlab.internal.preprocessingApp.base.PreprocessingPanel



    properties
        GridLayout matlab.ui.container.GridLayout
        UITable matlab.ui.control.Table
        View matlab.internal.preprocessingApp.history.HistoryView
    end

    properties
        ViewHistoryChangedFcn=[];
        ViewHistoryRequestedFcn=[];
        ViewOpenModeCallbackFcn=[];
        ViewDeleteStepCallbackFcn=[];
        ViewInsertCallbackFcn=[];
    end

    methods
        function this=HistoryPanel(varargin)
            this@matlab.internal.preprocessingApp.base.PreprocessingPanel(varargin{:});
            set(this.Figure,'Color',[1,1,1,]);
            this.GridLayout=uigridlayout(this.Figure,[1,1],'Padding',[0,0,0,0]);
            this.setupView();
        end

        function enableUpdateInteractions(this)
            this.View.removeBusyIndicatorOnClient();
        end

        function disableUpdateInteractions(this)
            this.View.setBusyIndicatorOnClient();
        end

    end

    methods(Access='private')

        function setupView(this)
            this.View=matlab.internal.preprocessingApp.history.HistoryView('Parent',this.GridLayout,'Tag','DataCleanerHistoryView');
            this.addViewListeners();
        end
    end

    methods(Access='protected')
        function addViewListeners(this)
            this.View.HistoryRequestedFcn=@(msg)this.notifyHistoryRequested();
            this.View.HistoryChangedFcn=@(msg)this.notifyHistoryChanged(msg);
            this.View.OpenModeCallbackFcn=@(msg)this.notifyOpenMode(msg);
            this.View.DeleteStepCallbackFcn=@(msg)this.notifyDeleteStep(msg);
            this.View.InsertCallbackFcn=@(type,msg)this.notifyInsert(type,msg);
        end

        function notifyHistoryRequested(this)

            if~isempty(this.ViewHistoryRequestedFcn)
                try
                    this.ViewHistoryRequestedFcn();
                catch e
                    disp(e)
                end
            end
        end

        function notifyHistoryChanged(this,message)
            data=message.data;
            for i=1:length(data)
                data(i).Enabled=data(i).checked;
            end


            data=removeExcessFields(data);


            if~isempty(this.ViewHistoryChangedFcn)
                try
                    this.ViewHistoryChangedFcn(data);
                catch e
                    disp(e)
                end
            end
        end

        function notifyOpenMode(this,message)
            data=message.data;
            data=cleanUpClientSteps(data);


            if~isempty(this.ViewOpenModeCallbackFcn)
                try
                    this.ViewOpenModeCallbackFcn(data);
                catch e
                    disp(e)
                end
            end
        end

        function notifyDeleteStep(this,message)
            data=message.data;
            data=cleanUpClientSteps(data);


            if~isempty(this.ViewDeleteStepCallbackFcn)
                try
                    this.ViewDeleteStepCallbackFcn(data);
                catch e
                    disp(e)
                end
            end
        end

        function notifyInsert(this,type,message)
            data=message.data.step;
            data.Enabled=data.checked;
            task=message.data.task;


            data=removeExcessFields(data);


            if~isempty(this.ViewInsertCallbackFcn)
                try
                    this.ViewInsertCallbackFcn(type,data,task);
                catch e
                    disp(e)
                end
            end
        end

    end

    methods
        function setHistory(this,data)

            for i=1:length(data)
                data(i).id=string(data(i).ID);
                data(i).label=data(i).DisplayName;
                data(i).checked=data(i).Enabled;
                data(i).index=i;
                data(i).parent=NaN;
                data(i).iconUri=matlab.internal.preprocessingApp.PreprocessingApp.getIconForStep(data(i).DisplayName);
            end


            this.View.setHistory(data);
        end

        function setSelection(this,selection)
            data.nodeIds=selection;
            this.View.setSelection(data);
        end

        function setTasks(this,tasks)
            this.View.setTasks(tasks);
        end

        function delete(this)
            this.View.delete();
        end


        function data=testRemoveExcessFields(~,clientData)
            data=removeExcessFields(clientData);
        end
    end
end

function data=removeExcessFields(clientData)

    data=rmfield(clientData,...
    {'id','label','checked','index','parent','iconUri'});
end

function data=cleanUpClientSteps(data)
    currentStep=data.currentStep;
    steps=data.steps;


    currentStep.Enabled=currentStep.checked;

    currentStep=removeExcessFields(currentStep);

    for i=1:length(steps)
        steps(i).Enabled=steps(i).checked;
    end

    if~isempty(steps)
        steps=removeExcessFields(steps);
    end

    data.steps=steps;
    data.currentStep=currentStep;
end

