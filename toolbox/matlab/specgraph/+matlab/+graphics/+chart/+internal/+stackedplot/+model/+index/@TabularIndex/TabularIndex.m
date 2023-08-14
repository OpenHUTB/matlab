classdef TabularIndex<handle









    properties(Access=private)
        ChartData matlab.graphics.chart.internal.stackedplot.ChartData







VariableIndex





InnerVariableIndex
    end

    properties(Access=private,Transient,NonCopyable)
SourceTablePostSetListener
DisplayVariablesPostSetListener
    end

    methods
        function obj=TabularIndex(chartData)
            obj.ChartData=chartData;
            obj.SourceTablePostSetListener=addlistener(chartData,"SourceTable","PostSet",@obj.handleSourceTableSet);
            obj.DisplayVariablesPostSetListener=addlistener(chartData,"DisplayVariables","PostSet",@obj.handleDisplayVariablesSet);
            [~,ind]=matlab.graphics.chart.internal.stackedplot.validateDisplayVariables(...
            chartData.DisplayVariables,chartData.SourceTable,"","DisplayVariables");
            obj.setVariableIndex(chartData,ind);
        end

        function varIndex=getVariableIndex(obj)
            varIndex=obj.VariableIndex;
        end

        function innerVarIdx=getInnerVariableIndex(obj)
            innerVarIdx=obj.InnerVariableIndex;
        end

        function n=getNumAxes(obj)

            n=length(obj.VariableIndex);
        end

        function n=getNumPlotsInAxes(obj,axesIndex)

            n=0;
            t=obj.getSubTableForAxes(axesIndex);
            for i=1:width(t)
                var=t.(i);
                if istabular(var)
                    for j=1:width(var)
                        varInner=var.(j);
                        n=n+width(varInner(:,:));
                    end
                else
                    n=n+width(var(:,:));
                end
            end
        end

        function t=getSubTableForAxes(obj,axesIndex)

            currIndex=getElement(obj.VariableIndex,axesIndex);
            t=obj.ChartData.SourceTable(:,currIndex);
            if obj.isInnerTable(axesIndex)

                currInnerIndex=getElement(obj.InnerVariableIndex,axesIndex);
                t.(1)=t.(1)(:,currInnerIndex);
            end
        end

        function tf=isInnerTable(obj,axesIndex)






            currIndex=getElement(obj.VariableIndex,axesIndex);
            tf=isscalar(currIndex)&&istabular(obj.ChartData.SourceTable.(currIndex));
        end

        [axesMapping,plotMapping]=mapPlotObjects(obj,oldIndex)
    end

    methods(Access=private)
        function handleSourceTableSet(obj,~,evnt)
            chartData=evnt.AffectedObject;
            if~istabular(chartData.SourceTable)
                return
            end
            if chartData.DisplayVariablesMode=="manual"
                if iscellstr(chartData.DisplayVariables)
                    [lia,locb]=ismember(chartData.DisplayVariables,chartData.SourceTable.Properties.VariableNames);
                    obj.setVariableIndex(chartData,locb(lia));
                else
                    vars=chartData.DisplayVariables;
                    varindex=obj.VariableIndex;
                    for i=1:length(vars)
                        currvar=vars{i};
                        if~iscell(currvar)
                            currvar={currvar};
                        end
                        [lia,locb]=ismember(currvar,chartData.SourceTable.Properties.VariableNames);
                        currvarindex=locb(lia);
                        varindex{i}=currvarindex;
                    end
                    if iscellstr(vars)%#ok<ISCLSTR> 
                        varindex=[varindex{:}];
                    end
                    obj.setVariableIndex(chartData,varindex);
                end
            end
        end

        function handleDisplayVariablesSet(obj,~,evnt)
            chartData=evnt.AffectedObject;
            if~istabular(chartData.SourceTable)
                return
            end
            [~,ind]=matlab.graphics.chart.internal.stackedplot.validateDisplayVariables(...
            chartData.DisplayVariables,chartData.SourceTable,"","DisplayVariables");
            obj.setVariableIndex(chartData,ind);
        end
    end

    methods(Access=private)
        [axesMapping,plotMapping]=mapVariableIndex(obj,varIndex,innerVarIndex,oldVarIndex,oldInnerVarindex)

        function obj=setVariableIndex(obj,chartData,rawVarIndex)



            expandFactor=ones(size(rawVarIndex));
            if iscell(rawVarIndex)
                innerVariableIndex={};
            else
                innerVariableIndex=[];
            end
            for i=1:length(rawVarIndex)
                if iscell(rawVarIndex)
                    currindex=rawVarIndex{i};
                else
                    currindex=rawVarIndex(i);
                end
                if isscalar(currindex)
                    currvar=chartData.SourceTable.(currindex);
                    if isa(currvar,'tabular')


                        currinnerindex=find(...
                        matlab.graphics.chart.internal.stackedplot.canBeDisplayVariables(currvar,true));
                        if iscell(innerVariableIndex)
                            innerVariableIndex=[innerVariableIndex,num2cell(currinnerindex)];%#ok<AGROW>
                        else
                            innerVariableIndex=[innerVariableIndex,currinnerindex];%#ok<AGROW>
                        end
                        expandFactor(i)=length(currinnerindex);
                    else


                        innerVariableIndex=[innerVariableIndex,0];%#ok<AGROW>
                    end
                else



                    innerVariableIndex=[innerVariableIndex,zeros(1,length(currindex))];%#ok<AGROW>
                end
            end

            obj.VariableIndex=repelem(rawVarIndex,expandFactor);
            obj.InnerVariableIndex=innerVariableIndex;
        end
    end
end

function v=getElement(C,i)

    if iscell(C)
        v=C{i};
    else
        v=C(i);
    end
end