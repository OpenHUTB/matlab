classdef rptviewer<handle






















    properties(Access=private)
        ViewerMap;
    end

    methods(Static)
        function open(filename)



            hrptviewer=mlreportgen.utils.rptviewer.instance();
            hViewer=hrptviewer.viewer(filename);
            show(hViewer);
        end

        function tf=isOpen(filename)



            hrptviewer=mlreportgen.utils.rptviewer.instance();
            hViewer=hrptviewer.getViewer(filename,false);
            tf=~isempty(hViewer);
        end

        function close(filename)



            hrptviewer=mlreportgen.utils.rptviewer.instance();
            hViewer=getViewer(hrptviewer,filename,false);
            if~isempty(hViewer)
                if close(hViewer)
                    removeViewer(hrptviewer,filename);
                else
                    error(message("mlreportgen:utils:error:cannotCloseViewer",filename));
                end
            else


                removeViewer(hrptviewer,filename);

            end
        end

        function closeAll()



            hrptviewer=mlreportgen.utils.rptviewer.instance();
            fnames=hrptviewer.filenames();
            for fname=fnames
                hrptviewer.close(fname);
            end
        end
    end

    methods(Hidden,Static)
        function hViewer=viewer(filename)



            hrptviewer=mlreportgen.utils.rptviewer.instance();
            hViewer=getViewer(hrptviewer,filename,true);
            if isempty(hViewer)
                hViewer=createViewer(hrptviewer,filename);
            end
        end

        function out=filenames()

            hrptviewer=mlreportgen.utils.rptviewer.instance();
            out=string(hrptviewer.ViewerMap.keys());
        end
    end

    methods(Access=private)
        function viewer=getViewer(this,filename,checkFileDate)



            key=this.getFileNameKey(filename);
            viewer=[];
            if isKey(this.ViewerMap,key)
                viewerInfo=this.ViewerMap(key);
                if checkFileDate
                    fileListing=dir(filename);
                    if~isempty(fileListing)&&(fileListing.datenum==viewerInfo.datenum)
                        viewer=viewerInfo.viewer;
                    end
                else
                    viewer=viewerInfo.viewer;
                end
            end
        end

        function viewer=createViewer(this,filename)





            fileNameKey=this.getFileNameKey(filename);
            if~isfile(fileNameKey)
                error(message("mlreportgen:utils:error:fileNotFound",fileNameKey));
            end
            [~,~,fExt]=fileparts(fileNameKey);


            if ismember(fExt,mlreportgen.utils.WordDoc.FileExtensions)
                viewer=mlreportgen.utils.word.load(fileNameKey);
            elseif ismember(fExt,mlreportgen.utils.HTMLDoc.FileExtensions)
                viewer=mlreportgen.utils.HTMLDoc(fileNameKey);
            elseif ismember(fExt,mlreportgen.utils.PDFDoc.FileExtensions)
                viewer=mlreportgen.utils.PDFDoc(fileNameKey);
            elseif ismember(fExt,mlreportgen.utils.PPTPres.FileExtensions)
                viewer=mlreportgen.utils.powerpoint.load(fileNameKey);
            elseif ismember(fExt,mlreportgen.utils.HTMXDoc.FileExtensions)
                viewer=mlreportgen.utils.HTMXDoc(fileNameKey);
            else
                error(message("mlreportgen:utils:error:unsupportedFileType",...
                upper(fExt(2:end)),...
                fileNameKey));
            end


            if~isempty(viewer)
                fileListing=dir(fileNameKey);
                this.ViewerMap(fileNameKey)=struct(...
                'viewer',viewer,...
                'datenum',fileListing.datenum);
            end
        end

        function removeViewer(this,filename)




            key=this.getFileNameKey(filename);
            if isKey(this.ViewerMap,key)
                remove(this.ViewerMap,key);
            else
                error(message("mlreportgen:utils:error:fileNotOpen",filename));
            end
        end

        function updateViewerMap(this)




            viewerMap=this.ViewerMap;
            fileNameKeys=viewerMap.keys();
            nFileNameKeys=numel(fileNameKeys);
            for i=1:nFileNameKeys
                fileNameKey=fileNameKeys{i};
                viewer=getViewer(this,fileNameKey,false);
                try
                    if~isOpen(viewer)
                        remove(viewerMap,fileNameKey);
                    end
                catch
                    remove(viewerMap,fileNameKey);
                end
            end
        end

        function h=rptviewer()



            h.ViewerMap=containers.Map();
        end
    end

    methods(Static,Access=private)
        function h=instance()



            persistent RPTVIEWER
            mlock();
            if isempty(RPTVIEWER)
                RPTVIEWER=mlreportgen.utils.rptviewer();
            end
            h=RPTVIEWER;
            updateViewerMap(h);
        end

        function key=getFileNameKey(filename)



            key=char(mlreportgen.utils.findFile(filename,"FileMustExist",false));
        end
    end
end