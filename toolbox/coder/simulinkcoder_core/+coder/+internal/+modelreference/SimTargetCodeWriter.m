


classdef SimTargetCodeWriter<handle
    properties(SetAccess=private,GetAccess=private)
FID
FileName
Writer
        CodeBuffer={};
    end


    methods(Access=public)
        function this=SimTargetCodeWriter(fileName)
            this.FileName=fileName;
            this.FID=fopen(this.FileName,'at');
            assert(this.FID~=-1,'Could not open the file "%s" for writing.',fileName);
        end


        function delete(this)
            if(this.FID~=-1)
                this.writeCodeBufferToFile;
                fclose(this.FID);
            end
        end
    end


    methods(Access=public)
        function writeLine(this,formatString,varargin)
            this.CodeBuffer{end+1}=sprintf(formatString,varargin{:});
        end


        function writeChar(this,ch)
            this.CodeBuffer{end+1}=ch;
        end


        function writeString(this,str)
            this.CodeBuffer{end+1}=str;
        end


        function writeCodeBufferToFile(this)
            fprintf(this.FID,'%s\n',this.CodeBuffer{:});
            this.CodeBuffer={};
        end
    end
end
