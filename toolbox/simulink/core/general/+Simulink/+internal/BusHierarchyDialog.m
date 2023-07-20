




classdef BusHierarchyDialog<handle

    properties(Hidden)
portHandle
modelHandle
x
y
hostInfo
URL
Geometry
Dialog
studio
compileListener
selectionListener
m
lastActiveEditor
    end

    properties
unlocked
    end
    methods

        function obj=BusHierarchyDialog(portHndl,modelHandle,x,y)
            obj.portHandle=portHndl;
            obj.modelHandle=modelHandle;
            obj.x=x;
            obj.y=y;
            editors=SLM3I.SLDomain.getAllEditorsForBlockDiagram(modelHandle);
            obj.lastActiveEditor=editors(1);
            obj.unlocked=true;
            connector.ensureServiceOn;
            try
                if obj.isDebug()
                    html='index-debug.html';
                else
                    html='index.html';
                end
            catch ex
                disp(ex);
            end
            obj.URL=connector.getBaseUrl(['/toolbox/simulink/signal_hierarchy_dialog/',html,'?modelHdl=',num2str(modelHandle,'%.15f'),...
            '&portHdl=',num2str(portHndl,'%.15f')]);
            obj.Dialog=DAStudio.Dialog(obj);

            obj.m=get_param(modelHandle,'InternalObject');
            obj.compileListener=addlistener(obj.m,'SLCompEvent::PRE_INACTIVE_VARIANT_REMOVAL',...
            @(~,~)Simulink.internal.BusHierarchyDialogMgr.compileCallBack(modelHandle,obj.portHandle));
            obj.selectionListener=Simulink.listener(get_param(modelHandle,'Object'),'SelectionChangeEvent',...
            @(h,ev)updateSelection(h,ev,obj,false));
            obj.show;
        end


        function geometry=getDialogGeometry(obj)
            if(obj.x==0&&obj.y==0)
                e=obj.lastActiveEditor;
                canvasPos=e.getCanvas.GlobalPosition;
                sceneRect=e.getCanvas.SceneRectInView;
                scale=e.getCanvas.Scale;
                position=get_param(obj.portHandle,'Position');
                dlgX=(position(1)-sceneRect(1))*scale+canvasPos(1)+5;
                dlgY=(position(2)-sceneRect(2))*scale+canvasPos(2)+5;
            else
                dlgX=obj.x+5;
                dlgY=obj.y+5;
            end

            width=300;
            height=325;

            geometry=[dlgX,dlgY,width,height];
        end


        function dlg=getDialogSchema(obj)
            webbrowser.Type='webbrowser';
            webbrowser.Url=connector.applyNonce(obj.URL);
            webbrowser.WebKit=true;
            webbrowser.EnableInspectorOnLoad=obj.isDebug();

            dlg.DialogTitle='Signal Hierarchy Viewer';
            dlg.StandaloneButtonSet={''};
            dlg.IsScrollable=false;
            dlg.DispatcherEvents={};
            dlg.ExplicitShow=true;
            dlg.DialogStyle='normal';
            dlg.CloseCallback='Simulink.internal.BusHierarchyDialogCB';
            dlg.CloseArgs={obj};
            dlg.Items={webbrowser};
            dlg.Geometry=obj.getDialogGeometry;
        end


        function show(obj)
            if~ishandle(obj.Dialog)
                obj.Dialog=DAStudio.Dialog(obj);
            else
                obj.Dialog.show();
            end
        end

        function updateSelection(obj,~)

            if(get_param(gcs,'CurrentOutputPort'))
                if(obj.unlocked)
                    obj.portHandle=get_param(gcs,'CurrentOutputPort');
                    Simulink.internal.BusHierarchyDialogMgr.changeSignal(obj.modelHandle,obj.portHandle);
                end
            end
        end


        function delete(obj)

            if~isempty(obj.Dialog)&&ishandle(obj.Dialog)
                delete(obj.Dialog);
                delete(obj.compileListener);
                delete(obj.selectionListener);
            end
        end
    end
    methods(Static)


        function value=isDebug()
            value=false;
        end
    end
end
