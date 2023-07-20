function updateExtension(hSrc,event)




    hCS=hSrc.getConfigSet();

    switch(event)
    case('UseCoderTarget')
        hCS.setPropEnabled('ProdHWDeviceType',0);
        loc_setCoderTargetComponent(hCS);
    case('DoNotUseCoderTarget')
        if~isempty(hCS.getComponent('Coder Target'))
            hCS.detachComponent('Coder Target');
        end
        hCS.setPropEnabled('ProdHWDeviceType',1);
        set_param(hCS,'InlineParams','on');
    case('activate')
        isBoardRegistered=true;
        if loc_isCoderTarget(hCS)
            targetHW=codertarget.data.getParameterValue(hCS,...
            'TargetHardware');
            hwDisplayName=...
            codertarget.target.getTargetHardwareDisplayNameFromName(...
            targetHW);
            registeredTargetHW=...
            codertarget.targethardware.getRegisteredTargetHardwareNames;
            if ismember(hwDisplayName,registeredTargetHW)||...
                ismember(targetHW,registeredTargetHW)
                if~isequal(get_param(hCS,'HardwareBoard'),hwDisplayName)
                    set_param(hCS,'HardwareBoard',hwDisplayName);
                end


                loc_hardwareBoardForwarding(hCS,hwDisplayName);

                loc_parameterForwarding(hCS);
                codertarget.data.update(hCS);
            elseif~isempty(targetHW)
                boardName=get_param(hCS,'HardwareBoard');
                if ismember(boardName,registeredTargetHW)

                    loc_hardwareBoardForwarding(hCS,boardName);

                    loc_parameterForwarding(hCS);
                    codertarget.data.setParameterValue(hCS,'TargetHardware',boardName);
                else
                    isBoardRegistered=false;
                    warning(message(...
                    'codertarget:build:SupportPackageNotInstalled',...
                    targetHW,targetHW,targetHW));
                end
            end





            hwBoard=get_param(hCS,'HardwareBoard');
            [out,missingBaseProduct]=...
            codertarget.utils.isSpPkgInstalledForSelectedBoard(hCS,hwBoard);
            if~out&&isBoardRegistered
                warning(message(...
                'codertarget:build:SupportPackageNotInstalled',...
                [missingBaseProduct,hwBoard],hwBoard,hwBoard));
            end


            codertarget.data.initializeTargetData(hCS,'update');
            if~slprivate('getIsExportFcnModel',hCS.getModel)
                hCS.setPropEnabled('GenerateSampleERTMain',1);
                set_param(hCS,'GenerateSampleERTMain','off');
            end
            loc_updateTLCOptions(hCS);
            hw=codertarget.targethardware.getTargetHardware(hCS);
            if~isempty(hw)
                enabled=hw.EnableProdHWDeviceType;
                hCS.setPropEnabled('ProdHWDeviceType',enabled);
            end


            if codertarget.utils.isMdlConfiguredForSoC(hCS)
                codertarget.utils.setESBPluginAttached(hCS,true);
            end
        end
    case('deselect_target')
        if~isempty(hCS.getComponent('Coder Target'))&&...
            ~codertarget.target.supportsCoderTarget(hCS,true)
            loc_onTargetHardwareDeselect(hCS);
            hCS.detachComponent('Coder Target');
            codertarget.target.updateCSOptionsForCoderTarget(hCS,'exit');
            set_param(hCS,'HardwareBoard','None');
        end
    end
end



function loc_setCoderTargetComponent(hCS)
    if~isempty(hCS)
        if isempty(hCS.getComponent('Coder Target'))
            component=CoderTarget.SettingsController;
            hCS.attachComponent(component);
            if isempty(get_param(hCS,'CoderTargetData'))
                data.UseCoderTarget=false;
                data.TargetHardware='';
                set_param(hCS,'CoderTargetData',data);
            end
        end
        set_param(hCS,'InlineParams','off');
        hCS.setPropEnabled('GenerateSampleERTMain',1);
    end
end



function loc_onTargetHardwareDeselect(hCS)
    targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
    if~isempty(targetInfo)&&~isempty(targetInfo.getOnHardwareDeselectHook)
        feval(targetInfo.getOnHardwareDeselectHook,hCS);
    end
end



function ret=loc_isCoderTarget(hCS)
    ret=~isempty(hCS.getComponent('Coder Target'))&&...
    hCS.isValidParam('CoderTargetData')&&...
    ~isempty(get_param(hCS,'CoderTargetData'));
    if ret
        targetHW=codertarget.data.getParameterValue(hCS,'TargetHardware');
        ret=~isequal(targetHW,'None');
    end
end



function loc_updateTLCOptions(hCS)




    os=codertarget.targethardware.getTargetRTOS(hCS);
    tlcOptionsStr=get_param(hCS,'TLCOptions');
    tlcOptions=...
    {'-aRateBasedStepFcn=1';...
'-aRateBasedStepFcn=0'
    };
    if isequal(os,'Baremetal')
        tlcOptionsStr=strrep(tlcOptionsStr,tlcOptions{2},'');
        if isempty(strfind(tlcOptionsStr,tlcOptions{1}))
            tlcOptionsStr=[tlcOptionsStr,char(32),tlcOptions{1}];
        end
    else
        tlcOptionsStr=strrep(tlcOptionsStr,tlcOptions{1},'');
        if isempty(strfind(tlcOptionsStr,tlcOptions{2}))
            tlcOptionsStr=[tlcOptionsStr,char(32),tlcOptions{2}];
        end
    end
    set_param(hCS,'TLCOptions',strtrim(tlcOptionsStr));
end


function loc_hardwareBoardForwarding(hCS,boardName)


    tgtHWInfo=codertarget.targethardware.getTargetHardwareFromName(boardName);
    if~isempty(tgtHWInfo)


        for boardNum=1:numel(tgtHWInfo)
            if~isempty(tgtHWInfo(boardNum).BoardForwardingFcn)
                try
                    feval(tgtHWInfo(boardNum).BoardForwardingFcn,hCS);
                catch ME
                    MSLDiagnostic('codertarget:setup:OpenModelFcnError',boardName,ME.message).reportAsWarning;
                end
            end
        end
    end
end


function loc_parameterForwarding(hCS)
    tgtHWInfo=codertarget.targethardware.getTargetHardware(hCS);
    if~isempty(tgtHWInfo)&&~isempty(tgtHWInfo.getForwardingInfoFile())

        codertarget.forwarding.apply(hCS,tgtHWInfo)
    end
end


