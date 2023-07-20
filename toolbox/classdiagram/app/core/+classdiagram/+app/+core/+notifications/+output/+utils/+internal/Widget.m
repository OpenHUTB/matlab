classdef Widget<handle


    properties(Constant,Hidden)
        ChannelReady='ready';
        ChannelRenderWidget='renderWidget';
        ChannelDestroyWidget='destroyWidget';
        ChannelWidgetCommunicator='widgetCommunicator';
    end

    properties(Access={...
        ?classdiagram.app.core.notifications.output.DiagnosticWidget,...
        ?classdiagram.app.core.notifications.output.utils.internal.Widget,...
        })
        Diagnostics={};
    end

    properties(Access=private)
        DialogHandle=[];
        Position=[];
        Hint=[];
        UniqueId='';
        MessageService=[];
        MoveOnResize=0;
        Config=[];
        OnExitCB function_handle=function_handle.empty;
    end

    methods(Access=public)
        function this=Widget(targetUuid,diagnosticData,position,hint,config,varargin)
            this.UniqueId=char(targetUuid);

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

            this.Config=config;



            if(nargin==5)
                this.MoveOnResize=varargin{1};
            end


            this.MessageService=classdiagram.app.core.notifications.output.utils.internal.MessageService(this.UniqueId);
        end

        function start(this)
            if(isvalid(this))

                this.MessageService.subscribe(this.ChannelReady,@(data)ready(this,data));
                this.MessageService.subscribe(this.ChannelWidgetCommunicator,@(data)eventHandler(this,data));
                this.MessageService.subscribe(this.ChannelDestroyWidget,@(data)delete(this));
            end
        end

        function addNotification(this,toAdd)

            if~isvalid(this)
                return;
            end
            notifs=[this.Diagnostics{:}];

            notifValues=[string(notifs.Notification.Message)];
            addValues=[string(toAdd.Message)];
            idx=ismember(addValues,notifValues);
            if all(idx)

                return;
            end
            this.Diagnostics{end+1}={toAdd(~idx)};
            this.Diagnostics=[this.Diagnostics{:}];

            this.ready([]);
        end

        function removeNotification(this,options)


            if~isvalid(this)
                return;
            end
            notifs=[this.Diagnostics{:}];
            toRemove={};
            if isfield(options,'uuids')
                toRemove=options.uuids;
                if isa(toRemove,'cell')
                    toRemove=[toRemove{:}];
                end

                notifValues=[notifs.Notification.uuid];
            elseif isfield(options,'categories')
                toRemove=options.categories;
                notifValues=arrayfun(@(n)string(class(n)),notifs.Notification);
            end
            if isfield(options,'not')&&options.not
                idx=~ismember(notifValues,toRemove);
            else
                idx=ismember(notifValues,toRemove);
            end
            if all(~idx)

                return;
            end
            this.Diagnostics={notifs(~idx)};

            if~this.isEmptyDiagnostics

                this.ready([]);
            end
        end

        function bool=isEmptyDiagnostics(this)
            bool=~isvalid(this)||isempty(this.Diagnostics)||~numel(this.Diagnostics{:});
        end

        function setClientCloseCallback(this,fh)
            this.OnExitCB=fh;
        end

        function closeCallback(this,~)
            this.MessageService.publish(this.ChannelDestroyWidget,'destroy');
            this.MessageService.unsubscribeAll();
            if(~isempty(this.OnExitCB))
                this.OnExitCB();
            end
        end

        function delete(this)
            this.closeCallback();
        end
    end

    methods(Hidden)
        function ready(this,data)


            jsOut=this.formatDataToJS();
            this.MessageService.publish(this.ChannelRenderWidget,jsOut);
        end

        function out=formatDataToJS(this)
            out={};
            for i=1:length(this.Diagnostics)


                out.notif{i}.message=this.Diagnostics{i}.Message;
                out.notif{i}.severity=uint8(this.Diagnostics{i}.Severity);
                out.notif{i}.category=this.Diagnostics{i}.Category;


                out.notif{i}.helpIsAvailable=~isempty(this.Diagnostics{i}.HelpFcn);
                out.notif{i}.suppressIsAvailable=~isempty(this.Diagnostics{i}.SuppressFcn);
            end
            out.config=jsonencode(this.Config);
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
                dataOut.resolveKey=aData{3};
                this.suppressFcn(aData{2});
                this.MessageService.publish(this.ChannelWidgetCommunicator,dataOut);
            end
        end

        function helpFcn(this,index)
            this.Diagnostics{index}.HelpFcn();
            drawnow();
        end

        function suppressFcn(this,index)
            this.Diagnostics{index}.SuppressFcn();
        end

        function setDlgTransient(this,status)
            if(~classdiagram.app.core.notifications.output.utils.internal.Widget.debugMode)
                this.DialogHandle.show();
                this.DialogHandle.setTransient(status);
            end
        end

        function fitToContent(this,height)
            if(~classdiagram.app.core.notifications.output.utils.internal.Widget.debugMode)
                pos=this.DialogHandle.position;
                y=pos(2);
                if(this.MoveOnResize)


                    y=y+250-height;
                end
                this.DialogHandle.position=[pos(1),y,pos(3),height];
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
