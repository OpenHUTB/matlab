function ToWorkspaceCompileCheck(block,muObj)










    appendCompileCheck(muObj,block,@CollectTwsBlockData,...
    @UpdateTwsBlockNewFrames);

end


function blkInfo=CollectTwsBlockData(block,~)


    blkInfo.Frame=get_param(block,'CompiledPortFrameData');
    blkInfo.SaveFormat=get_param(block,'SaveFormat');
    hPorts=get_param(block,'PortHandles');
    blkInfo.isVarSizeSignal=get_param(hPorts.Inport(1),...
    'CompiledPortDimensionsMode')==1;
    blkInfo.Save2DSignal=get_param(block,'Save2DSignal');

end



function UpdateTwsBlockNewFrames(block,muObj,blkInfo)
    isArrayOrStruct=strcmp(blkInfo.SaveFormat,'Array')||...
    strcmp(blkInfo.SaveFormat,'Structure');
    isDataFrame=blkInfo.Frame.Inport(1)==1;

    if isArrayOrStruct&&strcmp(blkInfo.Save2DSignal,...
        'Inherit from input (this choice will be removed - see release notes)')

        if askToReplace(muObj,block)


            if isDataFrame
                Save2DSignalStr='2-D array (concatenate along first dimension)';
                reasonStr=DAStudio.message('Simulink:logLoadBlocks:UpAdvSave2dMode_SAVE_AS_2D_ReasonStr');
            else
                Save2DSignalStr='3-D array (concatenate along third dimension)';
                reasonStr=DAStudio.message('Simulink:logLoadBlocks:UpAdvSave2dMode_SAVE_AS_3D_ReasonStr');
            end


            if(doUpdate(muObj))
                SetSave2DSignalParam(block,Save2DSignalStr);
            end

            funcSet={'SetSave2DSignalParam',block,Save2DSignalStr};
            appendTransaction(muObj,block,reasonStr,{funcSet});
        end
    end

end


function SetSave2DSignalParam(block,Save2DSignalStr)
    set_param(block,'Save2DSignal',Save2DSignalStr);
end


