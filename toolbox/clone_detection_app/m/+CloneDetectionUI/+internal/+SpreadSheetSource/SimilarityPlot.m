classdef SimilarityPlot<handle






    properties
        data;
        columns;
        cloneGroupSidMap;
        m2mObj;
        refactorButtonStatus;
    end

    methods(Access=public)
        function this=SimilarityPlot(m2mObj,cloneGroupSidMap,refactorButtonStatus)
            this.cloneGroupSidMap=cloneGroupSidMap;
            this.data=[];
            this.m2mObj=m2mObj;

            this.columns={DAStudio.message('sl_pir_cpp:creator:similarityPlotSSColumn1'),...
            DAStudio.message('sl_pir_cpp:creator:similarityPlotSSColumn2'),...
            DAStudio.message('sl_pir_cpp:creator:similarityPlotSSColumn3')};
            this.refactorButtonStatus=refactorButtonStatus;
        end


        function children=getChildren(this,~)
            if~isempty(this.data)
                children=this.data;
                return;
            else
                if~isempty(this.cloneGroupSidMap)&&this.refactorButtonStatus
                    keyList=keys(this.cloneGroupSidMap);
                    [maxPlotLength,~]=getNumOfClones(this,keyList,1);
                    similarCount=0;



                    for cloneGroupIndex=1:length(keyList)
                        [numOfClones,~]=getNumOfClones(this,keyList,cloneGroupIndex);
                        if numOfClones>maxPlotLength
                            maxPlotLength=numOfClones;
                        end
                        if contains(keyList{cloneGroupIndex},'Similar')
                            similarCount=similarCount+1;
                        end
                    end


                    exactColor=CloneDetectionUI.internal.util.getExactColorCodeNumerical;
                    darkest=CloneDetectionUI.internal.util.getSimilarColorCodeNumerical;
                    lightest=CloneDetectionUI.internal.util.getSimilarLightColorCodeNumerical;
                    red=linspace(lightest(1),darkest(1),similarCount+1);
                    green=linspace(lightest(2),darkest(2),similarCount+1);
                    blue=linspace(lightest(3),darkest(3),similarCount+1);


                    children(1,length(keyList))=...
                    CloneDetectionUI.internal.SpreadSheetItem.SimilarityPlot();


                    for cloneGroupIndex=1:length(keyList)
                        [numClones,paramDiff]=getNumOfClones(this,keyList,cloneGroupIndex);
                        if contains(keyList{cloneGroupIndex},'Exact')
                            children(cloneGroupIndex)=...
                            CloneDetectionUI.internal.SpreadSheetItem.SimilarityPlot...
                            (this.cloneGroupSidMap(keyList{cloneGroupIndex}).CloneGroupName,...
                            numClones,maxPlotLength,...
                            {exactColor(1),exactColor(2),exactColor(3)},...
                            ['Parameter difference:',int2str(paramDiff)]);
                        else
                            children(cloneGroupIndex)=...
                            CloneDetectionUI.internal.SpreadSheetItem.SimilarityPlot...
                            (this.cloneGroupSidMap(keyList{cloneGroupIndex}).CloneGroupName,...
                            numClones,maxPlotLength,...
                            {red(similarCount),green(similarCount),blue(similarCount)},...
                            ['Parameter difference:',int2str(paramDiff)]);
                            similarCount=similarCount-1;
                        end
                    end
                    this.data=children;
                end

                children=this.data;
            end
        end

    end
    methods(Access=private)


        function[numClones,paramDiff]=getNumOfClones(this,keyList,cloneGroupIndex)
            cloneIndex=this.cloneGroupSidMap(keyList{cloneGroupIndex}).cloneIndex;
            if contains(keyList{cloneGroupIndex},'Exact')
                idx=this.m2mObj.cloneresult.exact{cloneIndex}.index;
            else
                idx=this.m2mObj.cloneresult.similar{cloneIndex}.index;
            end
            numClones=length(this.m2mObj.cloneresult.Before{idx});
            paramDiff=this.m2mObj.cloneresult.dissimiliartyParamNum(idx);
        end

    end
end


