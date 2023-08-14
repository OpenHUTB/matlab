classdef ExporterInterface<handle








































    properties

        Enabled logical=true;
    end

    properties(SetAccess=private)

ProgressMonitor
    end

    properties(Access=private)
        ExportDirector slreportgen.webview.internal.ExportDirector
    end

    methods(Abstract)



        export(this)
    end

    methods
        function preExport(~)



        end

        function postExport(~)


        end
    end

    methods(Sealed)
        function this=ExporterInterface(director)
            this.ExportDirector=director;
            this.ProgressMonitor=slreportgen.webview.ProgressMonitor(0,1);
        end

        function out=project(this)


            out=this.ExportDirector.Project;
        end

        function out=views(this)



            out=this.ExportDirector.enabledViews();
        end

        function out=sysview(this)


            out=this.ExportDirector.SystemView;
        end

        function out=optviews(this)



            out=this.ExportDirector.enabledOptionalViews();
        end

        function addFile(this,filePath,packagePath)




            this.ExportDirector.addFile(filePath,packagePath);
        end

        function out=supportFolderPath(this)



            out=this.ExportDirector.supportFolderPath();
        end

        function out=supportPackagePath(this)



            out=this.ExportDirector.SupportPackagePath;
        end

        function out=indent(this)



            out=this.ExportDirector.Indent;
        end

        function out=cache(this,sid)



            out=this.ExportDirector.cache(sid);
        end


        function setProgress(this,value)




            assert((value>=0)&&(value<=1));
            this.ProgressMonitor.setValue(value);
        end
    end
end