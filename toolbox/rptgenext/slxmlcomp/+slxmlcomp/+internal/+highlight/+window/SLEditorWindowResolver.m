classdef SLEditorWindowResolver<slxmlcomp.internal.highlight.window.WindowResolver




    properties(Access=private)
Delegates
        SimulinkTypes=["System","Annotation","Block","Line"]
    end

    methods(Access=public)

        function obj=SLEditorWindowResolver()

            import slxmlcomp.internal.highlight.window.*
            obj.Delegates={...
            StateflowWindowResolver(),...
            TruthTableWindowResolver(),...
            };

        end

        function windowInfo=getInfo(obj,location)

            for delegate=obj.Delegates
                windowInfo=delegate{1}.getInfo(location);
                if~isempty(windowInfo)
                    return
                end
            end

            windowId='';
            windowType='';

            if any(obj.SimulinkTypes==location.Type)
                windowType="Simulink";
                strLocation=string(location.Location);
                if strLocation.contains("/")
                    windowId=strLocation.extractBefore("/");
                else
                    windowId=strLocation;
                end
            end

            if(~isempty(windowType))
                windowInfo.Id=windowId;
                windowInfo.Type=windowType;
            else
                windowInfo=[];
            end

        end

    end

end
