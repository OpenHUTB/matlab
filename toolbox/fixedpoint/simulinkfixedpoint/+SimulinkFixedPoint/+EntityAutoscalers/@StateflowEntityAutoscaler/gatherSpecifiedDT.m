function[DTConInfo,Comments,paramNames]=gatherSpecifiedDT(h,sfData,pathItem)%#ok




    isResolved=sfData.Props.ResolveToSignalObject;
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';


    Comments={};

    if isResolved

        DTStr='Inherit: From Simulink signal object';
    else
        DTStr=sfData.DataType;
    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(DTStr,getSLResolveContext(sfData));

end


function context=getSLResolveContext(sfData)

    chartId=sf('DataChartParent',sfData.Id);
    parentH=sfprivate('chart2block',chartId);
    context=get_param(parentH,'Object');

end




