classdef SubsystemResolver<handle





    methods(Access=public,Static)
        function subsysPath=getPath(location)
            switch location.Type
            case{"System"}
                subsysPath=location.Location;
            case "Annotation"
                annotation=slxmlcomp.internal.annotation.find(...
                slxmlcomp.internal.annotation.highlightPathToStruct(location.Location)...
                );
                subsysPath=get_param(annotation,"Parent");
            case{"Block","chart","TestSequenceChart","TruthTableChart"}
                subsysPath=get_param(location.Location,"Parent");
            case{"Line","SimulinkMatlabFunction","EMLChart"}
                slashes=strfind(location.Location,"/");
                assert(~isempty(slashes));
                subsysPath=location.Location.extractBetween(1,slashes(end)-1);

            otherwise
                subsysPath='';
            end
        end
    end
end
