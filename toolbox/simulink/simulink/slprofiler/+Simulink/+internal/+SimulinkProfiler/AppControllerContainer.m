classdef AppControllerContainer<handle



    properties(Constant,Access=private)
        Instance=Simulink.internal.SimulinkProfiler.AppControllerContainer();
    end

    properties(GetAccess=private,SetAccess=immutable)
        HandleToControllerMap;
    end

    methods(Access=private)
        function obj=AppControllerContainer()
            mlock;
            obj.HandleToControllerMap=containers.Map('KeyType','double','ValueType','any');
        end

        function data=get(this,modelHandle,studio,app)
            if this.HandleToControllerMap.isKey(modelHandle)
                data=this.HandleToControllerMap(modelHandle);
            elseif~(isempty(studio))

                controller=Simulink.internal.SimulinkProfiler.AppController(studio,app);
                listener=Simulink.listener(modelHandle,...
                'CloseEvent',...
                @i_closeCallback);
                data=struct('Controller',controller,'CloseListener',listener);
                this.HandleToControllerMap(modelHandle)=data;
            else

                data=struct('Controller',[],'CloseListener',[]);
            end
        end

        function remove(this,modelHandle)
            if this.HandleToControllerMap.isKey(modelHandle)
                data=this.HandleToControllerMap(modelHandle);
                this.HandleToControllerMap.remove(modelHandle);
                delete(data.CloseListener);
                delete(data.Controller);
            end
        end
    end

    methods(Access=public,Static)
        function controller=getController(modelHandle,studio,app)
            if nargin<2
                studio=[];
                app=[];
            elseif nargin<3
                app=[];
            end

            appInstanceContainer=Simulink.internal.SimulinkProfiler.AppControllerContainer.Instance;
            data=appInstanceContainer.get(modelHandle,studio,app);
            controller=data.Controller;
        end

    end



end

function i_closeCallback(event,~)
    wb=Simulink.internal.SimulinkProfiler.AppController.getWaitBar(DAStudio.message('Simulink:Profiler:ClearingData'));%#ok<NASGU>
    container=Simulink.internal.SimulinkProfiler.AppControllerContainer.Instance;
    container.remove(event.Handle);
end


