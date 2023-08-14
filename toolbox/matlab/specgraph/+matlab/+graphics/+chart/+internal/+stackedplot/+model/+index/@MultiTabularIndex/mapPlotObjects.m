function[axesMapping,plotMapping]=mapPlotObjects(obj,oldIndex)





    oldCache=[];
    if~isempty(oldIndex)
        oldCache=oldIndex.Cache;
    end
    [axesMapping,plotMapping]=mapCache(obj,obj.Cache,oldCache);
end

function[axesMapping,plotMapping]=mapCache(obj,newCache,oldCache)










    import matlab.graphics.chart.internal.stackedplot.model.index.shared.createAxesMapping
    import matlab.graphics.chart.internal.stackedplot.model.index.shared.createPlotMapping



    [oldCacheExpanded,oldNumVarsPerAxes]=expandCache(oldCache);
    [newCacheExpanded,newNumVarsPerAxes]=expandCache(newCache);




    if isempty(oldCacheExpanded)
        d=dictionary(oldCacheExpanded,[]);
    else


        d=dictionary(flip(oldCacheExpanded),numel(oldCacheExpanded):-1:1);
    end
    inOldCache=isKey(d,newCacheExpanded);
    locInOldCacheExpanded=double(inOldCache);
    locInOldCacheExpanded(inOldCache)=d(newCacheExpanded(inOldCache));


    [axesMapping,oldCumLengths]=createAxesMapping(oldNumVarsPerAxes,locInOldCacheExpanded);




    getVariableByCacheIndex=@(idx)getVariableByCacheEntry(obj,oldCacheExpanded(idx));
    plotMapping=createPlotMapping(axesMapping,locInOldCacheExpanded,oldCumLengths,inOldCache,getVariableByCacheIndex);


    if numel(axesMapping)>1&&numel(plotMapping)>1&&any(newNumVarsPerAxes>1)
        axesMapping=mat2cell(axesMapping,1,newNumVarsPerAxes);
        plotMapping=mat2cell(plotMapping,1,newNumVarsPerAxes);
    end
end

function[cacheExpanded,numVarsPerAxes]=expandCache(cache)




    if isempty(cache)
        cacheExpanded=struct.empty;
        numVarsPerAxes=[];
        return
    end
    cacheExpanded=cell(1,numel(cache));
    numVarsPerAxes=zeros(1,numel(cache));
    for i=1:numel(cache)
        numVarsPerAxes(i)=numel(cache(i).SourceTableIndex);
        f=fieldnames(cache);
        cacheExpanded{i}=repmat(cache(i),1,numVarsPerAxes(i));
        for j=1:numVarsPerAxes(i)
            for k=1:numel(f)
                cacheExpanded{i}(j).(f{k})=cache(i).(f{k})(j);
            end
        end
    end
    cacheExpanded=[cacheExpanded{:}];
end


function v=getVariableByCacheEntry(obj,ce)


    v=obj.ChartData.SourceTable{ce.SourceTableIndex}{:,ce.VariableIndex};


    if isa(v,'tabular')

        v=v.(ce.InnerVariableIndex);
    end
end