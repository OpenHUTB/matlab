function stateflowInfo=stateflowPathToStruct(pathStr)




    colonInds=regexp(pathStr,":","start");
    if isempty(colonInds)
        block=pathStr;
        ssid=[];
    else
        colonInds=colonInds(end);
        block=extractBefore(pathStr,colonInds);
        ssid=str2double(extractAfter(pathStr,colonInds));
    end

    stateflowInfo=struct(...
    'Block',block,...
    'SSID',ssid...
    );
end