classdef BayesOptInput<handle


    properties(Access=private)
        name=''
        type=''
        values=[];
        transform='';
    end

    methods
        function this=BayesOptInput(name,values,type,transform)
            this.name=name;
            this.values=values;
            this.type=type;
            this.transform=transform;
        end

        function name=getName(this)
            name=this.name;
        end

        function numValues=getNumValues(this)
            numValues=length(this.values);
        end

        function value=getValues(this)
            value=this.values;
        end

        function value=getMinValue(this)
            value=this.values(1);
        end

        function name=getType(this)
            name=this.type;
        end

        function optVar=createOptVar(this)
            optVar=optimizableVariable(this.name,this.values,'Type',this.type,'Transform',this.transform);
        end

    end

end
