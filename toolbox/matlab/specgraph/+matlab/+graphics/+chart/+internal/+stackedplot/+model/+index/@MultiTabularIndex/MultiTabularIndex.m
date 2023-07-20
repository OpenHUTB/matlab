classdef MultiTabularIndex<handle









    properties(Access=private)
        ChartData matlab.graphics.chart.internal.stackedplot.ChartData
    end

    properties(Access=private,Transient,NonCopyable)
SourceTablePostSetListener
DisplayVariablesPostSetListener
CombineMatchingNamesPostSetListener
    end

    properties(Access=private,Transient)



































        Cache=[]
    end

    methods
        function obj=MultiTabularIndex(chartData)
            obj.ChartData=chartData;
            postSetCallback=@(~,~)obj.updateCache;
            obj.SourceTablePostSetListener=addlistener(chartData,"SourceTable","PostSet",postSetCallback);
            obj.DisplayVariablesPostSetListener=addlistener(chartData,"DisplayVariables","PostSet",postSetCallback);
            obj.CombineMatchingNamesPostSetListener=addlistener(chartData,"CombineMatchingNames","PostSet",postSetCallback);
            obj.updateCache();
        end

        [axesMapping,plotMapping]=mapPlotObjects(obj,oldIndex)

        function n=getNumAxes(obj)














            n=length(obj.Cache);
        end

        function[tbls,tblIdx]=getSingleVarSubTablesForAxes(obj,axesIndex)



















































            tbls=readCachedSingleVarSubTablesForAxes(obj,axesIndex);
            if nargout>1
                tblIdx=obj.Cache(axesIndex).SourceTableIndex;
            end
        end
    end

    methods(Static)
        function tbls=splitTables(tbls)




            if isempty(tbls)
                return
            end
            tbls=cellfun(@splitTable,tbls,"UniformOutput",false);
            tbls=[tbls{:}];
        end

        function tbls=sortSplitTablesByVars(tbls,vars)





            vars=cellstr(vars);
            allVars=cellfun(@(t)t.Properties.VariableNames,tbls,"UniformOutput",false);
            allVars=[allVars{:}];
            idx=groupStable(allVars,vars);
            tbls=tbls(idx);



            hasTabularVar=cellfun(@(t)istabular(t.(1)),tbls);
            if any(hasTabularVar)



                tabularVarTbls=tbls(hasTabularVar);
                allTabularVars=cellfun(@(t)string(t.Properties.VariableNames),tabularVarTbls);
                allNestedTabularVars=cellfun(@(t)string(t.(1).Properties.VariableNames),tabularVarTbls);
                catNames=strcat(allTabularVars,allNestedTabularVars);
                idx=groupStable(catNames,unique(allTabularVars,"stable"));
                tabularVarTbls=tabularVarTbls(idx);
                tbls(hasTabularVar)=tabularVarTbls;
            end
        end

        function tf=areVarsCompatible(tbls,vars,combineMatchingNames)









            tblsWithVars=cellfun(@(t)t(:,intersect(vars,t.Properties.VariableNames,"stable")),tbls,"UniformOutput",false);
            tblsWithVars(cellfun(@isempty,tblsWithVars))=[];
            if combineMatchingNames
                tf=canPlotAllTableVarsTogether(tblsWithVars,vars);
            else
                for i=1:length(tblsWithVars)
                    tf=canPlotAllTableVarsTogether(tblsWithVars(i),vars);
                    if~tf
                        break
                    end
                end
            end
        end
    end

    methods(Access=private)
        function updateCache(obj)
            tblsForAxes=obj.computeSingleVarSubTablesForAllAxes();
            cacheSingleVarSubTablesForAxes(obj,tblsForAxes);
        end

        function tbls=getSingleVarSubTablesForVars(obj,varsIndex)



































            import matlab.graphics.chart.internal.stackedplot.model.index.MultiTabularIndex

            vars=obj.ChartData.DisplayVariables{varsIndex};
            sourceTables=annotateSourceTablesForCaching(obj.ChartData.SourceTable);
            tbls=cellfun(@(t)getSubTablesForVars(t,vars),sourceTables,"UniformOutput",false);
            tbls=[tbls{:}];
            hasAnyVars=cellfun(@(t)numel(t)>0,tbls);
            tbls=tbls(hasAnyVars);
            vars=cellstr(obj.ChartData.DisplayVariables{varsIndex});
            tbls=MultiTabularIndex.sortSplitTablesByVars(tbls,vars);
        end

        function tbls=computeSingleVarSubTablesForAllAxes(obj)









            import matlab.graphics.chart.internal.stackedplot.model.index.MultiTabularIndex

            if isempty(obj.ChartData.DisplayVariables)||isempty(obj.ChartData.SourceTable)||~iscell(obj.ChartData.SourceTable)||all(cellfun(@isempty,obj.ChartData.SourceTable))
                tbls={};
                return
            end
            if obj.ChartData.CombineMatchingNames
                tbls={};
                for i=1:length(obj.ChartData.DisplayVariables)
                    tVars=getSingleVarSubTablesForVars(obj,i);
                    istabular_tVars=cellfun(@(t)istabular(t.(1)),tVars);
                    if~any(istabular_tVars)

                        tbls=[tbls,{tVars}];%#ok<AGROW> 
                    else

                        assert(all(istabular_tVars));
                        tbls_i={};
                        outerNamePrev="";
                        innerNamePrev="";
                        for j=1:length(tVars)
                            outerNameCurr=string(tVars{j}.Properties.VariableNames);
                            innerNameCurr=string(tVars{j}.(1).Properties.VariableNames);
                            if outerNameCurr==outerNamePrev&&innerNameCurr==innerNamePrev
                                tbls_i{end}=[tbls_i{end},tVars(j)];
                                if j==length(tVars)




                                    outerNamePrev="";
                                end
                            else
                                outerNamePrev=outerNameCurr;
                                innerNamePrev=innerNameCurr;
                                tbls_i=[tbls_i,{tVars(j)}];%#ok<AGROW> 
                            end
                        end
                        tbls=[tbls,tbls_i];%#ok<AGROW> 
                    end
                end
                hasAnyVars=cellfun(@(t)numel(t)>0,tbls);
                tbls=tbls(hasAnyVars);
            else
                sourceTables=annotateSourceTablesForCaching(obj.ChartData.SourceTable);
                tbls={};
                for i=1:length(obj.ChartData.DisplayVariables)
                    vars=cellstr(obj.ChartData.DisplayVariables{i});
                    for j=1:length(sourceTables)
                        tVars=getSubTablesForVars(sourceTables{j},vars);
                        tVars=MultiTabularIndex.sortSplitTablesByVars(tVars,vars);
                        istabular_tVars=cellfun(@(t)istabular(t.(1)),tVars);
                        if~any(istabular_tVars)

                            tbls=[tbls,{tVars}];%#ok<AGROW> 
                        else

                            assert(all(istabular_tVars));
                            tbls=[tbls,num2cell(tVars)];%#ok<AGROW> 
                        end
                    end
                end
                hasAnyVars=cellfun(@(t)numel(t)>0,tbls);
                tbls=tbls(hasAnyVars);
            end
        end
    end
