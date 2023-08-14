classdef BaseWidget<handle











    properties(Constant,Hidden)
        REL_URL='ui/composite_dv_widget_mi/index.html';
        DEBUG_URL='ui/composite_dv_widget_mi/index-debug.html';
        ChannelReady='ready';
        ChannelRenderWidget='renderWidget';
        ChannelWidgetCommunicator='widgetCommunicator';
    end


    properties(Access=protected)
        MoveOnResize=0;
        DialogHandle=[];
    end

    properties(Access=private)
        Diagnostics={};
        Position=[];
        Hint=[];
        UniqueId='';
        MessageService=[];
        OnExitCB function_handle=function_handle.empty;
        config=[];
    end

    methods(Abstract)
        dlg=getDialogSchema(this)
        transient=isTransient(this)
    end

    methods(Abstract,Access=protected)
        fitToContent(this,height)
    end


    methods(Access=public)
        function this=BaseWidget(diagnosticData,position,hint,config,varargin)

            if(isa(diagnosticData,'MException')||isa(diagnosticData,'MSLException')||isa(diagnosticData,'MSLDiagnostic'))

                diagnosticData=Simulink.output.DiagnosticWidgetData(diagnosticData);
            elseif(isa(diagnosticData,'Simulink.output.DiagnosticWidgetData'))

            else
                error(message('sl_diagnostic:SLMsgVieweri18N:CompositeDVWidgetInvalidType',class(diagnosticData)).getString());
            end


            this.Diagnostics=num2cell(diagnosticData);

            if(isnumeric(position))
                this.Position=position;
            else
                this.Position='auto';
            end

            if(isnumeric(hint))
                this.Hint=hint;
            else
                this.Hint=[1,1,1,1];
            end

            this.config=config;



            if(nargin==5)
                this.MoveOnResize=varargin{1};
            end


            this.UniqueId=num2str(randi(100000));
            this.MessageService=Simulink.output.utils.internal.MessageService(this.UniqueId);
        end



        function url=getUrl(this)
            if(isvalid(this))
                connector.ensureServiceOn;
                if(Simulink.output.utils.internal.BaseWidget.debugMode)
                    url=connector.getUrl(this.DEBUG_URL);
                else
                    url=connector.getUrl(this.REL_URL);
                end
                url=connector.applyNonce(url);
                url=[url,'&id=',this.UniqueId];
            end
        end


        function show(this)
            if(isvalid(this))

                this.MessageService.subscribe(this.ChannelReady,@(data)ready(this,data));
                this.MessageService.subscribe(this.ChannelWidgetCommunicator,@(data)eventHandler(this,data));

                if(Simulink.output.utils.internal.BaseWidget.debugMode)
                    disp('Call closeCallback method before clearing the workspace or deleting the widget object');
                    web(this.getUrl,'-browser');
                else
                    dlg=DAStudio.Dialog(this);
                    this.DialogHandle=dlg;
                    this.placeDialogAtSuitablePosition();
                    dlg.show;
                end
            end
        end

        function setClientCloseCallback(this,fh)
            this.OnExitCB=fh;
        end

        function closeCallback(this,~)
            if(isvalid(this))
                this.MessageService.unsubscribeAll();
                if(~isempty(this.OnExitCB))
                    this.OnExitCB();
                end
            end
        end

        function delete(this)
            this.closeCallback();
        end
    end

    methods(Hidden)
        function placeDialogAtSuitablePosition(this)
            screenInfo=get(0,'MonitorPositions');
            hint=this.Hint;
            widgetSize=[455,255];


            if(strcmp(this.Position,'auto'))

                mouseLoc=get(0,'PointerLocation');
                screenId=getScreenIndexForPoint(mouseLoc);
                currentScreenHeight=screenInfo(screenId,4);
                mouseLoc(2)=currentScreenHeight-mouseLoc(2);
                placeDialogInAvailableQuadrant(screenInfo(screenId,:),mouseLoc);
            else
                clickPos=this.Position;
                screenId=getScreenIndexForPoint(clickPos);

                if(screenId)
                    placeDialogInAvailableQuadrant(screenInfo(screenId,:),clickPos);
                end
            end

            function id=getScreenIndexForPoint(xy)
                id=0;

                for idx=1:size(screenInfo,1)
                    if(screenContainsPoint(screenInfo(idx,:),xy))
                        id=idx;
                        break;
                    end
                end
            end

            function out=screenContainsPoint(currentScreen,point)
                screenStartPos=currentScreen(1:2);
                screenWidth=currentScreen(3);
                screenHeight=currentScreen(4);
                out=le(screenStartPos(1),point(1))&&lt(point(1),screenStartPos(1)+screenWidth)&&le(screenStartPos(2),point(2))&&lt(point(2),screenStartPos(2)+screenHeight);
            end

            function placeDialogInAvailableQuadrant(screen,xy)


                widgetW=widgetSize(1);
                widgetH=widgetSize(2);
                posQ4=xy;
                posQ3=[xy(1)-widgetW,xy(2)];
                posQ2=[xy(1)-widgetW,xy(2)-widgetH];
                posQ1=[xy(1),xy(2)-widgetH];

                if(hint(4)&&screenContainsPoint(screen,posQ4)&&screenContainsPoint(screen,posQ4+widgetSize))
                    this.DialogHandle.position(1:2)=posQ4;
                elseif(hint(3)&&screenContainsPoint(screen,posQ3)&&screenContainsPoint(screen,posQ3+widgetSize))
                    this.DialogHandle.position(1:2)=posQ3;
                elseif(hint(2)&&screenContainsPoint(screen,posQ2)&&screenContainsPoint(screen,posQ2+widgetSize))
                    this.DialogHandle.position(1:2)=posQ2;
                elseif(hint(1)&&screenContainsPoint(screen,posQ1)&&screenContainsPoint(screen,posQ1+widgetSize))
                    this.DialogHandle.position(1:2)=posQ1;
                else

                    pos(1)=min(screen(1)+screen(3),xy(1)+widgetW)-widgetW;
                    pos(2)=min(screen(2)+screen(4),xy(2)+widgetH)-widgetH;
                    this.DialogHandle.position(1:2)=pos;
                end
            end
        end

        function ready(this,data)


            jsOut=this.formatDataToJS();
            this.MessageService.publish(this.ChannelRenderWidget,jsOut);
        end

        function out=formatDataToJS(this)
            out.diagnostic={};
            for i=1:length(this.Diagnostics)
                out.diagnostic{i}.diagnostic=this.Diagnostics{i}.Diagnostic;
                out.diagnostic{i}.severity=uint8(this.Diagnostics{i}.Severity);
                out.diagnostic{i}.component=this.Diagnostics{i}.Component;
                out.diagnostic{i}.category=this.Diagnostics{i}.Category;


                out.diagnostic{i}.helpIsAvailable=~isempty(this.Diagnostics{i}.HelpFcn);
                out.diagnostic{i}.suppressIsAvailable=~isempty(this.Diagnostics{i}.SuppressFcn);
                out.diagnostic{i}.restoreIsAvailable=~isempty(this.Diagnostics{i}.RestoreFcn);
            end
            out.config=jsonencode(this.config);
        end

        function eventHandler(this,aData)
            switch(aData{1})
            case 'setTransient'
                dataOut=struct();
                dataOut.resolveKey=aData{3};
                this.setDlgTransient(aData{2});
                this.MessageService.publish(this.ChannelWidgetCommunicator,dataOut);

            case 'fitToContent'
                dataOut=struct();
                dataOut.resolveKey=aData{3};
                this.fitToContent(aData{2});
                this.MessageService.publish(this.ChannelWidgetCommunicator,dataOut);

            case 'help'
                dataOut=struct();
                dataOut.resolveKey=aData{3};
                this.helpFcn(aData{2});
                this.MessageService.publish(this.ChannelWidgetCommunicator,dataOut);

            case 'suppress'
                dataOut=struct();
                dataOut.resolveKey=aData{4};
                this.suppressFcn(aData{2},aData{3});
                this.MessageService.publish(this.ChannelWidgetCommunicator,dataOut);


            case 'restore'
                dataOut=struct();
                dataOut.resolveKey=aData{3};
                this.restoreFcn(aData{2});
                this.MessageService.publish(this.ChannelWidgetCommunicator,dataOut);
            end
        end

        function helpFcn(this,index)
            this.Diagnostics{index}.HelpFcn();
            drawnow();
        end

        function suppressFcn(this,index,metaData)
            if this.config.Suppression.ClientHandlesJustification
                this.Diagnostics{index}.SuppressFcn();
            else
                this.Diagnostics{index}.SuppressFcn(metaData);
            end
        end

        function restoreFcn(this,index)
            this.Diagnostics{index}.RestoreFcn();
        end


        function setDlgTransient(this,status)
            if(~Simulink.output.utils.internal.BaseWidget.debugMode)
                this.DialogHandle.show();
                if(this.isTransient)
                    this.DialogHandle.setTransient(status);
                end
            end
        end

    end

    methods(Hidden,Static)

        function isDebug=debugMode(varargin)
            mlock;
            persistent IsDebug;

            if nargin>0
                IsDebug=varargin{1};
            elseif isempty(IsDebug)
                IsDebug=false;
            end

            isDebug=IsDebug;
        end
    end
end
