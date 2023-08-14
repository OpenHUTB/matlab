classdef HierarchyExporter<slreportgen.webview.internal.ExporterInterface


















    properties

        TargetPackagePath string


        TargetFilePath string
    end

    methods
        function this=HierarchyExporter(engine)
            this=this@slreportgen.webview.internal.ExporterInterface(engine);
        end

        function export(this)


            pm=this.ProgressMonitor;
            pm.setMessage("Hierarchy: Exporting hierarchy",pm.LowLevelMessagePriority);


            project=this.project();
            parts=project.Parts;
            for i=1:numel(parts)
                part=parts(i);
                if pm.isCanceled()
                    return
                end
                part.ExportData.DiagramsURL=this.partPackagePath(part);

                partFilePath=this.partFilePath(part);
                partWriter=this.createJSONWriter(partFilePath);
                partWriter.beginArray();
                diagrams=part.Diagrams;
                for j=1:numel(diagrams)
                    if this.ProgressMonitor.isCanceled()
                        return
                    end
                    diagram=diagrams(j);
                    if diagram.ExportData.IsPartOfExportHierarchy
                        diagram.ExportData.write(partWriter);
                    end
                end
                partWriter.endArray();
                partWriter.close();

                this.addFile(partFilePath,part.ExportData.DiagramsURL);
            end


            projectWriter=this.createJSONWriter(this.TargetFilePath);
            project.ExportData.write(projectWriter);
            projectWriter.close();

            this.addFile(this.TargetFilePath,this.TargetPackagePath);
            pm.setValue(1);
        end
    end

    methods(Access=private)
        function writer=createJSONWriter(this,filePath)
            folder=fileparts(filePath);
            if(~isempty(folder)&&~isfolder(folder))
                mkdir(folder);
            end
            writer=slreportgen.webview.JSONWriter(filePath);
            writer.Indent=this.indent();
        end

        function out=partPackagePath(this,part)

            out=this.supportPackagePath()+"/"+escapeSID(part.RootDiagram.SID)+"_diagrams_"+part.RootDiagram.ExportData.ID+".json";
        end

        function out=partFilePath(this,part)
            out=this.supportFolderPath()+filesep+escapeSID(part.RootDiagram.SID)+"_diagrams_"+part.RootDiagram.ExportData.ID+".json";
        end
    end
end

function out=escapeSID(sid)
    out=sid.replace(":","_");
end