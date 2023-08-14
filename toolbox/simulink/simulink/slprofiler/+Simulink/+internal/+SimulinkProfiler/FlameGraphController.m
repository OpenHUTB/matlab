classdef FlameGraphController<handle




    properties
        component;

        RequiredHeight;


        Url;
        IndexFile='toolbox/mwflamegraph/index.html';


        source;
        Json='';
        RunLabel;
        currentType=Simulink.internal.SimulinkProfiler.ViewMode.EMPTY;



        ClientId;
        RootChannel;
        RequestChannel;
        PayloadChannel;
        LoadingChannel;
        LoadedChannel;
        RequestSubscriber=[];
        ConfirmationSubscriber=[];
    end

    methods(Access=public)


        function obj=FlameGraphController(component)
            obj.component=component;
            obj.reset();

        end

        function newUrl=reset(obj)
            obj.unsubscribeAll();
            connector.ensureServiceOn();
            connector.newNonce();
            obj.Url=connector.getUrl(obj.IndexFile);
            els=split(obj.Url,{'?','='});
            sncIdx=find(strcmpi(els,'snc'));
            obj.ClientId=els{sncIdx+1};
            obj.RootChannel=['/mwflamegraph/',obj.ClientId];
            obj.RequestChannel=[obj.RootChannel,'/request'];
            obj.PayloadChannel=[obj.RootChannel,'/payload'];
            obj.LoadingChannel=[obj.RootChannel,'/loading'];
            obj.LoadedChannel=[obj.RootChannel,'/loaded'];
            obj.RequestSubscriber=message.subscribe(obj.RequestChannel,...
            @obj.requestGraph);
            obj.ConfirmationSubscriber=message.subscribe(obj.LoadedChannel,...
            @obj.onCompletion);
            newUrl=obj.Url;
        end


        function obj=setData(obj,source,runLabel)


            if isa(source,'Simulink.internal.SimulinkProfiler.emptySource')
                newType=Simulink.internal.SimulinkProfiler.ViewMode.EMPTY;
            elseif isa(source.mData,'Simulink.internal.SimulinkProfiler.UIrow')
                newType=Simulink.internal.SimulinkProfiler.ViewMode.UI;
            elseif isa(source.mData,'Simulink.internal.SimulinkProfiler.ExecRow')
                newType=Simulink.internal.SimulinkProfiler.ViewMode.EXEC;
            end

            if newType==obj.currentType&&strcmp(runLabel,obj.RunLabel)
                return
            end


            obj.source=source;
            obj.currentType=newType;
            obj.RunLabel=runLabel;

            if~obj.component.DDGDialogSource.isSpreadsheet
                obj.calculateJson();
            end
        end

        function obj=refresh(obj)
            obj.startLoading();
            obj.requestGraph();
        end
    end

    methods(Access=private)



        function startLoading(obj)
            message.publish(obj.LoadingChannel,'start loading');
        end


        function calculateJson(obj)
            if obj.currentType~=Simulink.internal.SimulinkProfiler.ViewMode.EMPTY
                obj.Json=Simulink.internal.SimulinkProfiler.profile2json(...
                obj.source.mData,true);
            else
                obj.Json='';
            end
        end




        function obj=requestGraph(obj,varargin)
            obj.setData(obj.component.DDGDialogSource.sheetSource,...
            obj.component.DDGDialogSource.runLabel);

            message.publish(obj.PayloadChannel,obj.Json);
        end


        function obj=onCompletion(obj,msg)
            obj.RequiredHeight=msg;
        end


    end
    methods(Access=public)
        function delete(obj)
            obj.unsubscribeAll();
        end

        function unsubscribeAll(obj)
            message.unsubscribe(obj.RequestSubscriber);
            message.unsubscribe(obj.ConfirmationSubscriber);
        end
    end
end