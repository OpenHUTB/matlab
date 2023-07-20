function[axesMapping,plotMapping]=mapPlotObjects(obj,oldIndex)





    oldVariableIndex=[];
    oldInnerVariableIndex=[];
    if~isempty(oldIndex)
        oldVariableIndex=oldIndex.VariableIndex;
        oldInnerVariableIndex=oldIndex.InnerVariableIndex;
    end
    [axesMapping,plotMapping]=mapVariableIndex(obj,obj.VariableIndex,obj.InnerVariableIndex,oldVariableIndex,oldInnerVariableIndex);
end

function[axesMapping,plotMapping]=mapVariableIndex(obj,varIndex,innerVarIndex,oldVarIndex,oldInnerVarindex)












    import matlab.graphics.chart.internal.stackedplot.model.index.shared.createAxesMapping
    import matlab.graphics.chart.internal.stackedplot.model.index.shared.createPlotMapping



    [varIndex_flat,newNumVarsPerAxes]=flattenVarIndex(varIndex);
    innerVarIndex_flat=flattenVarIndex(innerVarIndex);
    [oldVarIndex_flat,oldNumVarsPerAxes]=flattenVarIndex(oldVarIndex);
    oldInnerVarIndex_flat=flattenVarIndex(oldInnerVarindex);




    newVars=[varIndex_flat(:),innerVarIndex_flat(:)];
    oldVars=[oldVarIndex_flat(:),oldInnerVarIndex_flat(:)];
    [inOldVariableIndex_flat,locInOldVariableIndex_flat]=ismember(newVars,oldVars,'rows');


    [axesMapping,oldcumlengths]=createAxesMapping(oldNumVarsPerAxes,locInOldVariableIndex_flat);




    getVariableByCacheIndex=@(idx)getVariableByIndex(obj,oldVarIndex_flat(idx),oldInnerVarIndex_flat(idx));
    plotMapping=createPlotMapping(axesMapping,locInOldVariableIndex_flat,oldcumlengths,inOldVariableIndex_flat,getVariableByCacheIndex);


    if iscell(varIndex)
        axesMapping=mat2cell(axesMapping,1,newNumVarsPerAxes);
        plotMapping=mat2cell(plotMapping,1,newNumVarsPerAxes);
    end
end

function[varIndex_flat,numVarsPerAxes]=flattenVarIndex(varIndex)




    if iscell(varIndex)
        if nargout>1
            numVarsPerAxes=cellfun('length',varIndex);
        end
        varIndex_flat=[varIndex{:}];
    else
        if nargout>1
            numVarsPerAxes=ones(size(varIndex));
        end
        varIndex_flat=varIndex;
    end
end


function v=getVariableByIndex(obj,varidx,innervaridx)


    v=obj.ChartData.SourceTable{:,varidx};


    if isa(v,'tabular')

        v=v.(innervaridx);
    end
end