end

function tbls=annotateSourceTablesForCaching(tbls)















    for i=1:length(tbls)
        t=tbls{i};
        t=rmprop(t,"SourceTableIndex");
        t=addprop(t,"SourceTableIndex","table");
        t.Properties.CustomProperties.SourceTableIndex=i;
        t=rmprop(t,"VariableIndex");
        t=addprop(t,"VariableIndex","variable");
        for j=1:width(t)
            t.Properties.CustomProperties.VariableIndex(j)=j;
            tInner=t.(j);
            if istabular(tInner)
                tInner=rmprop(tInner,"InnerVariableIndex");
                tInner=addprop(tInner,"InnerVariableIndex","variable");
                for k=1:width(tInner)
                    tInner.Properties.CustomProperties.InnerVariableIndex(k)=k;
                end
            end
            t.(j)=tInner;
        end
        tbls{i}=t;
    end
end

function subTables=getSubTablesForVars(t,vars)



    import matlab.graphics.chart.internal.stackedplot.canBeDisplayVariables
    import matlab.graphics.chart.internal.stackedplot.model.index.MultiTabularIndex










    vars=cellstr(vars);
    validVars=t.Properties.VariableNames(canBeDisplayVariables(t,false));
    invalidVars=setxor(vars,validVars);
    vars(ismember(vars,invalidVars))=[];
    subTables=cell(1,numel(vars));
    for i=1:length(vars)
        subTables{i}=t(:,vars{i});
    end
    subTables=MultiTabularIndex.splitTables(subTables);


    isInvalidNestedTable=cellfun(@(v)istabular(v.(1))&&~canBeDisplayVariables(v.(1),true),subTables);
    subTables(isInvalidNestedTable)=[];
