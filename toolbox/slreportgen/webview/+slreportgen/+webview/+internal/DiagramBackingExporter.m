classdef DiagramBackingExporter<slreportgen.webview.internal.ExporterInterface



















    properties(Access=private)
        ExportedMap struct
    end

    properties(Constant,Access=private)
        CachePackageBasePath="diagrams";
    end

    methods
        function this=DiagramBackingExporter(director)
            this=this@slreportgen.webview.internal.ExporterInterface(director);
            this.ExportedMap=struct();
            for view=this.views()
                this.ExportedMap.(view.Id)=dictionary(string.empty(),double.empty());
            end
        end

        function export(this)




            views=this.views();
            nViews=numel(views);
            parts=this.project().Parts;
            nParts=numel(parts);
            steps=0;
            nSteps=nViews*nParts;
            for i=1:nViews
                if this.ProgressMonitor.isCanceled()
                    return
                end
                view=views(i);
                for j=1:nParts
                    part=parts(j);
                    this.exportPartView(part,view);
                    steps=steps+1;
                    this.ProgressMonitor.setValue(steps/nSteps);
                end
            end
        end
    end

    methods(Access=private)
        function exportPartView(this,part,view)
            pm=this.ProgressMonitor;

            packagePath=this.packagePath(part,view);

            if(view==this.sysview())
                part.ExportData.SystemView=packagePath;
            else
                if isempty(part.ExportData.OptionalViews)
                    part.ExportData.OptionalViews=struct();
                end
                part.ExportData.OptionalViews.(view.Id)=packagePath;
            end

            if this.isExported(part,view)
                pm.setMessage(...
                sprintf("Diagram %s: Skipping exported ""%s""",view.Id,part.RootDiagram.FullName),...
                pm.LowLevelMessagePriority);
                return;
            end

            [viewCacheFilePaths,viewCachePackagePaths]=this.cacheFiles(part,view);
            if~isempty(viewCacheFilePaths)
                pm.setMessage(...
                sprintf("Diagram %s: Exporting ""%s"" from cache",view.Id,part.RootDiagram.FullName),...
                pm.LowLevelMessagePriority);

                for i=1:numel(viewCacheFilePaths)
                    this.addFile(viewCacheFilePaths(i),viewCachePackagePaths(i));
                end
            else
                pm.setMessage(...
                sprintf("Diagram %s: Exporting ""%s"" from Simulink",view.Id,part.RootDiagram.FullName),...
                pm.LowLevelMessagePriority);

                filePath=this.filePath(part,view);
                writer=slreportgen.webview.internal.BackingWriter(view);
                writer.Indent=this.indent();
                writer.open(filePath);
                diagrams=part.Diagrams;
                for i=1:numel(diagrams)
                    diagram=diagrams(i);
                    if diagram.Selected
                        writer.write(diagram.RSID,diagram.slproxyobject());
                    end
                end
                writer.close();
                [supportFilePaths,supportPackagePaths]=writer.supportFiles();

                filePaths=[filePath,supportFilePaths];
                packagePaths=[packagePath,supportPackagePaths];
                for i=1:numel(filePaths)
                    this.addFile(filePaths(i),packagePaths(i));
                end

                this.addCacheFiles(part,view,filePaths,packagePaths);
            end

            this.setExported(part,view);
        end

        function out=cacheFileKey(~,part,view)
            out=sprintf('%s_part_%s_files',part.RootDiagram.RSID,view.Id);
        end

        function addCacheFiles(this,part,view,filePaths,packagePaths)
            cache=this.cache(part.RootDiagram.RSID);
            if~isempty(cache)
                cacheFileKey=this.cacheFileKey(part,view);
                cachePackagePaths=this.packagePathToCachePackagePath(view,packagePaths);
                for i=1:numel(filePaths)
                    cache.addFile(filePaths(i),cachePackagePaths(i));
                end
                cache.addProperty(cacheFileKey,cachePackagePaths);
            end
        end

        function out=packagePathToCachePackagePath(this,view,packagePaths)

            out=strcat(this.CachePackageBasePath+"/"+view.Id+"/",packagePaths);
        end

        function out=cachePackagePathToPackagePath(this,view,cachePaths)

            persistent BASE_LENGTH
            if isempty(BASE_LENGTH)
                BASE_LENGTH=strlength(this.CachePackageBasePath)+1;
            end
            out=extractAfter(cachePaths,BASE_LENGTH+strlength(view.Id)+1);
        end


        function[cacheFilePaths,packagePaths]=cacheFiles(this,part,view)
            cacheFilePaths=string.empty();
            packagePaths=string.empty();
            cache=this.cache(part.RootDiagram.RSID);
            if~isempty(cache)
                cacheFileKey=this.cacheFileKey(part,view);
                if cache.hasProperty(cacheFileKey)
                    cachePackagePaths=cache.getProperty(cacheFileKey);
                    packagePaths=this.cachePackagePathToPackagePath(view,cachePackagePaths);
                    nPackagePaths=numel(packagePaths);
                    cacheFilePaths=string.empty(0,nPackagePaths);
                    for i=1:nPackagePaths
                        cacheFilePaths(i)=cache.getFile(cachePackagePaths(i));
                    end
                end
            end
        end

        function tf=isExported(this,part,view)
            tf=this.ExportedMap.(view.Id).isKey(part.RootDiagram.RSID);
        end

        function setExported(this,part,view)
            this.ExportedMap.(view.Id)(part.RootDiagram.RSID)=1;
        end

        function out=filePath(this,part,view)
            if(view==this.sysview())
                out=this.supportFolderPath()+filesep+escapeSID(part.RootDiagram.RSID)+"_p"+".json";
            else
                out=this.supportFolderPath()+filesep+escapeSID(part.RootDiagram.RSID)+"_p_"+view.Id+".json";
            end
        end

        function out=packagePath(this,part,view)
            if(view==this.sysview())
                out=this.supportPackagePath()+"/"+escapeSID(part.RootDiagram.RSID)+"_p"+".json";
            else
                out=this.supportPackagePath()+"/"+escapeSID(part.RootDiagram.RSID)+"_p_"+view.Id+".json";
            end
        end
    end
end

function out=escapeSID(sid)
    out=sid.replace(":","_");
end