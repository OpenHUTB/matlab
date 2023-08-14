classdef RequirementsDataExporter<slreportgen.webview.DataExporter



    methods
        function h=RequirementsDataExporter()
            h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.Line',@noExport);
            bind(h,'Simulink.Object',@exportRequirements);
            bind(h,'Stateflow.Object',@exportRequirements);
        end
    end

    methods(Access=private)
        function ret=exportRequirements(~,obj)
            sid=Simulink.ID.getSID(obj);
            ret='<p> No Requirements </p>';
            if~isempty(sid)
                reqFile=rmi.Informer.cache(sid);
                if exist(reqFile,'file')
                    fid=fopen(reqFile,'r','n','utf-8');
                    ret=fread(fid,inf,'char*1=>char')';
                    fclose(fid);
                end
            end
        end
    end
end
