classdef ExpInput<handle




    properties(Access=private)
        name=''
        values=[];
    end

    methods
        function this=ExpInput(name)
            this.name=name;
            this.values={};
        end

        function name=getName(this)
            name=this.name;
        end

        function numValues=getNumValues(this)
            numValues=length(this.values);
        end

        function value=getValueAt(this,ind)
            value=this.values{ind};
        end

        function addValue(this,v)



            if iscellstr(v)
                v=string(v);
            end
            this.values{end+1}=v;
        end

        function addValues(this,v)
            this.values=[this.values,v];
        end
    end

end
