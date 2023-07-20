classdef TETMonitor<handle













    properties(Constant)
        RELEASE_URL='toolbox/slrealtime/web/tet/index.html';
        DEBUG_URL='toolbox/slrealtime/web/tet/index-debug.html';
    end

    methods(Access={?slrealtime.TETMonitor})



        function obj=TETMonitor()
            obj.dlgUUID=char(matlab.lang.internal.uuid);
            obj.dataChannel=strcat('/',obj.dlgUUID,'/Data');
            obj.statusChannel=strcat('/',obj.dlgUUID,'/Status');
            obj.geometry=[60,60,700,325];
            obj.targetMap=containers.Map('KeyType','char','ValueType','any');

            tgs=slrealtime.Targets;
            obj.nameChangedListener=addlistener(tgs,'TargetNameChanged',@(o,e)nameChangedCB(obj,e));



            obj.commReady=false;




            connector.ensureServiceOn;
            obj.subscription=message.subscribe(obj.statusChannel,@(msg)obj.handleMessage(msg));
        end
    end

    methods(Access=public)



        function handleMessage(this,msg)
            if strcmp(msg,'started')


                this.commReady=true;




                if~this.targetMap.isempty
                    targetNames=this.targetMap.keys;
                    targetObjs=this.targetMap.values;
                    for i=1:length(targetNames)
                        message.publish(this.dataChannel,...
                        {'addTarget',...
                        {targetNames{i},targetObjs{i}.targetUUID}...
                        });


                        try
                            tg=slrealtime(targetNames{i});
                            tg.enableTETStreamingToSDIDueToTETMonitor();
                        catch


                        end
                    end
                end
            end
        end

        function url=getUrlForTesting(this)
            url=this.getUrl();
        end

        function comm=getCommForTesting(this)
            comm=this.commReady;
        end

        function add(this,targetName)

            if this.targetMap.isKey(targetName)
                return;
            end

            t=slrealtime.internal.TETMonitorTarget(targetName);
            this.targetMap(targetName)=t;

            if this.commReady
                message.publish(this.dataChannel,...
                {'addTarget',...
                {targetName,t.targetUUID}...
                });


                try
                    tg=slrealtime(targetName);
                    tg.enableTETStreamingToSDIDueToTETMonitor();
                catch


                end
            end
        end

        function remove(this,targetName)

            if~this.targetMap.isKey(targetName)
                return;
            end

            delete(this.targetMap(targetName));
            this.targetMap.remove(targetName);

            if this.commReady
                message.publish(this.dataChannel,...
                {'removeTarget',...
                {targetName}...
                });


                try
                    tg=slrealtime(targetName);
                    tg.disableTETStreamingToSDIDueToTETMonitor();
                catch


                end
            end
        end

        function activate(this,targetName,modelName,tetInfo)

            if~this.targetMap.isKey(targetName)
                return;
            end

            t=this.targetMap(targetName);
            t.activate(modelName,tetInfo);
        end

        function deactivate(this,targetName)

            if~this.targetMap.isKey(targetName)
                return;
            end

            t=this.targetMap(targetName);
            t.deactivate();
        end

        function runOnce(this,targetName,tetInfo)

            if~this.targetMap.isKey(targetName)
                return;
            end

            t=this.targetMap(targetName);
            t.runOnce(tetInfo);
        end

        function nameChangedCB(this,e)
            this.remove(e.oldName);
            this.add(e.newName);
        end

        function show(this)
            if 0
                web(this.getUrl(),'-browser');
            else
                if isempty(this.dialog)
                    this.dialog=eval('DAStudio.Dialog(this)');
                end
                this.dialog.show();
            end
        end

        function delete(this)
            message.unsubscribe(this.subscription);
            this.closeDlg();
            delete(this.nameChangedListener);
        end

        function closeDlg(this,varargin)


            if nargin==1
                isaExplorerTab=false;
            elseif nargin==2
                isaExplorerTab=varargin{1};
            end

            this.commReady=false;

            if(~isempty(this.dialog)&&ishandle(this.dialog))||isaExplorerTab
                if~isaExplorerTab
                    this.geometry=this.dialog.position;
                    delete(this.dialog);
                end


                keys=this.targetMap.keys;
                for i=1:length(keys)
                    try
                        tg=slrealtime(keys{i});
                        tg.disableTETStreamingToSDIDueToTETMonitor();
                    catch


                    end
                end
            end
            if~isaExplorerTab
                this.dialog=[];
            end

            keys=this.targetMap.keys;
            for i=1:length(keys)
                t=this.targetMap(keys{i});
                t.commReady=false;
                t.dataReady=false;
            end
        end

        function dlg=getDialogSchema(this)
            webbrowser.Type='webbrowser';
            webbrowser.Tag='tet_webbrowser';
            webbrowser.Url=this.getUrl();

            dlg.DialogTitle=DAStudio.message('slrealtime:tetMonitor:tetMonitorDialogTitle');
            dlg.Items={webbrowser};
            dlg.StandaloneButtonSet={''};
            dlg.IsScrollable=false;
            dlg.DispatcherEvents={};
            dlg.ExplicitShow=true;
            dlg.IgnoreESCClose=true;
            dlg.CloseCallback='slrealtime.TETMonitor.close';



            if ispc||ismac
                dlg.MinMaxButtons=true;
            end

            if~isempty(this.geometry)
                dlg.Geometry=this.geometry;
            end
        end
    end

    methods(Access=private,Hidden)



        function url=getUrl(this)


            url=connector.getUrl(slrealtime.internal.TETMonitor.RELEASE_URL);
            url=[url,sprintf('&dlgUUID=%s',this.dlgUUID)];
        end
    end



    properties(Hidden)
        dlgUUID;
        commReady;
        subscription;
        dataChannel;
        statusChannel;
        dialog;
        geometry;
        targetMap;
        nameChangedListener;
    end

end
