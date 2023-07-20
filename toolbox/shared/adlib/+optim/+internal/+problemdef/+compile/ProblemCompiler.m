classdef ProblemCompiler<handle







    properties(SetAccess=protected,GetAccess=public)


        QuadraticObjective=[];
    end

    methods(Access=public)

        function this=ProblemCompiler()

        end

        function reset(this)



            this.QuadraticObjective=[];
        end

        function[H,A,b]=compileQuadraticObjective(this,objective,TotalVar)



            if isempty(this.QuadraticObjective)

                [H,A,b]=extractQuadraticCoefficients(objective,TotalVar);
                this.QuadraticObjective.H=H;
                this.QuadraticObjective.A=A;
                this.QuadraticObjective.b=b;
            else
                H=this.QuadraticObjective.H;
                A=this.QuadraticObjective.A;
                b=this.QuadraticObjective.b;
            end
        end

        function cachesEmpty=areCachesEmpty(this)





            mc=metaclass(this);
            numProps=numel(mc.PropertyList);
            propNames=cell(1,numProps);
            [propNames{:}]=mc.PropertyList.Name;


            cachesEmpty=true;
            for i=1:numProps
                if~isempty(this.(propNames{i}))
                    cachesEmpty=false;
                    break
                end
            end

        end
    end
end
