



classdef BufferedWriter<rtw.connectivity.Writer


    properties(Constant,Hidden)
        MaxNumel int32=20
    end


    properties(SetAccess=protected,GetAccess=public)
        CodeBuffer={}
        InsertIdx int32=1
        TxtBuffer char=''
    end


    methods




        function this=BufferedWriter()

            this.resetBuffer();
        end




        function delete(this)
            this.close();
        end




        function close(this)

            this.flush();
        end




        function write(this,str)

            this.CodeBuffer{this.InsertIdx}=str;


            this.InsertIdx=this.InsertIdx+1;
            if this.InsertIdx>this.MaxNumel
                this.flush();
            end
        end




        function writeLine(this,formatString,varargin)
            this.write(sprintf(formatString,varargin{:}));
        end




        function flush(this)


            this.TxtBuffer=sprintf('%s%s',this.TxtBuffer,this.CodeBuffer{1:this.InsertIdx-1});


            this.resetBuffer();
        end
    end


    methods(Access=protected)




        function resetBuffer(this)
            this.CodeBuffer=cell(this.MaxNumel,1);
            this.InsertIdx=1;
        end
    end

end
