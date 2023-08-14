
function UnitDelayRegisterCompileCheck(block,h)



    appendCompileCheck(h,block,@loc_CollectUnitDelayBlockData,@loc_ReplaceUnitDelayWithMemory);
end


function Data=loc_CollectUnitDelayBlockData(block,~)
    Data.isDiscrete=true;
    ret=get_param(block,'CompiledSampleTime');





    if(~iscell(ret)&&((ret(1)==0)&&(ret(2)==1)))
        Data.isDiscrete=false;
    end
end

function loc_ReplaceUnitDelayWithMemory(block,h,Data)

    if askToReplace(h,block)
        if(Data.isDiscrete==true)
            return;
        end

        reason=DAStudio.message('SimulinkBlocks:upgrade:unitDelayBlockContinuousMode');

        oldIC=get_param(block,'InitialCondition');
        oldSN=get_param(block,'StateName');
        oldSMRTSO=get_param(block,'StateMustResolveToSignalObject');
        oldSSO=get_param(block,'StateSignalObject');
        oldSSC=get_param(block,'StateStorageClass');
        oldCGSSTQ=get_param(block,'CodeGenStateStorageTypeQualifier');

        funcSet=uReplaceBlock(h,block,'built-in/Memory',...
        'InitialCondition',oldIC,...
        'InheritSampleTime','off',...
        'LinearizeMemory','off',...
        'LinearizeAsDelay','on',...
        'StateName',oldSN,...
        'StateMustResolveToSignalObject',oldSMRTSO,...
        'StateSignalObject',oldSSO,...
        'StateStorageClass',oldSSC,...
        'RTWStateStorageTypeQualifier',oldCGSSTQ);

        appendTransaction(h,block,reason,{funcSet});
    end
end
