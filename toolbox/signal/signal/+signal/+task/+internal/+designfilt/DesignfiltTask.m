classdef(Hidden=true)DesignfiltTask<signal.task.internal.BaseTask




    properties(Hidden,Transient)

AppModel

AppView

FigureDestroyedListener
    end

    properties(Hidden,Transient,Constant)



        RESPONSELIST=[...
        "lowpassfir";...
        "highpassfir";...
        "bandpassfir";...
        "bandstopfir";...
        "hilbertfir";...
        "differentiatorfir";...
        "lowpassiir";...
        "highpassiir";...
        "bandpassiir";...
        "bandstopiir";];
    end

    methods
        function this=DesignfiltTask()


            this.AppModel=signal.task.internal.designfilt.DesignfiltTaskModel;
            responseViewChangedCallback=@(src,evtData)onResponseViewChanged(this,evtData);
            this.AppView=signal.task.internal.designfilt.DesignfiltTaskView(responseViewChangedCallback,this.RESPONSELIST);

            this.UIFigure=getAppContainer(this.AppView);


            installListeners(this);


            setVisible(this.AppView,true);
        end

        function delete(this)
            delete(this.UIFigure);
            deleteListeners(this);
        end
    end


    methods
        function[code,outputs]=generateScript(this)


            code='';
            outputs={};
            if isReadyForScript(this)
                [code,outputs]=generateScript(this.AppModel);
            end
        end

        function code=generateVisualizationScript(this)



            code='';
            if isReadyForScript(this)
                code=generateVisualizationScript(this.AppModel);
            end
        end

        function summary=generateSummary(this)


            summary=generateSummary(this.AppModel);
        end

        function taskState=getState(this)


            taskState=getState(this.AppModel);
        end

        function setState(this,taskState)


            prevResponse=this.AppModel.Response;
            setState(this.AppModel,taskState);
            newResponse=this.AppModel.Response;

            evtData.PreviousResponse=prevResponse;
            evtData.Value=true;
            evtData.Source.UserData=newResponse;

            updateResponseView(this,evtData);


            updateViewFilterAnalysisControlsState(this.AppView,taskState);
        end

        function reset(this)




            reset(this.AppView);
            reset(this.AppModel);

            evtData.Value=this.AppModel.Response;
            viewSettings=updateModelAndGetViewSettings(this.AppModel,'response',evtData);
            updateView(this.AppView,viewSettings)
        end

        function update(~,~)


        end
    end

    methods(Access=protected)
        function installListeners(this)

            this.FigureDestroyedListener=event.listener(this.UIFigure,...
            'ObjectBeingDestroyed',@(~,~)delete(this));


            synchronizeWidgetWithModel(this,'MagAndPhaseButton','ViewMagAndPhase');
            synchronizeWidgetWithModel(this,'GroupDelayButton','ViewGroupDelay');
            synchronizeWidgetWithModel(this,'PhaseDelayButton','ViewPhaseDelay');
            synchronizeWidgetWithModel(this,'ImpulseResponseButton','ViewImpulseResponse');
            synchronizeWidgetWithModel(this,'StepResponseButton','ViewStepResponse');
            synchronizeWidgetWithModel(this,'PZPlotButton','ViewPZPlot');
            synchronizeWidgetWithModel(this,'FilterInfoButton','ViewFilterInfo');

            for idx=1:numel(this.RESPONSELIST)
                synchronizeWidgetWithModel(this,this.RESPONSELIST(idx),'Response');
            end
        end

        function deleteListeners(this)
            delete(this.FigureDestroyedListener);
        end

        function synchronizeWidgetWithModel(this,widgetName,modelVarName)
            cbFcn=@(src,ed)onWidgetValueChanged(this,modelVarName,ed);
            this.AppView.setValueChangedCallback(widgetName,cbFcn);
        end


        function onWidgetValueChanged(this,modelVarName,evtData)

            switch modelVarName
            case 'Response'
                updateResponseView(this,evtData);
            otherwise
                this.AppModel.(modelVarName)=evtData.Value;
                notify(this,"Changed");
            end
        end

        function updateResponseView(this,evtData)

            model=this.AppModel;

            resp=evtData.Source.UserData;
            if evtData.Value
                newEvtData.Value=resp;
            else
                newEvtData.Value="select";
            end


            drawnow nocallbacks
            updateResponseButtons(this.AppView,newEvtData.Value);
            drawnow nocallbacks

            if isstruct(evtData)&&isfield(evtData,'PreviousResponse')
                prevResponse=evtData.PreviousResponse;
            else
                prevResponse=model.Response;
            end




            viewSettings=updateModelAndGetViewSettings(model,'response',newEvtData);
            actResponse=newEvtData.Value;


            updateView(this.AppView,viewSettings,'response',prevResponse,actResponse);
        end




        function onResponseViewChanged(this,evtData)
            whatChanged=evtData.Data.WhatChanged;

            viewSettings=updateModelAndGetViewSettings(...
            this.AppModel,whatChanged,evtData.Data.EventData);


            updateView(this.AppView,viewSettings,whatChanged);





            notify(this,"Changed");
        end

        function flag=isReadyForScript(this)

            flag=isReadyForScript(this.AppView)&&...
            isReadyForScript(this.AppModel);
        end
    end
end

