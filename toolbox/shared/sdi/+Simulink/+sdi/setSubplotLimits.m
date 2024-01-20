function setSubplotLimits(r,c,varargin)

    try
        inputResults=locParseInput(r,c,varargin{:});
        setClientLimits(inputResults);
    catch ex
        throwAsCaller(ex);
    end
end


function inputResults=locParseInput(r,c,varargin)
    import Simulink.sdi.internal.Util;
    limitsInput=inputParser;
    addRequired(limitsInput,'row',@Util.layoutValidationFcn);
    addRequired(limitsInput,'column',@Util.layoutValidationFcn);
    addParameter(limitsInput,'view','inspect',@Util.viewValidationFcn);
    nameKeys={'allrange','trange','yrange','ymin','ymax','tmin','tmax'};
    foundNames='';
    viewInput='inspect';
    for key=1:length(varargin)
        if strcmpi(varargin{key},'view')
            viewInput=varargin{key+1};
            continue;
        end
        try
            matchedStr=validatestring(lower(varargin{key}),nameKeys);
            foundNames=strcat(foundNames,matchedStr);
        catch
            continue;
        end
    end
    if contains(foundNames,'allrange')&&~strcmp(foundNames,'allrange')
        error(message('SDI:sdi:InvalidNameValuePairsAll'));
    elseif contains(foundNames,'trange')&&(contains(foundNames,'tmin')||contains(foundNames,'tmax'))
        error(message('SDI:sdi:InvalidNameValuePairsT'));
    elseif contains(foundNames,'yrange')&&(contains(foundNames,'ymin')||contains(foundNames,'ymax'))
        error(message('SDI:sdi:InvalidNameValuePairsY'));
    end
    [t1,t2,y1,y2]=Simulink.sdi.getSubplotLimits(r,c,'view',viewInput);
    currentLimits=[t1,t2,y1,y2];

    if contains(foundNames,'allrange')
        addParameter(limitsInput,'allrange',currentLimits,@vector4ValidationFcn);
    end
    if contains(foundNames,'trange')
        addParameter(limitsInput,'trange',currentLimits(1:2),@vector2ValidationFcn);
    end
    if contains(foundNames,'yrange')
        addParameter(limitsInput,'yrange',currentLimits(3:4),@vector2ValidationFcn);
    end
    if contains(foundNames,'tmin')
        addParameter(limitsInput,'tmin',currentLimits(1),@limitValidationFcn);
    end
    if contains(foundNames,'tmax')
        addParameter(limitsInput,'tmax',currentLimits(2),@limitValidationFcn);
    end
    if contains(foundNames,'ymin')
        addParameter(limitsInput,'ymin',currentLimits(3),@limitValidationFcn);
    end
    if contains(foundNames,'ymax')
        addParameter(limitsInput,'ymax',currentLimits(4),@limitValidationFcn);
    end

    parse(limitsInput,r,c,varargin{:});
    inputResults=limitsInput.Results;

    tLimits=currentLimits(1:2);
    if isfield(inputResults,'tmin')
        tLimits(1)=inputResults.tmin;
    end
    if isfield(inputResults,'tmax')
        tLimits(2)=inputResults.tmax;
    end
    if isfield(inputResults,'trange')
        trange=inputResults.trange;
        for idx=1:length(trange)
            curr=trange(idx);
            if isfinite(curr)
                tLimits(idx)=curr;
            end
        end
    end

    yLimits=currentLimits(3:4);
    if isfield(inputResults,'ymin')
        yLimits(1)=inputResults.ymin;
    end
    if isfield(inputResults,'ymax')
        yLimits(2)=inputResults.ymax;
    end
    if isfield(inputResults,'yrange')
        yrange=inputResults.yrange;
        for idx=1:length(yrange)
            curr=yrange(idx);
            if isfinite(curr)
                yLimits(idx)=curr;
            end
        end
    end

    allLimits=[tLimits,yLimits];
    if isfield(inputResults,'allrange')
        allrange=inputResults.allrange;
        for idx=1:length(allrange)
            curr=allrange(idx);
            if isfinite(curr)
                allLimits(idx)=curr;
            end
        end
    end
    validateattributes(allLimits(1:2),'double',{'increasing'},'','trange');
    validateattributes(allLimits(3:4),'double',{'increasing'},'','yrange');

    inputResults.limits=allLimits;
end


function limitValidationFcn(limVal)
    validateattributes(limVal,'numeric',{'real','finite','scalar'});
end


function vectorValidationFcn(vecVal,size)

    len=length(vecVal);
    vecSize=getString(message('SDI:sdi:VectorSize'));
    validateattributes(len,'numeric',{'scalar','>=',1,'<=',size},'',vecSize);

    for index=1:len
        curr=vecVal(index);
        if isfinite(curr)&&mod(index,2)
            if(index+1<=len&&isfinite(vecVal(index+1)))
                validateattributes([curr,vecVal(index+1)],'double',{'real'});
            end
        end
    end
end


function vector2ValidationFcn(vecVal)
    vectorValidationFcn(vecVal,2);
end


function vector4ValidationFcn(vecVal)
    vectorValidationFcn(vecVal,4);
end


function setClientLimits(inputs)
    import Simulink.sdi.internal.Util;
    view=lower(inputs.view);
    Util.validateLayoutRange(inputs.row,inputs.column,view);
    expectedTypes={'Time Plot'};
    Util.validateVizType(inputs.row,inputs.column,view,expectedTypes);
    client=Util.getClientFromView(view);
    if~isempty(client)
        len=length(client.Axes);
        plotIdx=uint8((inputs.column-1)*8+inputs.row);
        isLinked=1;
        for idx=1:len
            curr=client.Axes(idx);
            if curr.AxisID==plotIdx
                isLinked=curr.IsLinked;
                break;
            end
        end

        for idx=1:len
            curr=client.Axes(idx);
            if curr.AxisID==plotIdx

                curr.TimeSpan=inputs.limits(1:2);
                Util.waitForTimeSpanUpdate(client,idx,inputs.limits(1:2));
                curr.YRange=inputs.limits(3:4);
                Util.waitForYRangeUpdate(client,idx,inputs.limits(3:4));
            else
                if isLinked&&curr.IsLinked

                    curr.TimeSpan=inputs.limits(1:2);
                    Util.waitForTimeSpanUpdate(client,idx,inputs.limits(1:2));
                end
            end
        end
    else
        switch lower(inputs.view)
        case 'inspect'
            plotPref=Simulink.sdi.getViewPreferences().plotPref;
            idx=sub2ind([plotPref.numPlotRows,plotPref.numPlotCols],inputs.row,inputs.column);
            Simulink.sdi.setSubplotZoomLevels(idx,inputs.limits);
        case 'compare'
            error(message('SDI:sdi:NoConnectedClient'));
        end
    end
end
