classdef GraphicsExporter<slreportgen.webview.internal.ExporterInterface


























    properties(Access=private)
ExportedMap
Snapshot
    end

    methods
        function this=GraphicsExporter(director)
            this=this@slreportgen.webview.internal.ExporterInterface(director);
            this.Snapshot=slreportgen.utils.internal.DiagramSnapshot([],...
            "Format","PNG",...
            "Scaling","Custom",...
            "Size",[200,200]);
            this.ExportedMap=dictionary(string.empty(),double.empty());
        end

        function export(this)



            project=this.project();
            diagrams=project.Diagrams;
            nDiagrams=numel(diagrams);
            for i=1:nDiagrams
                if this.ProgressMonitor.isCanceled()
                    return
                end
                this.exportDiagram(diagrams(i));
                this.setProgress(i/nDiagrams);
            end
        end
    end

    methods(Access=private)
        function exportDiagram(this,diagram)
            pm=this.ProgressMonitor;

            if~diagram.Selected
                pm.setMessage(...
                sprintf("Graphics: Skipping unselected ""%s""",diagram.FullName),...
                pm.LowLevelMessagePriority);
                return;
            end


            diagram.ExportData.SVG=this.svgPackagePath(diagram);
            diagram.ExportData.Thumbnail=this.thumbnailPackagePath(diagram);

            if this.isExported(diagram)

                pm.setMessage(...
                sprintf("Graphics: Skipping exported ""%s""",diagram.FullName),...
                pm.LowLevelMessagePriority);
                return;
            end

            cache=this.cache(diagram.RSID);
            svgCachePath=string.empty();
            if~isempty(cache)
                svgCachePath=this.svgCachePath(diagram);
                thumbnailCachePath=this.thumbnailCachePath(diagram);
            end

            if~isempty(cache)&&cache.hasFile(svgCachePath)

                pm.setMessage(...
                sprintf("Graphics: Exporting ""%s"" from cache",diagram.FullName),...
                pm.LowLevelMessagePriority);

                this.addFile(cache.getFile(svgCachePath),diagram.ExportData.SVG);
                this.addFile(cache.getFile(thumbnailCachePath),diagram.ExportData.Thumbnail);
            else

                pm.setMessage(...
                sprintf("Graphics: Exporting ""%s"" from Simulink",diagram.FullName),...
                pm.LowLevelMessagePriority);

                if diagram.Part.RootDiagram.IsSubsystemReference
                    slobj=slreportgen.webview.SlProxyObject(diagram.RSID);
                    if~strcmp(slobj.ClassName,diagram.slproxyobject().ClassName)

                        hs=slreportgen.utils.HierarchyService;
                        slobj=slreportgen.webview.SlProxyObject(hs.getDiagramHID(diagram.RSID));
                    end
                else
                    slobj=diagram.slproxyobject();
                end





                objH=slobj.Handle;
                svgWriter=slreportgen.webview.SvgWriter(objH);
                svgFilePath=this.svgFilePath(diagram);
                svgWriter.generate(svgFilePath,GLUE2.SvgWriteArguments());


                thumbnailFilePath=this.thumbnailFilePath(diagram);
                snapshot=this.Snapshot;
                snapshot.Source=objH;
                snapshot.Filename=thumbnailFilePath;
                snapshot.snap();


                this.addFile(svgFilePath,diagram.ExportData.SVG);
                this.addFile(thumbnailFilePath,diagram.ExportData.Thumbnail);


                if~isempty(cache)
                    cache.addFile(svgFilePath,svgCachePath);
                    cache.addFile(thumbnailFilePath,thumbnailCachePath);
                end
            end
            this.setExported(diagram);
        end
    end

    methods(Access=private)
        function tf=isExported(this,diagram)
            tf=this.ExportedMap.isKey(diagram.RSID);
        end

        function setExported(this,diagram)
            this.ExportedMap(diagram.RSID)=1;
        end

        function out=svgFileName(~,diagram)
            out=sprintf("%s_d.svg",escapeSID(diagram.RSID));
        end

        function out=svgCachePath(this,diagram)
            out=sprintf("svg/%s",this.svgFileName(diagram));
        end

        function out=svgFilePath(this,diagram)
            out=this.supportFolderPath()+filesep+this.svgFileName(diagram);
        end

        function out=svgPackagePath(this,diagram)
            out=this.supportPackagePath()+"/"+this.svgFileName(diagram);
        end

        function out=thumbnailFileName(~,diagram)
            out=sprintf("%s_d.png",escapeSID(diagram.RSID));
        end

        function out=thumbnailCachePath(this,diagram)
            out=compose("thumbnail/%s",this.thumbnailFileName(diagram));
        end

        function out=thumbnailFilePath(this,diagram)
            out=this.supportFolderPath()+filesep+this.thumbnailFileName(diagram);
        end

        function out=thumbnailPackagePath(this,diagram)
            out=this.supportPackagePath()+"/"+this.thumbnailFileName(diagram);
        end
    end
end

function out=escapeSID(sid)
    out=sid.replace(":","_");
end