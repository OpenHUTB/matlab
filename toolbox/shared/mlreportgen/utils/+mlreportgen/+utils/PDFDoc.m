classdef PDFDoc<handle



















    properties(SetAccess=private)
        FileName=string.empty();
    end

    properties(Constant,Hidden)
        FileExtensions=".pdf";
    end

    properties(Access=private)
        WebWindow=[];
    end

    methods
        function this=PDFDoc(fileName)
            mlreportgen.utils.internal.logmsg('Create PDFDoc');

            filePath=char(mlreportgen.utils.findFile(...
            fileName,...
            "FileMustExist",true,...
            "FileExtensions",this.FileExtensions));

            mlreportgen.utils.internal.logmsg('Done finding file');

            if isempty(filePath)
                error(message("mlreportgen:utils:error:fileNotFound",fileName));
            end
            this.FileName=filePath;

            [~,~,fExt]=fileparts(filePath);
            if~ismember(fExt,this.FileExtensions)
                error(message("mlreportgen:utils:error:unexpectedFileType",...
                fileName,strjoin(this.FileExtensions," ")));
            end

            url=mlreportgen.utils.fileToURI(filePath);

            this.WebWindow=mlreportgen.utils.internal.WebWindow(...
            url,...
            "Title",this.FileName);
        end

        function delete(this)
            try
                delete(this.WebWindow);
            catch
            end
        end

        function show(this)


            show(this.WebWindow);
        end

        function hide(this)


            hide(this.WebWindow);
        end

        function tf=isVisible(this)



            tf=~isempty(this.WebWindow)&&isVisible(this.WebWindow);
        end

        function tf=close(this)




            tf=~isempty(this.WebWindow)&&close(this.WebWindow);
        end

        function tf=isOpen(this)




            tf=~isempty(this.WebWindow)&&isOpen(this.WebWindow);
        end
    end
end
