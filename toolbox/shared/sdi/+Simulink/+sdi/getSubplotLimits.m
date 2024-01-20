function[tMin,tMax,yMin,yMax]=getSubplotLimits(r,c,varargin)

    try
        inputResults=locParseInput(r,c,varargin{:});
        limits=getClientLimits(inputResults);
        tMin=limits(1);
        tMax=limits(2);
        yMin=limits(3);
        yMax=limits(4);
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
    parse(limitsInput,r,c,varargin{:});
    inputResults=limitsInput.Results;
end


function limits=getClientLimits(inputs)
    import Simulink.sdi.internal.Util;
    limits=[];
    view=lower(inputs.view);
    Util.validateLayoutRange(inputs.row,inputs.column,view);
    expectedTypes={'Time Plot'};
    Util.validateVizType(inputs.row,inputs.column,view,expectedTypes);
    client=Util.getClientFromView(view);
    if~isempty(client)
        isComparison=strcmp(view,'compare');
        clientID=str2double(client.ClientID);
        Simulink.sdi.waitForPlottingOnClient(clientID,isComparison);
        len=length(client.Axes);
        for idx=1:len
            curr=client.Axes(idx);
            plotIdx=uint8((inputs.column-1)*8+inputs.row);
            if curr.AxisID==plotIdx
                limits(1:2)=curr.TimeSpan;
                limits(3:4)=curr.YRange;
                break;
            end
        end
    else
        switch view
        case 'inspect'
            plotPref=Simulink.sdi.getViewPreferences().plotPref;
            idx=sub2ind([plotPref.numPlotRows,plotPref.numPlotCols],inputs.row,inputs.column);
            limits=Simulink.sdi.getSubplotZoomLevels(idx);
        case 'compare'
            error(message('SDI:sdi:NoConnectedClient'));
        end
    end
end
