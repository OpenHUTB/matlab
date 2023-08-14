classdef TimingLegend<handle




    properties(Constant)
        title="Timing Legend";
        id="Timing Info";
        comp='GLUE2:DDG Component';
        tag='Tag_TimingLegend';
        channel='timing_legend';
    end

    properties
Url
debugUrl
modelHandle
    end

    properties(Hidden)
Component
        debugMode=true
Studio
Subscribe
    end

    methods
        function obj=TimingLegend(modelHandle)
            if slfeature('RefactorTimingVisualization')>0
                obj.modelHandle=modelHandle;
                obj.init();
                obj.show();
            end
        end

        function delete(obj)
            obj.Studio.destroyComponent(obj.Component);
        end

        function dlg=getDialogSchema(obj)
            main.Type='webbrowser';
            main.Name=obj.title;
            main.Tag=obj.tag;
            main.DialogRefresh=false;
            main.Graphical=true;
            main.Url=generateUrl(obj);

            if obj.debugMode
                main.DisableContextMenu=true;
                main.EnableInspectorInContextMenu=true;
                main.EnableInspectorOnLoad=true;
            else
                main.DisableContextMenu=true;
            end

            dlg.DialogTitle='';
            dlg.Items={main};
            dlg.DialogMode='Slim';
            dlg.StandaloneButtonSet={''};
            dlg.EmbeddedButtonSet={''};
            dlg.DialogTag=[obj.tag,'_Dialog'];

            dlg.IsScrollable=true;
        end

        function init(obj)
            obj.debugMode=slsvTestingHook('TimingLegendDebug');
            obj.Url=generateUrl(obj);
            obj.debugUrl=generateUrl(obj);


            obj.Subscribe=message.subscribe(['/',obj.channel],@obj.callback);


            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

            obj.Studio=studios(1);

            obj.Component=GLUE2.DDGComponent(obj.Studio,obj.id,obj);
            obj.Studio.registerComponent(obj.Component);
        end

        function url=generateUrl(obj)
            path='/toolbox/simulink/timinglegend/web/';
            modelHandleStr=num2str(obj.modelHandle,'%.30g');
            if obj.debugMode
                url=connector.getUrl([path,'index-debug.html?snc=dev&modelHandle=',modelHandleStr]);
            else
                url=connector.getUrl([path,'index.html']);
                url=[url,'&modelHandle=',modelHandleStr];
            end

        end

        function show(obj)

            obj.Studio.moveComponentToDock(obj.Component,obj.title,'Right','Tabbed');

            obj.Component.ShowMinimized=false;
            obj.Studio.showComponent(obj.Component);
        end
    end
end
