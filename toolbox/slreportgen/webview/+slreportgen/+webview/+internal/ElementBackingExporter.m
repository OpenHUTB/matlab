classdef ElementBackingExporter<slreportgen.webview.internal.ExporterInterface



















    properties(Access=private)
        ExportedMap struct
    end

    properties(Constant,Access=private)
        CachePackageBasePath="elements";
    end

    methods
        function this=ElementBackingExporter(engine)
            this=this@slreportgen.webview.internal.ExporterInterface(engine);
            this.ExportedMap=struct();
            views=this.views();
            for i=1:numel(views)
                view=views(i);
                this.ExportedMap.(view.Id)=dictionary(string.empty(),double.empty());
            end
        end

        function export(this)




            views=this.views();
            nViews=numel(views);
            diagrams=this.project().Diagrams;
            nDiagrams=numel(diagrams);
            steps=0;
            nSteps=nViews*nDiagrams;

            pm=this.ProgressMonitor;
            pm.setMessage("Exporting elements",...
            slreportgen.webview.ProgressMonitor.LowLevelMessagePriority);

            for i=1:nViews
                if this.ProgressMonitor.isCanceled()


                    return
                end
                view=views(i);
                for j=1:nDiagrams
                    this.exportDiagramView(diagrams(j),view);
                    steps=steps+1;
                    pm.setValue(steps/nSteps);
                end
            end
        end
    end

    methods(Access=private)
        function exportDiagramView(this,diagram,view)
            pm=this.ProgressMonitor;

            if~diagram.Selected
                pm.setMessage(...
                sprintf("Elements %s: Skipping unselected ""%s""",view.Id,diagram.FullName),...
                pm.LowLevelMessagePriority);
                return;
            end



            packagePath=this.packagePath(diagram,view);

            if(view==this.sysview())
                diagram.ExportData.SystemView=packagePath;
            else
                if isempty(diagram.ExportData.OptionalViews)
                    diagram.ExportData.OptionalViews=struct();
                end
                diagram.ExportData.OptionalViews.(view.Id)=packagePath;
            end

            if this.isExported(diagram,view)
                pm.setMessage(...
                sprintf("Elements %s: Skipping exported ""%s""",view.Id,diagram.FullName),...
                pm.LowLevelMessagePriority);
                return;
            end

            [cacheFilePaths,cachePackagePaths]=this.cacheFiles(diagram,view);
            if~isempty(cacheFilePaths)
                pm.setMessage(...
                sprintf("Elements %s: Exporting ""%s"" from cache",view.Id,diagram.FullName),...
                pm.LowLevelMessagePriority);

                for i=1:numel(cacheFilePaths)
                    this.addFile(cacheFilePaths(i),cachePackagePaths(i));
                end
            else
                pm.setMessage(...
                sprintf("Elements %s: Exporting ""%s"" from Simulink",view.Id,diagram.FullName),...
                pm.LowLevelMessagePriority);

                filePath=this.filePath(diagram,view);
                writer=slreportgen.webview.internal.BackingWriter(view);
                writer.Indent=this.indent();
                writer.open(filePath);
                elements=diagram.elements();

                nElements=numel(elements);
                for j=1:nElements
                    element=elements(j);
                    writer.write(element.rsid(),element.slproxyobject());
                end
                writer.close();
                [supportFilePaths,supportPackagePaths]=writer.supportFiles();

                filePaths=[filePath,supportFilePaths];
                packagePaths=[packagePath,supportPackagePaths];
                for k=1:numel(filePaths)
                    this.addFile(filePaths(k),packagePaths(k));
                end

                this.addCacheFiles(diagram,view,filePaths,packagePaths);
            end
            this.setExported(diagram,view);
        end

        function out=cacheFileKey(~,diagram,view)
            out=sprintf('%s_diagram_%s_files',escapeSID(diagram.RSID),view.Id);
        end

        function addCacheFiles(this,diagram,view,filePaths,packagePaths)
            cache=this.cache(diagram.RSID);
            if~isempty(cache)
                cacheFileKey=this.cacheFileKey(diagram,view);
                cachePaths=this.packagePathToCachePackagePath(view,packagePaths);
                for i=1:numel(filePaths)
                    cache.addFile(filePaths(i),cachePaths(i));
                end
                cache.addProperty(cacheFileKey,cachePaths);
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

        function[cacheFilePaths,packagePaths]=cacheFiles(this,diagram,view)
            cacheFilePaths=string.empty();
            packagePaths=string.empty();
            cache=this.cache(diagram.RSID);
            if~isempty(cache)
                cacheFileKey=this.cacheFileKey(diagram,view);
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

        function tf=isExported(this,diagram,view)
            tf=this.ExportedMap.(view.Id).isKey(diagram.RSID);
        end

        function setExported(this,diagram,view)
            this.ExportedMap.(view.Id)(diagram.RSID)=1;
        end

        function out=filePath(this,diagram,view)
            if(view==this.sysview())
                out=this.supportFolderPath()+filesep+escapeSID(diagram.RSID)+"_d"+".json";
            else
                out=this.supportFolderPath()+filesep+escapeSID(diagram.RSID)+"_d_"+view.Id+".json";
            end
        end

        function out=packagePath(this,diagram,view)
            if(view==this.sysview())
                out=this.supportPackagePath()+"/"+escapeSID(diagram.RSID)+"_d"+".json";
            else
                out=this.supportPackagePath()+"/"+escapeSID(diagram.RSID)+"_d_"+view.Id+".json";
            end
        end
    end
end

function out=escapeSID(sid)
    out=sid.replace(":","_");
end