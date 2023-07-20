classdef SigHierDialog<handle

    properties(Hidden)
portHandle
modelHandle
x
y
hostInfo
URL
Geometry
Dialog
selectedSignals
sparkline
studio
    end

    methods

        function obj=SigHierDialog(portHndl,modelHandle,x,y,studio,sparkline,debug)
            tic;
            obj.portHandle=portHndl;
            obj.modelHandle=modelHandle;
            obj.x=x;
            obj.y=y;
            obj.sparkline=sparkline;
            if isempty(studio)
                studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                obj.studio=studios(1);
            else
                obj.studio=studio;
            end
            connector.ensureServiceOn;
            if debug
                html='index-debug.html';
            else
                html='index.html';
            end
            obj.URL=connector.getBaseUrl(['/toolbox/simulink/simulink/pvdbussignalselector/',html,'?modelHdl=',num2str(modelHandle,'%.15f'),...
            '&portHdl=',num2str(portHndl,'%.15f')]);

            obj.Dialog=DAStudio.Dialog(obj);
            obj.show;
        end


        function geometry=getDialogGeometry(obj)
            if(obj.x==0&&obj.y==0)
                e=obj.studio.App.getActiveEditor;
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

            width=200;
            height=250;

            geometry=[dlgX,dlgY,width,height];
        end


        function dlg=getDialogSchema(obj)
            webbrowser.Type='webbrowser';
            webbrowser.Url=connector.applyNonce(obj.URL);
            webbrowser.WebKit=true;

            dlg.DialogTitle='';
            dlg.Items={webbrowser};
            dlg.StandaloneButtonSet={''};
            dlg.IsScrollable=false;
            dlg.DispatcherEvents={};
            dlg.ExplicitShow=true;
            dlg.HideOnClose=true;
            dlg.Transient=true;
            dlg.DialogStyle='resizableframeless';
            dlg.PostApplyCallback='Simulink.internal.SigHierDialogCB';
            dlg.PostApplyArgs={obj,'applyCB'};


            dlg.Geometry=obj.getDialogGeometry;
        end


        function show(obj)
            if~ishandle(obj.Dialog)
                obj.Dialog=DAStudio.Dialog(obj);
            else
                obj.Dialog.show();
            end
        end


        function delete(obj)


            if~isempty(obj.Dialog)&&ishandle(obj.Dialog)
                delete(obj.Dialog);
            end
        end
    end
end
