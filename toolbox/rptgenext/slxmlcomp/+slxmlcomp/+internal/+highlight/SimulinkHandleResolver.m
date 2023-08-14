classdef SimulinkHandleResolver<handle



    properties(Access=private)
        SupportedTypes=[...
        "Block","chart","TestSequenceChart","EMLChart",...
        "state","transition","junction","SFBlock","System",...
        "Annotation","TruthTableChart",...
        "Line",...
        ]
    end

    methods(Access=public)

        function canResolve=canResolve(obj,location,~)
            canResolve=any(obj.SupportedTypes==location.Type);


            if canResolve&&(location.Type=="Block")
                try
                    canResolve=~strcmp(get_param(location.Location,'IOType'),'viewer');
                catch ME %#ok<NASGU> 

                end
            end
        end

        function handle=resolve(~,location)
            handle=[];
            switch location.Type
            case{"Block","chart","TestSequenceChart","EMLChart","TruthTableChart"}
                handle=get_param(location.Location,'Handle');
            case{"state","transition","junction","SFBlock","System"}
                handle=sfprivate('ssIdToHandle',location.Location);
            case "Annotation"
                handle=slxmlcomp.internal.annotation.find(...
                slxmlcomp.internal.annotation.highlightPathToStruct(location.Location)...
                );
            case "Line"
                handle=slxmlcomp.internal.line.getLineUnique(...
                slxmlcomp.internal.line.linePathToStruct(location.Location)...
                );

                if~isempty(handle)



                    handle=handle(1);
                end
            end
        end

    end

    methods(Access=public,Static)
        function isLoaded=isModelLoaded(location)
            modelName=location;

            if(contains(location,'/'))
                modelName=extractBefore(location,'/');
            end

            isLoaded=bdIsLoaded(modelName);
        end
    end

end
