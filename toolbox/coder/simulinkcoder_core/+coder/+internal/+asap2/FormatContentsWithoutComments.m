classdef FormatContentsWithoutComments<coder.internal.asap2.FormatContents




    methods(Access=public)
        function this=FormatContentsWithoutComments(fullFilePath)
            this=this@coder.internal.asap2.FormatContents(fullFilePath);
        end

        function write(this,~,value)

            this.WriterHFile.emitLine([value,' '],false,false);
            this.IsFreshLine=false;
        end



        function writeAppend(this,value,~)

            this.WriterHFile.emitLine([value,' '],false,false);
            this.IsFreshLine=false;
        end
    end
end

