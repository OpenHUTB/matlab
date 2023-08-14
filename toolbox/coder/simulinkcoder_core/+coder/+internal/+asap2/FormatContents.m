classdef FormatContents<handle




    properties(Access=protected)
        WriterHFile;
        IsFreshLine=true;
    end

    methods(Abstract)
        write(comment,value);
        writeAppend(value,comment);
    end

    methods(Access=protected)
        function this=FormatContents(fullFilePath)
            this.WriterHFile=rtw.connectivity.CodeWriter.create('filename',...
            fullFilePath,'append',false,'encoding','UTF-8');
        end
    end
    methods(Access=public)
        function newLine=isFreshLine(this)


            newLine=this.IsFreshLine;
        end

        function wLine(this,value)

            this.WriterHFile.wLine(value);
            this.IsFreshLine=true;
        end

        function writeBinary(this,value)
            this.WriterHFile.writeBinary(value);
        end

        function close(this)

            this.WriterHFile.close;
        end
    end
end

