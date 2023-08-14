


classdef(Hidden=true)CodeWriter<handle
    properties(SetAccess=private,GetAccess=protected)
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
            FID=fopen(this.FileName,'at','n','UTF-8');
            if(FID~=-1)
                fprintf(FID,'%s\n',this.CodeBuffer{:});
                this.CodeBuffer={};
                fclose(FID);
            else
                error(['Could not open the file "',this.FileName,' " for writing.']);
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
