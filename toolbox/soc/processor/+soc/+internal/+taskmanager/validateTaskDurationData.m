function validateTaskDurationData(data)




    locValidatePercents(data);
    locValidateMeans(data);
    locValidateLowerLimit(data);
    locValidateUpperLimit(data);
    locValidateSD(data);

    locValidateCumulativePercents(data);
    locValidateLimits(data);
    locValidateMeansVsLimits(data);
end


function locValidatePercents(data)
    allPercents=locHlpGetParamForAllTasks(data,'percent');
    locHlpValidateElem(allPercents,'soc:utils:InvalidPercent');
end


function locValidateMeans(data)
    allMeans=locHlpGetParamForAllTasks(data,'mean');
    locHlpValidateElem(allMeans,'soc:utils:InvalidMean');
end


function locValidateSD(data)
    allSDs=locHlpGetParamForAllTasks(data,'dev');
    locHlpValidateElem(allSDs,'soc:utils:InvalidSD','inclusive');
end


function locValidateLowerLimit(data)
    allLowLimits=locHlpGetParamForAllTasks(data,'min');
    locHlpValidateElem(allLowLimits,'soc:utils:InvalidLowerLim','inclusive');
end


function locValidateUpperLimit(data)
    allUppLimits=locHlpGetParamForAllTasks(data,'max');
    locHlpValidateElem(allUppLimits,'soc:utils:InvalidUpperLim','inclusive');
end


function locValidateCumulativePercents(data)
    allPercents=locHlpGetParamForAllTasks(data,'percent');

    if locHlpIsDataVariable(allPercents),return;end
    mySum=sum(allPercents);
    if~isequal(sum(allPercents),100)
        locHlpValidateRangeInclusive(mySum,[100,100],'soc:utils:InvalidPercentSum');
    end
end


function locValidateLimits(data)
    allLowLimits=locHlpGetParamForAllTasks(data,'min');
    allUppLimits=locHlpGetParamForAllTasks(data,'max');

    if locHlpIsDataVariable(allLowLimits)||locHlpIsDataVariable(allUppLimits)
        return;
    end
    for i=1:numel(allLowLimits)
        if(allLowLimits(i)>allUppLimits(i))
            error(message('soc:utils:LowerLimGTUpperLimit'));
        end
    end
end


function locValidateMeansVsLimits(data)
    allMeans=locHlpGetParamForAllTasks(data,'mean');
    allLowLimits=locHlpGetParamForAllTasks(data,'min');
    allUppLimits=locHlpGetParamForAllTasks(data,'max');

    if locHlpIsDataVariable(allMeans)||...
        locHlpIsDataVariable(allLowLimits)||...
        locHlpIsDataVariable(allUppLimits)
        return;
    end
    for i=1:numel(allLowLimits)
        mean=allMeans(i);
        mmin=allLowLimits(i);
        mmax=allUppLimits(i);
        locHlpValidateTwoElems(mean,mmax,'soc:utils:MeanGTUpperLim','LT');
        locHlpValidateTwoElems(mean,mmin,'soc:utils:MeanLTLowerLim','GT');
    end
end


function locHlpValidateTwoElems(dataVector1,dataVector2,msgID,compType)
    for i=1:numel(dataVector1)
        switch compType
        case 'LT'
            if(dataVector1(i)>dataVector2(i))
                error(message(msgID));
            end
        case 'GT'
            if(dataVector1(i)<dataVector2(i))
                error(message(msgID));
            end
        otherwise
            assert(false,'Wrong compare type.');
        end
    end
end


function locHlpValidateElem(data,msgID,varargin)

    if locHlpIsDataVariable(data),return;end
    for i=1:numel(data)
        upperLim=str2double(data(i));
        if isequal(nargin,2)
            locHlpValidateRange(upperLim,[0,inf],msgID);
        else
            locHlpValidateRangeInclusiveLeft(upperLim,[0,inf],msgID);
        end
    end
end


function locHlpValidateRangeInclusive(val,range,errorID)
    if(val<range(1))||(val>range(2))
        error(message(errorID));
    end
end


function locHlpValidateRangeInclusiveLeft(val,range,errorID)
    if(val<range(1))||(val>=range(2))
        error(message(errorID));
    end
end


function locHlpValidateRange(val,range,errorID)
    if(val<=range(1))||(val>=range(2))
        error(message(errorID));
    end
end


function ret=locHlpIsDataVariable(data)
    ret=iscell(data)&&...
    any(cell2mat(cellfun(@(x)isvarname(x),data,'UniformOutput',false)));
end


function ret=locHlpGetParamForAllTasks(data,pName)
    [found,idx]=ismember(pName,{'percent','mean','dev','min','max'});
    assert(found,'Wrong field name used');
    if iscell(data)
        ret=data(:,idx);
        if~locHlpIsDataVariable(ret)
            ret=str2double(ret);
        end
    else
        ret=arrayfun(@(x)x.(pName),data);
    end
end
