classdef IconExporter<slreportgen.webview.internal.ExporterInterface



























    properties(Access=private)
        ImageSpriteWriter slreportgen.webview.utils.ImageSpriteWriter
ExportedMap
    end

    methods
        function this=IconExporter(director)
            this=this@slreportgen.webview.internal.ExporterInterface(director);
            this.ExportedMap=dictionary(string.empty(),slreportgen.webview.internal.Diagram.empty());



            this.ImageSpriteWriter=slreportgen.webview.utils.ImageSpriteWriter(...
            "Width",16,...
            "Height",16);
        end

        function export(this)




            pm=this.ProgressMonitor;
            pm.setMessage("IconExporter: Exporting icons",pm.LowLevelMessagePriority);

            spriteFilePath=this.spriteFilePath();
            spritePackagePath=this.spritePackagePath();
            cssFilePath=this.cssFilePath();
            cssPackagePath=this.cssPackagePath();


            this.ImageSpriteWriter.open(spriteFilePath,cssFilePath);

            project=this.project();
            project.ExportData.IconsURL=cssPackagePath;

            diagrams=project.Diagrams;
            for i=1:numel(diagrams)
                if pm.isCanceled()
                    return
                end
                diagram=diagrams(i);
                if diagram.ExportData.IsPartOfExportHierarchy
                    this.exportDiagramIcon(diagram);
                    if diagram.Selected
                        elements=diagram.elements();
                        for j=1:numel(elements)
                            this.exportDiagramElementIcon(elements(j));
                        end
                    end
                    this.setExported(diagram);
                end
            end

            optviews=this.optviews();
            for k=1:numel(optviews)
                this.exportViewIcon(optviews(k));
            end


            this.ImageSpriteWriter.close();
            this.addFile(cssFilePath,cssPackagePath);
            this.addFile(spriteFilePath,spritePackagePath);

            pm.setValue(1);
        end
    end

    methods(Access=private)
        function exportDiagramIcon(this,diagram)
            if this.isExported(diagram)
                exportedDiagram=this.getExported(diagram);
                diagram.ExportData.IconClass=exportedDiagram.ExportData.IconClass;
            else
                iconFile=strrep(diagram.DisplayIcon,"$matlabroot",matlabroot);
                [~,iconName]=fileparts(iconFile);
                iconClass=sprintf("%s_icon",iconName);
                this.ImageSpriteWriter.add(iconClass,iconFile);
                diagram.ExportData.IconClass=iconClass;
            end
        end

        function exportDiagramElementIcon(this,element)


            if isempty(element.ExportData.IconClass)
                iconFile=strrep(element.DisplayIcon,"$matlabroot",matlabroot);



                if~isempty(iconFile)
                    [~,iconName]=fileparts(iconFile);
                    iconClass=sprintf("%s_icon",iconName);
                    this.ImageSpriteWriter.add(iconClass,iconFile);
                    element.ExportData.IconClass=iconClass;
                end
            end
        end

        function exportViewIcon(this,view)
            iconFile=view.Icon;
            project=this.project();
            if~isempty(iconFile)
                [~,iconName]=fileparts(iconFile);
                iconClass=sprintf("%s_%s_icon",view.Id,iconName);
                this.ImageSpriteWriter.add(iconClass,iconFile);
                project.ExportData.OptionalViews=[project.ExportData.OptionalViews,...
                struct(...
                'id',view.Id,...
                'name',view.Name,...
                'icon',iconClass)...
                ];
            end
        end

        function out=getExported(this,diagram)
            out=this.ExportedMap(diagram.RSID);
        end

        function tf=isExported(this,diagram)
            tf=this.ExportedMap.isKey(diagram.RSID);
        end

        function setExported(this,diagram)
            this.ExportedMap(diagram.RSID)=diagram;
        end

        function out=spriteFilePath(this)
            out=this.supportFolderPath()+filesep+"icon.png";
        end
        function out=spritePackagePath(this)
            out=this.supportPackagePath()+"/icon.png";
        end
        function out=cssFilePath(this)
            out=this.supportFolderPath()+filesep+"icon.css";
        end
        function out=cssPackagePath(this)
            out=this.supportPackagePath()+"/icon.css";
        end
    end
end