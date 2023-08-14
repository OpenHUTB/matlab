classdef MatlabLOCCount<slmetric.metric.Metric




    properties

    end

    methods
        function this=MatlabLOCCount()
            this.ID='mathworks.metrics.MatlabLOCCount';
            this.Version=1;
            this.ComponentScope=Advisor.component.Types.MATLABFunction;
            this.AggregationMode=slmetric.AggregationMode.Sum;
            this.Name=DAStudio.message('slcheck:metric:MatlabLOCCount_Name');
            this.Description=DAStudio.message('slcheck:metric:MatlabLOCCount_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:MatlabLOCCount_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:MatlabLOCCount_AggregateValueLabel');

            this.setCSH('ma.metricchecks','MatlabLOCCount');
        end

        function res=algorithm(this,component)


            sfObj=Advisor.component.getComponentSource(component);

            res=this.getEffectiveLOC(sfObj,component.ID);
        end
    end

    methods(Access=private)



        function res=getEffectiveLOC(this,sfObj,compID)
            res=slmetric.metric.Result();
            res.MetricID=this.ID;
            res.ComponentID=compID;
            res.Value=0;


            mlString=sfObj.Script;


            mtreeObject=mtree(mlString,'-com','-cell');



            functionNodes=mtreeObject.mtfind('Kind','FUNCTION');
            numFunctions=functionNodes.count;
            functionIndices=functionNodes.indices;

            for n=1:numFunctions
                thisNode=functionNodes.select(functionIndices(n));
                thisTree=thisNode.Tree;

                noCodeNodes=thisTree.mtfind('Kind',{'COMMENT','CELLMARK','BLKCOM'});
                codeNodes=thisTree.mtfind('~Member',noCodeNodes);
                thisEffectiveLinesOfCode=length(unique(codeNodes.lineno));

                res.Value=res.Value+thisEffectiveLinesOfCode;
            end
        end
    end
end

