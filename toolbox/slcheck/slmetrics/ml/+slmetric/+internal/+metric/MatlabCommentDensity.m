classdef MatlabCommentDensity<slmetric.metric.Metric




    methods
        function this=MatlabCommentDensity()
            this.ID='mathworks.metrics.MatlabCommentDensity';
            this.Version=1;
            this.ComponentScope=Advisor.component.Types.MATLABFunction;
            this.AggregationMode=slmetric.AggregationMode.None;
            this.Name=DAStudio.message('slcheck:metric:MatlabCommentDensity_Name');
            this.Description=DAStudio.message('slcheck:metric:MatlabCommentDensity_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:MatlabCommentDensity_ValueLabel');
        end

        function res=algorithm(this,component)


            sfObj=Advisor.component.getComponentSource(component);

            res=this.getCodeCommentDensity(sfObj,component.ID);
        end
    end

    methods(Access=private)



        function res=getCodeCommentDensity(this,sfObj,compID)
            res=slmetric.metric.Result();
            mlString=sfObj.Script;
            mtreeObject=mtree(mlString,'-com','-cell');
            LOC=length(unique(mtreeObject.lineno));
            commentNodes=mtreeObject.mtfind('Kind',{'COMMENT','CELLMARK','BLKCOM'});
            CLOC=length(unique(commentNodes.lineno));
            commentDensity=CLOC/LOC;
            res.ComponentID=compID;
            res.MetricID=this.ID;
            res.Value=commentDensity;

        end
    end
end

