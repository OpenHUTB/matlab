classdef SBioTimePercentilePlot<SimBiology.internal.plotting.sbioplot.SBioPercentilePlot



    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.PERCENTILE;
        end

        function flag=isTimePlot(obj)
            flag=true;
        end
    end




    methods(Access=protected)

        function[medianX,medianY]=getMedianForResampledData(obj,resampledData)
            medianX=[];
            medianY=median(resampledData.resampledDataY,2,'omitnan');
        end

        function[percentileVectorsX,percentileVectorsY]=getPercentileVectorsForResampledData(obj,resampledData,percentiles)
            percentileVectorsX=[];
            percentileVectorsY=prctile(resampledData.resampledDataY,percentiles,2);
        end


        function[medianX,medianY]=getMedianForBinnedData(obj,binnedData)
            medianX=[];
            medianY=accumarray(binnedData.dataClassifications,binnedData.allDataY,[],@median);
        end

        function[percentileVectorsX,percentileVectorsY]=getPercentileVectorsForBinnedData(obj,binnedData,percentiles)
            percentileVectorsX=[];
            percentileVectorsY=accumarray(binnedData.dataClassifications,binnedData.allDataY,[],@(data){prctile(data,percentiles)});
            percentileVectorsY=vertcat(percentileVectorsY{:});
        end
    end




    methods(Access=protected)

        function[meanX,meanY]=getMeanForResampledData(obj,resampledData)
            meanX=[];
            meanY=mean(resampledData.resampledDataY,2,'omitnan');
        end

        function[stdDevX,stdDevY]=getStdDevForResampledData(obj,resampledData)
            stdDevX=[];
            stdDevY=std(resampledData.resampledDataY,1,2,'omitnan');
        end

        function[minMaxX,minMaxY]=getMinMaxForResampledData(obj,resampledData)
            minMaxX=[];
            minMaxY(:,obj.MAX_INDEX)=max(resampledData.resampledDataY,[],2,'omitnan');
            minMaxY(:,obj.MIN_INDEX)=min(resampledData.resampledDataY,[],2,'omitnan');
        end


        function[meanX,meanY]=getMeanForBinnedData(obj,binnedData)
            meanX=[];
            meanY=accumarray(binnedData.dataClassifications,binnedData.allDataY,[],@mean);
        end

        function[stdDevX,stdDevY]=getStdDevForBinnedData(obj,binnedData)
            stdDevX=[];
            stdDevY=accumarray(binnedData.dataClassifications,binnedData.allDataY,[],@std);
        end

        function[minMaxX,minMaxY]=getMinMaxForBinnedData(obj,binnedData)
            minMaxX=[];
            minMaxY(:,obj.MAX_INDEX)=accumarray(binnedData.dataClassifications,binnedData.allDataY,[],@max);
            minMaxY(:,obj.MIN_INDEX)=accumarray(binnedData.dataClassifications,binnedData.allDataY,[],@min);
        end
    end




    methods(Access=protected)
        function[resampledDataX,resampledDataY]=resample(obj,timeVector,compoundBin,isSimulation,interpolationMethod)
            resampledDataX=[];
            if isSimulation
                resampledDataY=SimBiology.internal.plotting.data.SBioDataInterfaceForSimData.resample(timeVector,compoundBin.dataSeries,interpolationMethod);
            else
                resampledDataY=SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.resample(timeVector,compoundBin.dataSeries,interpolationMethod);
            end
        end
    end




    methods(Access=protected)
        function[T,X,Y]=getRawDataVectors(obj,dataSeries)
            T=vertcat(dataSeries.independentVariableData);
            X=[];
            Y=vertcat(dataSeries.dependentVariableData);
        end

        function dataSeries=cleanDataSeries(obj,dataSeries)







            for d=numel(dataSeries):-1:1
                notNanIdx=~isnan(dataSeries(d).dependentVariableData);
                dataSeries(d).dependentVariableData=dataSeries(d).dependentVariableData(notNanIdx);

                if isempty(dataSeries(d).dependentVariableData)
                    dataSeries(d)=[];
                else
                    dataSeries(d).independentVariableData=dataSeries(d).independentVariableData(notNanIdx);
                end
            end
        end
    end
end