end

function tOut=splitTable(t)





    tOut=cell(1,width(t));
    for i=1:width(t)
        if istabular(t.(i))
            tmp=t(:,i);
            tmpCell=splitTable(tmp.(1));
            for j=1:length(tmpCell)
                tmpCopy=tmp;
                tmpCopy.(1)=tmpCell{j};
                tmpCell{j}=tmpCopy;
            end
            tOut{i}=tmpCell;
        else
            tOut{i}={t(:,i)};
        end
    end
    tOut=[tOut{:}];
end

function idx=groupStable(A,G)






    [~,~,groups]=unique([G,A],"stable");
    groups=groups(length(G)+1:end);
    [~,idx]=sort(groups);
end

function tf=canPlotAllTableVarsTogether(tbls,vars)




    import matlab.graphics.chart.internal.stackedplot.model.index.MultiTabularIndex


    tf=true;
    tbls=MultiTabularIndex.splitTables(tbls);
    tbls=MultiTabularIndex.sortSplitTablesByVars(tbls,vars);
    tblVars=cellfun(@getFirstElement,tbls,"UniformOutput",false);
    function e=getFirstElement(t)
        if isempty(t.(1))
            e=t.(1)(1,:);
        else
            e=t.(1)(1,1);
        end
    end




    isDurationVars=cellfun(@isduration,tblVars);
    if any(isDurationVars)
        tf=all(isDurationVars);
        return
    end




    isTabularVars=cellfun(@istabular,tblVars);
    if any(isTabularVars)
        if~all(isTabularVars)
            tf=false;
            return
        end
        tblVars=cellfun(@(t)t.(1),tblVars,"UniformOutput",false);
    end

    try
        [tblVars{:}];%#ok<VUNUS> 
    catch
        tf=false;
    end
end

function cacheSingleVarSubTablesForAxes(obj,tblsForAxes)



    idx.SourceTableIndex=[];
    idx.VariableIndex=[];
    idx.InnerVariableIndex=[];
    idx=repmat(idx,1,length(tblsForAxes));
    for i=1:length(tblsForAxes)
        tbls=tblsForAxes{i};
        idx(i).SourceTableIndex=zeros(1,length(tbls));
        idx(i).VariableIndex=zeros(1,length(tbls));
        idx(i).InnerVariableIndex=zeros(1,length(tbls));
        for j=1:length(tbls)
            idx(i).SourceTableIndex(j)=tbls{j}.Properties.CustomProperties.SourceTableIndex;
            idx(i).VariableIndex(j)=tbls{j}.Properties.CustomProperties.VariableIndex;
            innerT=tbls{j}.(1);
            if istabular(innerT)
                idx(i).InnerVariableIndex(j)=innerT.Properties.CustomProperties.InnerVariableIndex;
            end
        end
    end
    obj.Cache=idx;
end

function tbls=readCachedSingleVarSubTablesForAxes(obj,axesIndex)


    idx=obj.Cache(axesIndex);
    tbls=cell(1,length(idx.SourceTableIndex));
    sourceTables=obj.ChartData.SourceTable;
    for i=1:length(tbls)
        tblIdx=idx.SourceTableIndex(i);
        varIdx=idx.VariableIndex(i);
        innerVarIdx=idx.InnerVariableIndex(i);
        t=sourceTables{tblIdx}(:,varIdx);
        if innerVarIdx>0
            t.(1)=t.(1)(:,innerVarIdx);
        end
        tbls{i}=t;
    end
end
