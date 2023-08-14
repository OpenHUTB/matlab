



classdef BufferedFileWriter<legacycode.lct.gen.BufferedWriter


    properties(SetAccess=protected,GetAccess=public)
        FileId=-1
        FileName char=''
        CallCBeautifier logical=false
    end


    methods




        function this=BufferedFileWriter(fileName,append,callCBeautifier)


            narginchk(1,3);

            this@legacycode.lct.gen.BufferedWriter();


            validateattributes(fileName,{'char','string'},{'scalartext'},'','fileName',1);
            fileName=char(fileName);


            if nargin>1
                validateattributes(append,{'logical'},{'scalar','nonempty'},'','append',2);
            else
                append=false;
            end

            if nargin>2
                validateattributes(callCBeautifier,{'logical'},{'scalar','nonempty'},'','callCBeautifier',3);
            else
                callCBeautifier=false;
            end


            this.FileName=fileName;
            this.CallCBeautifier=callCBeautifier;


            if append
                attr='a';
            else
                attr='w';
            end




            [this.FileId,msg]=fopen(fileName,attr,'n',slCharacterEncoding);


            if~isnumeric(this.FileId)||this.FileId<0
                [fpath,fname,fext]=fileparts(fileName);
                error(message('Simulink:tools:LCTErrorCannotOpenFile',...
                fullfile(fpath,fname),fext(2:end),['(',msg,')']));
            end
        end




        function close(this)
            if this.FileId>=0

                this.flush();


                fclose(this.FileId);
                this.FileId=-1;


                if this.CallCBeautifier
                    try
                        c_beautifier(this.FileName);
                    catch
                    end
                end
            end
        end




        function flush(this)


            fprintf(this.FileId,'%s',this.CodeBuffer{1:this.InsertIdx-1});


            this.resetBuffer();
        end
    end
end


