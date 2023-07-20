classdef SBioXYPercentilePlot<SimBiology.internal.plotting.sbioplot.SBioPercentilePlot



    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.PERCENTILE_XY;
        end

        function flag=isTimePlot(obj)
            flag=false;
        end
    end




    methods(Access=protected)

        function[medianX,medianY]=getMedianForResampledData(obj,resampledData)
            medianX=median(resampledData.resampledDataX,2,'omitnan');
            medianY=median(resampledData.resampledDataY,2,'omitnan');
        end

        function[percentileVectorsX,percentileVectorsY]=getPercentileVectorsForResampledData(obj,resampledData,percentiles)
            percentileVectorsX=prctile(resampledData.resampledDataX,percentiles,2);
            percentileVectorsY=prctile(resampledData.resampledDataY,percentiles,2);
        end


        function[medianX,medianY]=getMedianForBinnedData(obj,binnedData)
            medianX=accumarray(binnedData.dataClassifications,binnedData.allDataX,[],@median);
            medianY=accumarray(binnedData.dataClassifications,binnedData.allDataY,[],@median);
        end

        function[percentileVectorsX,percentileVectorsY]=getPercentileVectorsForBinnedData(obj,resampledData,percentiles)
            percentileVectorsX=accumarray(binnedData.dataClassifications,binnedData.allDataX,[],@(data){prctile(data,percentiles)});
            percentileVectorsY=accumarray(binnedData.dataClassifications,binnedData.allDataY,[],@(data){prctile(data,percentiles)});
            percentileVectorsX=vertcat(percentileVectorsX{:});
            percentileVectorsY=vertcat(percentileVectorsY{:});
        end

        function plotPercentileShading(obj,ax,percentileData,color,visibility,bins)

        end


...
...
...
...
...
...
...
...
    end




    methods(Access=protected)

        function[meanX,meanY]=getMeanForResampledData(obj,resampledData)
            meanX=mean(aggregatedData.resampledDataX,2,'omitnan');
            meanY=mean(aggregatedData.resampledDataY,2,'omitnan');
        end

        function[stdDevX,stdDevY]=getStdDevForResampledData(obj,resampledData)
            stdDevX=std(aggregatedData.resampledDataX,1,2,'omitnan');
            stdDevY=std(aggregatedData.resampledDataY,1,2,'omitnan');
        end

        function[minMaxX,minMaxY]=getMinMaxForResampledData(obj,resampledData)
            minMaxX(:,obj.MAX_INDEX)=max(aggregatedData.resampledDataX,[],2,'omitnan');
            minMaxX(:,obj.MIN_INDEX)=min(aggregatedData.resampledDataX,[],2,'omitnan');
            minMaxY(:,obj.MAX_INDEX)=max(aggregatedData.resampledDataY,[],2,'omitnan');
            minMaxY(:,obj.MIN_INDEX)=min(aggregatedData.resampledDataY,[],2,'omitnan');
        end


        function[meanX,meanY]=getMeanForBinnedData(obj,binnedData)
            meanX=accumarray(aggregatedData.dataClassifications,aggregatedData.allDataX,[],@mean);
            meanY=accumarray(aggregatedData.dataClassifications,aggregatedData.allDataY,[],@mean);
        end

        function[stdDevX,stdDevY]=getStdDevForBinnedData(obj,binnedData)
            stdDevX=accumarray(aggregatedData.dataClassifications,aggregatedData.allDataX,[],@std);
            stdDevY=accumarray(aggregatedData.dataClassifications,aggregatedData.allDataY,[],@std);
        end

        function[minMaxX,minMaxY]=getMinMaxForBinnedData(obj,binnedData)
            minMaxX(:,obj.MAX_INDEX)=accumarray(aggregatedData.dataClassifications,aggregatedData.allDataX,[],@max);
            minMaxX(:,obj.MIN_INDEX)=accumarray(aggregatedData.dataClassifications,aggregatedData.allDataX,[],@min);
            minMaxY(:,obj.MAX_INDEX)=accumarray(aggregatedData.dataClassifications,aggregatedData.allDataY,[],@max);
            minMaxY(:,obj.MIN_INDEX)=accumarray(aggregatedData.dataClassifications,aggregatedData.allDataY,[],@min);
        end
    end




    methods(Access=protected)
        function showBinEdges(obj,ax,compoundBin,binEdgeValues,color,visibility,bins)

        end
    end




    methods(Access=protected)
        function[resampledDataX,resampledDataY]=resample(obj,timeVector,compoundBin,isSimulation,interpolationMethod)
            if isSimulation
                [resampledDataX,resampledDataY]=SimBiology.internal.plotting.data.SBioDataInterfaceForSimData.resampleWithParameterization(timeVector,compoundBin.dataSeries,interpolationMethod);
            else
                [resampledDataX,resampledDataY]=SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.resampleWithParameterization(timeVector,compoundBin.dataSeries,interpolationMethod);
            end
        end
    end




    methods(Access=protected)
        function[T,X,Y]=getRawDataVectors(obj,dataSeries)
            T=vertcat(dataSeries.parameterizationVariableData);
            X=vertcat(dataSeries.independentVariableData);
            Y=vertcat(dataSeries.dependentVariableData);
        end

        function dataSeries=cleanDataSeries(obj,dataSeries)






            for d=numel(dataSeries):-1:1
                notNanIdx=~isnan(dataSeries(d).dependentVariableData)&~isnan(dataSeries(d).independentVariableData);
                dataSeries(d).dependentVariableData=dataSeries(d).dependentVariableData(notNanIdx);

                if isempty(dataSeries(d).dependentVariableData)
                    dataSeries(d)=[];
                else
                    dataSeries(d).independentVariableData=dataSeries(d).independentVariableData(notNanIdx);
                    dataSeries(d).parameterizationVariableData=dataSeries(d).parameterizationVariableData(notNanIdx);
                end
            end
        end
    end
end