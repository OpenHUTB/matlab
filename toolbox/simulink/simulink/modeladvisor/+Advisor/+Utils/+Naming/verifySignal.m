function result=verifySignal(thisSignal)




    result=true;

    signalName=get_param(thisSignal,'Name');

    if isempty(signalName)
        result=false;
        return;
    end


    if signalName(1)=='<'&&signalName(end)=='>'
        result=false;
        return;
    end


    signalParent=get_param(thisSignal,'Parent');
    type=get_param(signalParent,'Type');
    if strcmp(type,'block')
        linkStatus=get_param(signalParent,'LinkStatus');
        if strcmp(linkStatus,'resolved')||strcmp(linkStatus,'implicit')
            referenceBlock=get_param(signalParent,'ReferenceBlock');
            libraryName=strtok(referenceBlock,'/');

            switch libraryName
            case 'simulink'
                result=false;
                return;
            otherwise
                libraryPath=which(libraryName);
                toolboxRoot=[matlabroot,filesep,'toolbox'];
                if strncmp(libraryPath,toolboxRoot,numel(toolboxRoot))
                    result=false;
                    return;
                end
            end

        end
    end

end

