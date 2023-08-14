




classdef Stack<handle
    properties(Access=private)
        Counter=0;
        Size=16;
        Data={};
    end

    methods(Access=public)
        function this=Stack()
            this.Data=cell(this.Size,1);
            this.Counter=0;
        end

        function push(this,val)
            if(this.Counter==(this.Size-1))
                this.resize;
            end

            this.Counter=this.Counter+1;
            this.Data{this.Counter}=val;
        end

        function val=pop(this)
            if(this.Counter>0)
                val=this.Data{this.Counter};
                this.Counter=this.Counter-1;
            else
                val=[];
            end
        end

        function resize(this)
            dat=cell(this.Size*2,1);
            for idx=1:this.Counter
                dat{idx}=this.Data{idx};
            end
            this.Data=dat;
            this.Size=this.Size*2;
        end

        function status=empty(this)
            status=(this.Counter==0);
        end

        function len=size(this)
            len=this.Counter;
        end

        function values=data(this)
            values=this.Data(1:this.Counter);
        end

        function clear(this)
            this.Counter=0;
        end
    end
end
