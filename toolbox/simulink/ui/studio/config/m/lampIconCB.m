


function schema=lampIconCB(fncname,userData,cbinfo,~)
    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(userData,cbinfo);
    else
        schema=[];
        fnc(userData,cbinfo);
    end
end

function setIcon(userData,cbinfo)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(block)
        return;
    end
    blockHandle=block.handle;
    isLampBlock=strcmp(get_param(blockHandle,'BlockType'),'LampBlock');
    isPushButtonBlock=strcmp(get_param(blockHandle,'BlockType'),'PushButtonBlock');


    if~isLampBlock&&~isPushButtonBlock
        return;
    end

    if isLampBlock

        setIconForLamp(userData,blockHandle);
    else

        setIconForPushButton(userData,blockHandle);
    end
end

function setIconForLamp(userData,blockHandle)
    if~strcmp(userData,'CustomIconUpload')
        set_param(blockHandle,'Icon',userData);
    else
        [file,path]=uigetfile('*.svg');
        if~isequal(file,0)
            [~,~,ext]=fileparts(file);
            if~strcmp(ext,'.svg')
                error(message('SimulinkHMI:dashboardblocks:lampInvalidCustomIconText'));
            else
                icon=fileread(fullfile(path,file));
                iconBase64=['data:image/svg+xml;base64,',matlab.net.base64encode(icon)];
                set_param(blockHandle,'CustomIcon',iconBase64);
            end
        end
    end
end

function setIconForPushButton(userData,blockHandle)
    if~strcmp(userData,'CustomIconUpload')
        if strcmp(get_param(blockHandle,'Icon'),userData)
            set_param(blockHandle,'Icon','None')
        else
            set_param(blockHandle,'Icon',userData);
        end
    else
        imageFileExtension={'*.svg';'*.jpg';'*.png';'*.gif';'*.bmp'};
        [file,path]=uigetfile(imageFileExtension,'File Selector');
        if~isequal(file,0)
            [~,~,ext]=fileparts(file);
            if~strcmp(ext,'.svg')&&~strcmp(ext,'.jpg')&&...
                ~strcmp(ext,'.png')&&~strcmp(ext,'.gif')&&...
                ~strcmp(ext,'.bmp')
                error(message('SimulinkHMI:dashboardblocks:lampInvalidCustomIconText'));
            else
                icon=fileread(fullfile(path,file));
                ext=ext(2:end);
                if strcmp(ext,'svg')
                    ext=[ext,'+xml'];
                end
                iconBase64=['data:image/',ext,';base64,',matlab.net.base64encode(icon)];
                set_param(blockHandle,'CustomIcon',iconBase64);
            end
        end
    end
end