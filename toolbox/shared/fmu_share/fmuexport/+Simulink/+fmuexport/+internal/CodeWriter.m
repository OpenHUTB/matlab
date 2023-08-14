

classdef(Hidden=true)CodeWriter<handle
    properties(SetAccess=private,GetAccess=public)
FileName
        CodeBuffer={};
    end


    methods(Access=public)
        function this=CodeWriter(fileName)
            if exist(fullfile(pwd,fileName),'file')
                delete(fileName);
            end
            this.FileName=fileName;
        end

        function delete(this)
            FID=fopen(this.FileName,'at','native','UTF-8');
            if(FID~=-1)
                code=unicode2native(strjoin(this.CodeBuffer,'\n'),'UTF-8');
                fwrite(FID,code,'uint8');
                this.CodeBuffer={};
                fclose(FID);
            else
                error(message('FMUShare:FMU:CannotOpenFileForWriting',this.FileName));
            end
        end
    end


    methods(Access=public)
        function writeLine(this,formatString,varargin)
            this.CodeBuffer{end+1}=sprintf(formatString,varargin{:});
        end

        function writeString(this,str)
            this.CodeBuffer{end+1}=str;
        end
    end

end
