classdef SFTextOverlay<handle
    properties
        styler=[];
        styleMap=[];
        sfIds=[];
        cvIds=[];

        modelH=[];

        colorTable=[];

        tag='';
    end


    methods
        function this=SFTextOverlay(modelH,covResults)
            this.modelH=modelH;
            this.colorTable=cvi.Informer.getHighlightingColorTable;
            this.styler=Stateflow.internal.getStateflowStyler();
            this.setupStyleMap()
            this.create(covResults,false);
        end


        function delete(this)
            this.clearAll();
        end


        function addPartialCoverageStylingForMALCharts(this)
            for i=1:length(this.sfIds)
                styleVector=this.getStyleVectorForMALChartObject(this.cvIds(i));
                this.applyStyleVectorToSFObject(this.sfIds(i),styleVector);
            end
        end


        function triggerExtents=get_transition_trigger_extents(~,~)

            triggerExtents=[];
        end
end

        function conditionExtents=get_transition_condition_extents(~,sfId)

            conditionExtents=[];
            ast=Stateflow.Ast.getContainer(idToHandle(sfroot,sfId));
            if(~isempty(ast.conditionSection))
                sec=ast.conditionSection{1};
                r1=sec.roots{1};
                conditionExtents=[r1.treeStart,r1.treeEnd];
            end
        end


        function styleVector=getStyleVectorForCALChartObject(this,partialCovSFObj)
            sfId=partialCovSFObj.sfId;
            labelString=sf('get',sfId,'.labelString');
            styleVector=zeros(1,length(labelString));

            if(~isempty(sf('get',sfId,'transition.id')))
                switch(partialCovSFObj.decisionCoverage)
                case 0

                    styleToApply=3;
                case 1

                    styleToApply=2;
                otherwise
                    styleToApply=0;
                end
                triggerExtents=get_transition_trigger_extents(this,sfId);
                if(~isempty(triggerExtents))
                    styleVector(triggerExtents(1):triggerExtents(2))=styleToApply;
                end
                conditionExtents=get_transition_condition_extents(this,sfId);
                if(~isempty(conditionExtents))
                    styleVector(conditionExtents(1):conditionExtents(2))=styleToApply;
                end
            else
                for j=1:length(partialCovSFObj.coveredDecisions)
                    indxs=partialCovSFObj.coveredDecisions{j};
                    styleVector(indxs(1)+1:indxs(2)+1)=2;
                end
                for j=1:length(partialCovSFObj.unCoveredDecisions)
                    indxs=partialCovSFObj.unCoveredDecisions{j};
                    styleVector(indxs(1)+1:indxs(2)+1)=3;
                end
            end

            for j=1:length(partialCovSFObj.coveredConditions)
                indxs=partialCovSFObj.coveredConditions{j};
                styleVector(indxs(1)+1:indxs(2)+1)=2;
            end
            for j=1:length(partialCovSFObj.unCoveredConditions)
                indxs=partialCovSFObj.unCoveredConditions{j};
                styleVector(indxs(1)+1:indxs(2)+1)=3;
            end
        end


        function addPartialCoverageStylingForCALCharts(this,sfCovResults)
            if(isfield(sfCovResults,'partialCovSFObjs'))
                for i=1:length(sfCovResults.partialCovSFObjs)
                    styleVector=this.getStyleVectorForCALChartObject(sfCovResults.partialCovSFObjs(i));
                    this.applyStyleVectorToSFObject(sfCovResults.partialCovSFObjs(i).sfId,styleVector);
                end
            end
        end


        function create(this,sfCovResults,append)
            if append
                existingSfIds=this.sfIds;
                existingCvIds=this.cvIds;
            else
                existingSfIds=[];
                existingCvIds=[];
            end

            if isfield(sfCovResults.sfMissing,'cvIds')
                newSfIds=[sfCovResults.sfMissing.sfIds(:);sfCovResults.sfCovered.sfIds(:)];
                newCvIds=[sfCovResults.sfMissing.cvIds(:);sfCovResults.sfCovered.cvIds(:)];
            else
                newSfIds=[sfCovResults.sfMissing(:);sfCovResults.sfCovered(:)];
                newCvIds=zeros(size(newSfIds));
            end

            [this.sfIds,uIdx]=unique([existingSfIds;newSfIds],'last');
            this.cvIds=[existingCvIds;newCvIds];
            this.cvIds=this.cvIds(uIdx);
            this.fixUnsetCvIds();
            addPartialCoverageStylingForMALCharts(this);
            addPartialCoverageStylingForCALCharts(this,sfCovResults);
        end


        function update(this,covResults,append)
            this.clearAll();
            this.create(covResults,append);
        end


        function clearAll(this)
            for i=1:length(this.sfIds)
                this.styler.disableHighlights(this.sfIds(i));
            end
            this.styler.clearDisabledHighlights();
        end


        function setupStyleMap(this)
            this.styleMap=containers.Map('KeyType','double','ValueType','any');
            this.addStyleToMap(0,'CoverageStyle_None',[0,0,0],[]);
            this.addStyleToMap(1,'CoverageStyle_Missing',this.colorTable.sfRed,[]);
            this.addStyleToMap(2,'CoverageStyle_Covered',this.colorTable.sfGreen,[]);
            this.addStyleToMap(3,'CoverageStyle_MissingBold',this.colorTable.sfRed,[]);
            this.addStyleToMap(4,'CoverageStyle_Justified',this.colorTable.sfLightBlue,[]);
        end


        function addStyleToMap(this,styleIdx,styleName,textColor,backgroundColor)
            style=Stateflow.internal.getStateflowStyle(styleName);
            style.textColor=[textColor,1];
            style.backgroundColor=backgroundColor;
            this.styleMap(styleIdx)=style;
        end


        function fixUnsetCvIds(this)

            for i=1:length(this.cvIds)
                if(this.cvIds(i)==0)
                    try
                        obj=sf('IdToHandle',this.sfIds(i));
                        ssid=Simulink.ID.getSID(obj);
                        cvId=SlCov.CoverageAPI.getCovId(ssid,this.sfIds(i));
                        if isempty(cvId)
                            cvId=0;
                        end
                    catch
                        cvId=0;
                    end
                    this.cvIds(i)=cvId;
                end
            end
        end


        function styleIdx=getStyleVectorForMALChartObject(~,cvId)
            styleIdx=[];
            if cvId~=0
                codeblock=cv('get',cvId,'.code');
                if codeblock~=0
                    styleIdx=cv('get',codeblock,'.styleIdx');
                end
            end
        end


        function applyStyleVectorToSFObject(this,sfId,styleIdx)

            lastStyle=-1;
            for i=1:length(styleIdx)
                curStyle=styleIdx(i);
                if(curStyle~=lastStyle)
                    if(lastStyle~=-1)
                        styleEndIdx=i-2;
                        textLength=styleEndIdx-styleStartIdx+1;
                        this.applySFStyle(sfId,styleStartIdx,textLength,lastStyle);
                    end
                    styleStartIdx=i-1;
                end
                if(i==length(styleIdx))
                    styleEndIdx=i-1;
                    textLength=styleEndIdx-styleStartIdx+1;
                    this.applySFStyle(sfId,styleStartIdx,textLength,curStyle);
                end
                lastStyle=curStyle;
            end
        end


        function applySFStyle(this,sfId,styleStartIdx,textLength,styleId)
            if(this.styleMap.isKey(styleId))
                curStyle=this.styleMap(styleId);
                this.styler.addStyleToTextRange(sfId,styleStartIdx,textLength,curStyle,true);
            else

            end
        end
    end
end
