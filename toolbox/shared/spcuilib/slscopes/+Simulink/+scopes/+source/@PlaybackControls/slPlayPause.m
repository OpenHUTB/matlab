function slPlayPause(this,~,~)












    srcObj=this.Source;
    srcObj.StepFwd=false;


    if srcObj.isRunning
        cmd='pause';
    elseif srcObj.isPaused
        cmd='continue';
    elseif srcObj.isStopped
        cmd='start';
    else

        return
    end



    if slfeature('slPbcModelRefEditorReuse')&&isprop(srcObj.BlockHandle,'StudioTopLevel')


        hModelString="";
        if strcmp(get_param(srcObj.BlockHandle.handle,'Type'),'block')
            hModelString=get_param(srcObj.BlockHandle.handle,'StudioTopLevel');
        end

        if~strcmp(hModelString,"")
            storedHandle=str2double(hModelString);
            storedSimulationStatus=get_param(storedHandle,'SimulationStatus');
            srcObjParent=get_param(srcObj.BlockHandle.Parent,'Handle');


            if(srcObjParent~=storedHandle)
                switch lower(storedSimulationStatus)
                case 'paused'
                    cmd='continue';
                case 'running'
                    cmd='pause';
                case 'stopped'
                    cmd='start';
                end
            end
        end
    end





    srcObj.PlayPauseButton=true;

    try
        sendSimulationCommand(srcObj,cmd);
        drawnow;
    catch me
        msg=uiservices.cleanErrorMessage(me.message);
        uiscopes.errorHandler(msg);
    end

    srcObj.PlayPauseButton=false;


