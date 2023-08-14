classdef TextPrinter<handle







    properties(Access=private)
        TextBuffer="";
        TabCount=0;
    end

    properties(Access=protected)
        DefaultFileExtension="txt";
    end

    methods
        function obj=TextPrinter()
            obj.clearBuffer;
        end

        function clearBuffer(obj)
            obj.TextBuffer="";
        end
    end


    methods(Access=public)
        function addEmptyLine(obj)

            obj.addLine("");
        end

        function addLine(obj,lineStr)

            tabs=sprintf(repmat('\t',1,obj.TabCount));


            line=tabs+lineStr+newline;
            obj.addText(line);
        end

        function addText(obj,textStr)

            obj.TextBuffer=obj.TextBuffer+textStr;
        end

        function indent(obj,tabCount)



            if nargin<2
                tabCount=1;
            end

            obj.TabCount=obj.TabCount+tabCount;
        end

        function unindent(obj,tabCount)



            if nargin<2
                tabCount=1;
            end


            obj.TabCount=max(obj.TabCount-tabCount,0);
        end
    end


    methods(Access=public)
        function print(obj,fileName)
            if nargin<2
                disp(obj.TextBuffer);
            else
                obj.printToFile(fileName);
            end
        end
    end

    methods(Access=protected)
        function printToFile(obj,fileName)






            fileID=obj.openFile(fileName);


            closeFile=onCleanup(@()obj.closeFile(fileID));


            textToPrint=obj.TextBuffer;
            textToPrint=insertBefore(textToPrint,"%","%");
            textToPrint=insertBefore(textToPrint,"\","\");


            fprintf(fileID,textToPrint);
        end

        function fileID=openFile(obj,fileName)
            [~,~,ext]=fileparts(fileName);
            if isempty(ext)
                fileName=[fileName,'.',obj.DefaultFileExtension];
            end
            fileID=l_createFile(fileName);
        end

        function closeFile(~,fileID)
            status=fclose(fileID);
            if status==-1
                error('Could not close file.')
            end
        end
    end
end

function fid=l_createFile(filePath)


    fileFolder=fileparts(filePath);
    l_createDir(fileFolder);

    fid=fopen(filePath,'w');
    if fid==-1
        error('Unable to create file "%s", please check write permission.',filePath);

    end

end

function l_createDir(dirPath)


    if isempty(dirPath)
        return;
    end

    [status,~,~]=mkdir(dirPath);
    if status==0
        error('Unable to create directory "%s", please check write permission.',dirPath);

    end

end