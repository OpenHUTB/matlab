
function openRTMXWindow(cbinfo)

    [~,canvasModelH]=slreq.toolstrip.getModelHandle(cbinfo);

    filePath=get_param(canvasModelH,'fileName');
    if isempty(filePath)

    else
        option.showArtifactSelector=true;
        option.queryOtherDataInMemory=true;
        slreq.report.rtmx.utils.generateRTMX({filePath},option);
    end
end