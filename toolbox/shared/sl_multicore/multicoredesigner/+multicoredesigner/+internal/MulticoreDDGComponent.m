classdef MulticoreDDGComponent<multicoredesigner.internal.MulticoreDockableComponent





    events
DDGComponentCloseAction
    end

    methods

        function obj=MulticoreDDGComponent(uiObj,compName,source)
            obj=obj@multicoredesigner.internal.MulticoreDockableComponent(uiObj,compName,source);
            addlistener(obj.Component,"Closed",@(~,~)obj.handleCloseClicked);
        end

        function close(obj)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                obj.Component.DestroyOnHide=true;
            end
            obj.hide();
        end

        function delete(obj)

            if~isempty(obj.Data)&&isvalid(obj.Data)
                delete(obj.Data);
            end

            obj.Data=[];
        end

        function handleCloseClicked(obj)
            notify(obj,'DDGComponentCloseAction');
        end



        function comp=getComponentType(~)
            comp='GLUE2:DDGComponent';
        end

        function comp=createDockableComponent(obj)
            comp=GLUE2.DDGComponent(obj.Studio,obj.ComponentName,obj.Data);
        end

        function update(obj)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                updateContents(obj.Data);
                updateSource(obj.Component,obj.Data);
            end
        end

    end
end


