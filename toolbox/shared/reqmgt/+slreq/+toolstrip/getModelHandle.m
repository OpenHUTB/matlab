
function[rootModelHandle,canvasModelHandle]=getModelHandle(cbInfo)
    studioHelper=slreq.utils.DAStudioHelper.createHelper(cbInfo.studio);
    rootModelHandle=studioHelper.TopModelHandle;
    canvasModelHandle=studioHelper.ActiveModelHandle;



end


function modelH=target2ModelHandle(modelH)





end
