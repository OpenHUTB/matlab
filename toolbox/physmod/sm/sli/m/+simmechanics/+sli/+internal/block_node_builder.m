function blkNode=block_node_builder(fullfileName)


















    blkNode=[];



    [fPath,fName,fExt]=fileparts(fullfileName);
    if isempty(fPath)
        fPath=pwd;
    end
    fullfileName=fullfile(fPath,[fName,fExt]);

    if((strcmp(fExt,'.m'))||(strcmp(fExt,'.p')))&&...
        (~strcmp(fName,'lib'))&&...
        (~contains(fName,'sl_postprocess'))&&...
        (fName(1)~='.')


        if strcmp(fExt,'.m')
            pfile=fullfile(fPath,[fName,'.p']);
            if exist(pfile,'file')
                return;
            end
        end

        setupFunctionH=pm.util.function_handle(fullfileName);
        funcStr=func2str(setupFunctionH);
        blkInfo=feval(funcStr);
        if(strcmpi(blkInfo.Hidden,'off'))
            blkNode=pm.util.SimpleNode(fullfileName);
            blkNode.Info=blkInfo;
        end
    end

end


