classdef SLEditorClassicStyler<handle




    methods(Access=public)

        function obj=SLEditorClassicStyler()

        end

        function applyAttentionStyle(obj,location)
            if location.Type=="stateflow"
                obj.applyAttentionStyleSF(location);
            else
                obj.applyAttentionStyleSL(location);
            end
        end

        function removeAttentionStyle(obj,location)
            if location.Type=="stateflow"
                obj.removeAttentionStyleSF(location);
            else
                obj.removeAttentionStyleSL(location);
            end
        end

    end

    methods(Access=private)

        function applyAttentionStyleSL(~,location)
            resolver=slxmlcomp.internal.highlight.SimulinkHandleResolver();
            objectHandle=resolver.resolve(location);

            switch location.Type
            case{'Block','Annotation','TruthTableChart'}
                set_param(objectHandle,'HiliteAncestors','find');
            case 'Line'
                set_param(objectHandle,'HiliteAncestors','red');
            end

        end

        function removeAttentionStyleSL(~,location)
            resolver=slxmlcomp.internal.highlight.SimulinkHandleResolver();
            objectHandle=resolver.resolve(location);

            if ishandle(objectHandle)
                try
                    set_param(objectHandle,'HiliteAncestors','none');
                catch E
                    warning(E.identifier,'%s',E.message);
                end
            end
        end

        function applyAttentionStyleSF(~,location)

            stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location.Location);

            sfObj=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block);
            handle=sfprivate('ssIdToHandle',location.Location);

            action='Highlight';
            if(isa(handle,'Stateflow.Annotation'))



                action='Select';
            end

            sf(action,sfObj.Id,handle.Id);
            try %#ok<TRYNC>
                handle.highlight;
            end
        end

        function removeAttentionStyleSF(~,lastLocation)
            if bdIsLoaded(strtok(lastLocation.Location,'/'))
                try
                    sfprivate('traceabilityManager',...
                    'unHighlightObject',lastLocation.Location);
                catch E
                    warning(E.identifier,'%s',E.message);
                end
            end
        end
    end
end
