

function hiliteAndFade_system(elemHandle,model,varargin)









    if(ischar(elemHandle))
        elemHandle=str2double(elemHandle);
    end

    if(~ishandle(elemHandle))
        return;
    end

    modelHandle=model;
    if(ischar(model))
        modelHandle=str2double(model);
        if(isnan(modelHandle))

            modelHandle=get_param(model,'Handle');
        end
    end

    if(~ishandle(modelHandle))
        return;
    end

    blockInPanel=false;



    if(strcmp(get_param(elemHandle,'Type'),'block'))
        blockH=elemHandle;
        blockInPanel=isBlockInWebPanel(elemHandle);
    end


    if(strcmp(get_param(elemHandle,'Type'),'line'))
        blockH=get_param(elemHandle,'SrcBlockHandle');
    end

    if(nargin==3)
        blockPath=varargin{1};
    else
        blockPath=Simulink.BlockPath(getfullname(blockH));
    end


    if~blockInPanel
        blockPath.openParent();
    end
    Simulink.HMI.highlightElement(modelHandle,elemHandle);

    if~blockInPanel
        Simulink.scrollToVisible(elemHandle,'ensureFit','on','panMode','minimal');
    end
end