
function loadLinks(cbinfo)

    [~,canvasModelHandle]=slreq.toolstrip.getModelHandle(cbinfo);


    rmidata.loadFromFile(canvasModelHandle);
end
