classdef JComparisonDefinitionAdapter<handle




    properties(Access=private)
JDefinition
    end

    methods

        function obj=JComparisonDefinitionAdapter(jDefinition)
            obj.JDefinition=jDefinition;
        end

        function bool=isThreeWayMerge(obj)
            jData=obj.JDefinition.getComparisonData();

            bool=jData.getComparisonSources().size()==3;
        end

        function bool=isTwoWayDiff(obj)
            jData=obj.JDefinition.getComparisonData();

            bool=jData.getComparisonSources().size()==2...
            &&~obj.allowMerge();
        end

        function bool=isTwoWayMerge(obj)
            jData=obj.JDefinition.getComparisonData();

            bool=jData.getComparisonSources().size()==2...
            &&obj.allowMerge();
        end

        function pth=getLeftPath(obj)
            pth=obj.getFilePath(0);
        end

        function pth=getRightPath(obj)
            pth=obj.getFilePath(1);
        end

        function type=getType(obj)
            jComparisonType=obj.JDefinition.getComparisonType();

            if isempty(jComparisonType)
                type="";
                return
            end

            jDataType=jComparisonType.getDataType();
            type=string(jDataType.getName());
        end

        function bool=hasSCMDiffData(obj)
            jParams=obj.JDefinition.getComparisonData.getComparisonParameters;
            bool=jParams.hasParameter(...
            com.mathworks.comparisons.scm.CParameterSourceControlComparisonData.getInstance());
        end

        function value=getSCMDiffData(obj)
            jParams=obj.JDefinition.getComparisonData.getComparisonParameters;
            value=jParams.getValue(...
            com.mathworks.comparisons.scm.CParameterSourceControlComparisonData.getInstance());
        end

        function bool=hasSCMMergeData(obj)
            jParams=obj.JDefinition.getComparisonData.getComparisonParameters;
            bool=jParams.hasParameter(...
            com.mathworks.comparisons.scm.CParameterSourceControlMergeData.getInstance());
        end

        function value=getSCMMergeData(obj)
            jParams=obj.JDefinition.getComparisonData.getComparisonParameters;
            value=jParams.getValue(...
            com.mathworks.comparisons.scm.CParameterSourceControlMergeData.getInstance());
        end

        function bool=hasAllowMerge(obj)
            jParams=obj.JDefinition.getComparisonData.getComparisonParameters;

            import com.mathworks.comparisons.param.parameter.ComparisonParameterAllowMerging
            bool=jParams.hasParameter(ComparisonParameterAllowMerging.getInstance());
        end

        function bool=getAllowMerge(obj)
            jParams=obj.JDefinition.getComparisonData.getComparisonParameters;

            import com.mathworks.comparisons.param.parameter.ComparisonParameterAllowMerging
            bool=jParams.getValue(ComparisonParameterAllowMerging.getInstance());
        end

        function jDefinition=getDefinition(obj)
            jDefinition=obj.JDefinition;
        end

    end

    methods(Access=private)
        function bool=allowMerge(obj)
            jData=obj.JDefinition.getComparisonData();
            jParams=jData.getComparisonParameters();

            import com.mathworks.comparisons.param.parameter.ComparisonParameterAllowMerging
            bool=~jParams.hasParameter(ComparisonParameterAllowMerging.getInstance())...
            ||jParams.getValue(ComparisonParameterAllowMerging.getInstance());
        end

        function filePath=getFilePath(obj,index)
            jData=obj.JDefinition.getComparisonData();
            sources=jData.getComparisonSources();
            import com.mathworks.comparisons.util.FileUtils;
            import com.mathworks.comparisons.source.property.CSPropertyReadableLocation;
            import com.mathworks.comparisons.source.property.CSPropertyAbsoluteName;
            source=sources.get(index);
            if source.hasProperty(CSPropertyReadableLocation.getInstance())
                filePath=string(FileUtils.convertComparisonSourceToFile(sources.get(index)));
            elseif source.hasProperty(CSPropertyAbsoluteName.getInstance())

                info=[];
                filePath=string(source.getPropertyValue(CSPropertyAbsoluteName.getInstance(),info));
            else
                filePath=string(source.toString());
            end
        end
    end
end
