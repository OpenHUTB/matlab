

function highlightSignalInModel(model,blockHandle,portNum)
    modelHandle=get_param(model,'Handle');
    if~ishandle(modelHandle)
        return
    end
    if portNum<=0



        utils.hiliteAndFade_system(blockHandle,model);
    else
        lineHandle=utils.getLineHandle(blockHandle,portNum);
        if lineHandle~=-1


            utils.hiliteAndFade_system(lineHandle,model);
        end
    end
end