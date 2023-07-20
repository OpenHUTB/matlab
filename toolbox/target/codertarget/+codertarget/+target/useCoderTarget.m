function useCoderTarget(hSrc,value,varargin)




    action={'DoNotUseCoderTarget','UseCoderTarget'};
    boardName='';
    if(nargin>=3)
        boardName=varargin{1};
    end
    if(nargin>=4)
        doReset=varargin{2};
    end

    hCS=hSrc.getConfigSet();

    codertarget.updateExtension(hCS,action{value+1});

    if hCS.isValidParam('CoderTargetData')
        codertarget.data.setParameterValue(hCS,'UseCoderTarget',logical(value));
        hwName=codertarget.target.getTargetHardwareNameFromDisplayName(boardName);
        codertarget.data.setParameterValue(hCS,'TargetHardware',hwName);
    end

    if hCS.isValidParam('CoderTargetData')&&...
        codertarget.data.getParameterValue(hCS,'UseCoderTarget')
        loc_setDefaultHardwareBoardFeatureSet(hCS,hwName,doReset);
        targetHardwareInfo=codertarget.targethardware.getTargetHardware(hCS);
        if~isempty(targetHardwareInfo)
            codertarget.data.initializeTargetData(hCS);
            codertarget.target.updateCSOptionsForCoderTarget(hCS,'entry',...
            codertarget.utils.isMdlConfiguredForSoC(hCS));

            codertarget.target.initializeTarget(hCS,targetHardwareInfo);
        end
    else
        codertarget.target.updateCSOptionsForCoderTarget(hCS,'exit');
        set_param(hCS,'HardwareBoard',...
        DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone'));
    end
end


function loc_setDefaultHardwareBoardFeatureSet(hCS,hwName,doReset)
    if(codertarget.utils.isSoCInstalled&&codertarget.utils.isBoardSoCCompatible(hwName))



        if doReset
            fsValue='SoCBlockset';
        else
            fsValue=get_param(hCS.getConfigSetCache,'HardwareBoardFeatureSet');
        end
    else
        fsValue='EmbeddedCoderHSP';
    end
    set_param(hCS,'HardwareBoardFeatureSet',fsValue);
    codertarget.utils.setESBPluginAttached(hCS,isequal(fsValue,'SoCBlockset'));
end