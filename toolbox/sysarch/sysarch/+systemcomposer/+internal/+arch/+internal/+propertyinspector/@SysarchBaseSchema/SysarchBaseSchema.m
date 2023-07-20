classdef SysarchBaseSchema<handle











    properties(SetAccess=private)
SourceObject
        isPIReadOnly=false;
    end

    methods(Sealed)
        function obj=SysarchBaseSchema()
            obj.SourceObject=[];
        end
        function obj=setSchemaSource(obj,srcObj)
            obj.SourceObject=srcObj;
        end
        function makePIReadOnly(obj,bool)

            obj.isPIReadOnly=bool;
        end
        function enabled=isPropertyEnabled(obj,prop)
            enabled=false;


            if~obj.isSourceLive()||obj.isPIReadOnly
                return;
            end

            enabled=obj.isPropertyEnabledHook(prop);




            if isempty(obj.SourceObject)
                enabled=false;
            end
        end
        function editable=isPropertyEditable(obj,prop)
            editable=false;
            if~obj.isSourceLive()||obj.isPIReadOnly
                return;
            end

            editable=obj.isPropertyEditableHook(prop);




            if isempty(obj.SourceObject)
                editable=false;
            end
        end
        function isLive=isSourceLive(obj)


            isLive=true;
            if~isempty(obj.SourceObject)

                if ishandle(obj.SourceObject.Handle)
                    handle=obj.SourceObject.Handle;

                else
                    handle=obj.SourceObject.Parent;
                end
                blockDiagram=bdroot(handle);
                if Simulink.harness.internal.hasActiveHarness(blockDiagram)||...
                    Simulink.harness.isHarnessBD(blockDiagram)||...
                    strcmp(get_param(blockDiagram,'Lock'),'on')||...
                    systemcomposer.internal.isArchitectureLocked(blockDiagram)
                    isLive=false;
                end

                containingSubref=systemcomposer.internal.getContainingSubsystemReference(handle);
                if~isempty(containingSubref)&&systemcomposer.internal.isArchitectureLocked(...
                    get_param(containingSubref,'Handle'))
                    isLive=false;
                end
            end
        end
    end


    methods
        function enabled=isPropertyEnabledHook(obj,prop)%#ok<INUSD> 

            enabled=false;
        end
        function editable=isPropertyEditableHook(obj,prop)%#ok<INUSD> 

            editable=false;
        end
    end
end
