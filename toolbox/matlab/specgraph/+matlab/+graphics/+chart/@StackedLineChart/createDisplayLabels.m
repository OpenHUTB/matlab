function createDisplayLabels(hObj,axesMapping,plotMapping)





    updateDisplayLabelsHandle(hObj);
    if strcmp(hObj.DisplayLabelsMode,'auto')
        hObj.DisplayLabels_I=hObj.Presenter.getAxesLabels();
    else
        axesMappingFlat=flattenAxesMapping(axesMapping);
        if hObj.JustCreated

            hObj.DisplayLabels_I=hObj.DisplayLabels_I(:);
        elseif~any(axesMappingFlat)


            hObj.DisplayLabelsMode='auto';
        else

            if~isIdentityMapping(axesMapping,plotMapping)
                hObj.DisplayLabels_I=getManualDisplayLabels(hObj,axesMapping,plotMapping);
            else

                hObj.DisplayLabels_I=hObj.DisplayLabels_I;
            end
        end
    end

    set(hObj.DisplayLabelsHandle,...
    'HorizontalAlignment','right',...
    'VerticalAlignment','middle',...
    'Interpreter','none',...
    'Rotation',0...
    );
end

function updateDisplayLabelsHandle(hObj)

    hObj.DisplayLabelsHandle=hObj.DisplayLabelsHandle([]);
    numAxes=hObj.getNumAxesCapped();
    for i=1:numAxes
        hObj.DisplayLabelsHandle(i)=hObj.Axes_I(i).YAxis.Label;
    end
end

function axesMappingFlat=flattenAxesMapping(axesMapping)

    if iscell(axesMapping)
        axesMappingFlat=[axesMapping{:}];
    else
        axesMappingFlat=axesMapping;
    end
end

function tf=isIdentityMapping(axesMapping,plotMapping)


    tf=true;
    if iscell(axesMapping)
        for i=1:length(axesMapping)
            for j=1:length(axesMapping{i})
                if~isequal(axesMapping{i}(j),i)||~isequal(plotMapping{i}(j),j)
                    tf=false;
                    return
                end
            end
        end
    else
        tf=isequal(axesMapping,1:length(axesMapping))&&...
        isequal(plotMapping,ones(1,length(plotMapping)));
    end
end

function labels=getManualDisplayLabels(hObj,axesMapping,plotMapping)

    numAxes=hObj.getNumAxesCapped();
    labels=cell(numAxes,1);
    for axesIndex=1:numAxes
        labels=getManualDisplayLabelsForAxes(hObj,labels,axesIndex,axesMapping,plotMapping);
    end
end

function labels=getManualDisplayLabelsForAxes(hObj,labels,axesIndex,axesMapping,plotMapping)

    yData=hObj.Presenter.getAxesYData(axesIndex);
    currAxesMapping=getElement(axesMapping,axesIndex);
    currPlotMapping=getElement(plotMapping,axesIndex);
    for varPos=1:length(yData)
        oldAxesIndex=currAxesMapping(varPos);
        oldPlotIndex=currPlotMapping(varPos);
        varInOldAxes=0<oldAxesIndex&&oldAxesIndex<=hObj.MaxNumAxes;
        if varInOldAxes
            label=getOldDisplayLabelForVariable(hObj,oldAxesIndex,oldPlotIndex);
        else
            label=getAutoDisplayLabelForVariable(hObj,axesIndex,varPos);
        end
        if isscalar(yData)
            labels(axesIndex)=label;
        else
            labels{axesIndex}(varPos)=label;
        end
    end
    if iscell(labels{axesIndex})
        labels{axesIndex}=labels{axesIndex}(:);
        labels=collapseDisplayLabelsForAxes(labels,axesIndex);
    end
end


function v=getElement(C,i)
    if iscell(C)
        v=C{i};
    else
        v=C(i);
    end
end

function label=getOldDisplayLabelForVariable(hObj,oldAxesIndex,oldPlotIndex)

    if iscell(hObj.DisplayLabels_I{oldAxesIndex})
        oldPlotIndex=min(oldPlotIndex,length(hObj.DisplayLabels_I{oldAxesIndex}));
        label=hObj.DisplayLabels_I{oldAxesIndex}(oldPlotIndex);
    else
        label=hObj.DisplayLabels_I(oldAxesIndex);
    end
end

function label=getAutoDisplayLabelForVariable(hObj,axesIndex,varPos)

    yData=hObj.Presenter.getAxesYData(axesIndex);
    label=hObj.Presenter.getAxesLabels(axesIndex);
    if~isscalar(yData)
        label=label(varPos);
    end
end

function labels=collapseDisplayLabelsForAxes(labels,axesIndex)

    if isequal(labels{axesIndex}{:})
        labels{axesIndex}=labels{axesIndex}{1};
    end
end
