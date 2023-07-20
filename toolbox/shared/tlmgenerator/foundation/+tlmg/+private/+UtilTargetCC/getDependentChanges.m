function chg=getDependentChanges(hObj,propName,propVal)



    cbName=str2func(['l_',propName,'_cb']);

    try
        chg=cbName(hObj,propVal,struct([]));
    catch ME
        if strcmpi('MATLAB:UndefinedFunction',ME.identifier)


            chg=struct([]);
        else

            rethrow(ME);
        end
    end
end



function chg=l_tlmgComponentSocketMapping_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end
    switch(propVal)

    case 'One combined TLM socket for input data, output data, and control'
        chg.vis.tlmgCombinedGroup=true;
        chg.en.tlmgCombinedGroup=true;
        chg.vis.tlmgMultiPanel=false;
        chg.en.tlmgMultiPanel=false;
        chg.vis.tlmgIPXactGroup=false;
        chg.en.tlmgIPXactGroup=false;













        chg.val.tlmgComponentAddressing=hObj.tlmgComponentAddressing;
        chg=l_tlmgComponentAddressing_cb(hObj,chg.val.tlmgComponentAddressing,chg);

        chg.val.tlmgSCMLOnOff='off';
        chg=l_tlmgSCMLOnOff_cb(hObj,chg.val.tlmgSCMLOnOff,chg);


        chg.vis.tlmgCombinedTimingPanel=true;
        chg.en.tlmgCombinedTimingPanel=true;
        chg.vis.tlmgMultiTimingPanel=false;
        chg.en.tlmgMultiTimingPanel=false;
        chg.vis.tlmgCompProcGroup=true;
        chg.en.tlmgCompProcGroup=true;




    case 'Three separate TLM sockets for input data, output data, and control'
        chg.vis.tlmgCombinedGroup=false;
        chg.en.tlmgCombinedGroup=false;
        chg.vis.tlmgMultiPanel=true;
        chg.en.tlmgMultiPanel=true;
        chg.vis.tlmgIPXactGroup=false;
        chg.en.tlmgIPXactGroup=false;

        chg.val.tlmgComponentAddressing='Auto-generated memory map';


        chg.val.tlmgComponentAddressingInput=hObj.tlmgComponentAddressingInput;
        chg=l_tlmgComponentAddressingInput_cb(hObj,chg.val.tlmgComponentAddressingInput,chg);

        chg.val.tlmgComponentAddressingOutput=hObj.tlmgComponentAddressingOutput;
        chg=l_tlmgComponentAddressingOutput_cb(hObj,chg.val.tlmgComponentAddressingOutput,chg);

        chg.val.tlmgCommandStatusRegOnOffInoutput=hObj.tlmgCommandStatusRegOnOffInoutput;
        chg=l_tlmgCommandStatusRegOnOffInoutput_cb(hObj,chg.val.tlmgCommandStatusRegOnOffInoutput,chg);

        chg.val.tlmgTestAndSetRegOnOffInoutput=hObj.tlmgTestAndSetRegOnOffInoutput;
        chg.val.tlmgTunableParamRegOnOffInoutput=hObj.tlmgTunableParamRegOnOffInoutput;

        chg.val.tlmgSCMLOnOff='off';
        chg=l_tlmgSCMLOnOff_cb(hObj,chg.val.tlmgSCMLOnOff,chg);

        chg.vis.tlmgCombinedTimingPanel=false;
        chg.en.tlmgCombinedTimingPanel=false;
        chg.vis.tlmgMultiTimingPanel=true;
        chg.en.tlmgMultiTimingPanel=true;
        chg.vis.tlmgCompProcGroup=true;
        chg.en.tlmgCompProcGroup=true;

    case 'Defined by imported IP-XACT file'
        chg.vis.tlmgCombinedGroup=false;
        chg.en.tlmgCombinedGroup=false;
        chg.vis.tlmgMultiPanel=false;
        chg.en.tlmgMultiPanel=false;
        chg.vis.tlmgIPXactGroup=true;
        chg.en.tlmgIPXactGroup=true;

        chg.val.tlmgCommandStatusRegOnOffInoutput='off';
        chg=l_tlmgCommandStatusRegOnOffInoutput_cb(hObj,chg.val.tlmgCommandStatusRegOnOffInoutput,chg);
        chg.val.tlmgTestAndSetRegOnOffInoutput='off';
        chg.val.tlmgTunableParamRegOnOffInoutput='off';

        chg.val.tlmgSCMLOnOff=hObj.tlmgSCMLOnOff;
        chg=l_tlmgSCMLOnOff_cb(hObj,chg.val.tlmgSCMLOnOff,chg);

        chg.vis.tlmgCombinedTimingPanel=true;
        chg.en.tlmgCombinedTimingPanel=true;
        chg.vis.tlmgMultiTimingPanel=false;
        chg.en.tlmgMultiTimingPanel=false;
        chg.vis.tlmgCompProcGroup=false;
        chg.en.tlmgCompProcGroup=false;
    end

end

function chg=l_tlmgSCMLOnOff_cb(hObj,propVal,prev_chg)
    if(~isempty(prev_chg))
        chg=prev_chg;
    end
    switch(propVal)
    case 'off'
        chg.vis.tlmgSCMLCcPanel=false;
        chg.en.tlmgSCMLCcPanel=false;
    case 'on'
        chg.vis.tlmgSCMLCcPanel=true;
        chg.en.tlmgSCMLCcPanel=true;
    end
end

function chg=l_tlmgComponentAddressing_cb(hObj,propVal,prev_chg)
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    chg.val.tlmgComponentAddressingInput=propVal;
    chg.val.tlmgComponentAddressingOutput=propVal;

    switch(propVal)

    case 'No memory map'
        chg.vis.tlmgAutoAddressSpecType=false;
        chg.en.tlmgAutoAddressSpecType=false;
        chg.vis.tlmgCombinedCtrlPanel=false;
        chg.en.tlmgCombinedCtrlPanel=false;

        chg.val.tlmgCommandStatusRegOnOff='off';
        chg=l_tlmgCommandStatusRegOnOff_cb(hObj,chg.val.tlmgCommandStatusRegOnOff,chg);

        chg.val.tlmgTestAndSetRegOnOff='off';
        chg.val.tlmgTunableParamRegOnOff='off';


    case 'Auto-generated memory map'
        chg.vis.tlmgAutoAddressSpecType=true;
        chg.en.tlmgAutoAddressSpecType=true;
        chg.vis.tlmgCombinedCtrlPanel=true;
        chg.en.tlmgCombinedCtrlPanel=true;

        chg.val.tlmgCommandStatusRegOnOff=hObj.tlmgCommandStatusRegOnOff;
        chg=l_tlmgCommandStatusRegOnOff_cb(hObj,chg.val.tlmgCommandStatusRegOnOff,chg);

        chg.val.tlmgTestAndSetRegOnOff=hObj.tlmgTestAndSetRegOnOff;
        chg.val.tlmgTunableParamRegOnOff=hObj.tlmgTunableParamRegOnOff;
    end

end

function chg=l_tlmgCommandStatusRegOnOff_cb(~,propVal,prev_chg)
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    chg.val.tlmgCommandStatusRegOnOffInoutput=propVal;
    switch(propVal)
    case 'off'






        chg.en.tlmgInputBufferTriggerMode=false;
        chg.val.tlmgInputBufferTriggerMode='Automatic';
        chg.en.tlmgOutputBufferTriggerMode=false;
        chg.val.tlmgOutputBufferTriggerMode='Automatic';
    case 'on'
        chg.en.tlmgInputBufferTriggerMode=true;
        chg.en.tlmgOutputBufferTriggerMode=true;
    end
end

function chg=l_tlmgCommandStatusRegOnOffInoutput_cb(~,propVal,prev_chg)
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    chg.val.tlmgCommandStatusRegOnOff=propVal;
    switch(propVal)
    case 'off'






        chg.en.tlmgInputBufferTriggerMode=false;
        chg.val.tlmgInputBufferTriggerMode='Automatic';
        chg.en.tlmgOutputBufferTriggerMode=false;
        chg.val.tlmgOutputBufferTriggerMode='Automatic';
    case 'on'
        chg.en.tlmgInputBufferTriggerMode=true;
        chg.en.tlmgOutputBufferTriggerMode=true;
    end
end


function chg=l_tlmgComponentAddressingInput_cb(~,propVal,prev_chg)
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    switch(propVal)

    case 'No memory map'
        chg.vis.tlmgAutoAddressSpecTypeInput=false;
        chg.en.tlmgAutoAddressSpecTypeInput=false;


    case 'Auto-generated memory map'
        chg.vis.tlmgAutoAddressSpecTypeInput=true;
        chg.en.tlmgAutoAddressSpecTypeInput=true;
    end
end

function chg=l_tlmgComponentAddressingOutput_cb(~,propVal,prev_chg)
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    switch(propVal)

    case 'No memory map'
        chg.vis.tlmgAutoAddressSpecTypeOutput=false;
        chg.en.tlmgAutoAddressSpecTypeOutput=false;


    case 'Auto-generated memory map'
        chg.vis.tlmgAutoAddressSpecTypeOutput=true;
        chg.en.tlmgAutoAddressSpecTypeOutput=true;
    end
end

function chg=l_tlmgAlgorithmProcessingTime_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgAlgorithmProcessingTime=hObj.tlmgAlgorithmProcessingTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgFirstWriteTime_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgFirstWriteTime=hObj.tlmgFirstWriteTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgSubsequentWritesInBurstTime_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgSubsequentWritesInBurstTime=hObj.tlmgSubsequentWritesInBurstTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgFirstReadTime_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgFirstReadTime=hObj.tlmgFirstReadTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgSubsequentReadsInBurstTime_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgSubsequentReadsInBurstTime=hObj.tlmgSubsequentReadsInBurstTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgFirstWriteTimeInput_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgFirstWriteTimeInput=hObj.tlmgFirstWriteTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgSubsequentWritesInBurstTimeInput_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgSubsequentWritesInBurstTimeInput=hObj.tlmgSubsequentWritesInBurstTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgFirstReadTimeOutput_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgFirstReadTimeOutput=hObj.tlmgFirstReadTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgSubsequentReadsInBurstTimeOutput_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgSubsequentReadsInBurstTimeOutput=hObj.tlmgSubsequentReadsInBurstTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgFirstWriteTimeCtrl_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgFirstWriteTimeCtrl=hObj.tlmgFirstWriteTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgSubsequentWritesInBurstTimeCtrl_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgSubsequentWritesInBurstTimeCtrl=hObj.tlmgSubsequentWritesInBurstTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgFirstReadTimeCtrl_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgFirstReadTimeCtrl=hObj.tlmgFirstReadTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgSubsequentReadsInBurstTimeCtrl_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(propVal<0)
        chg.val.tlmgSubsequentReadsInBurstTimeCtrl=hObj.tlmgSubsequentReadsInBurstTimeDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgGenerateTestbenchOnOff_cb(~,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    switch(propVal)
    case 'off'
        chg.vis.tlmgVerboseTbMessagesOnOff=false;
        chg.vis.tlmgRuntimeTimingMode=false;
        chg.vis.tlmgInputBufferTriggerMode=false;
        chg.vis.tlmgOutputBufferTriggerMode=false;
        chg.vis.tlmgKeepInputBufferFullOnOff=false;
        chg.vis.tlmgKeepOutputBufferFullOnOff=false;

    case 'on'
        chg.vis.tlmgVerboseTbMessagesOnOff=true;
        chg.vis.tlmgRuntimeTimingMode=true;
        chg.vis.tlmgInputBufferTriggerMode=true;
        chg.vis.tlmgOutputBufferTriggerMode=true;
        chg.vis.tlmgKeepInputBufferFullOnOff=true;
        chg.vis.tlmgKeepOutputBufferFullOnOff=true;

    end
end

function chg=l_tlmgTbExeDir_cb(~,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    switch(propVal)
    case ''
        chg.vis.tlmgEnabledVerifyButton=false;
        chg.vis.tlmgDisabledVerifyButton=true;
    otherwise
        chg.vis.tlmgEnabledVerifyButton=true;
        chg.vis.tlmgDisabledVerifyButton=false;
    end
end

function chg=l_tlmgSystemCIncludePath_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    l_checkForCompDir('tlmgSystemCIncludePath',propVal);

    if(isempty(propVal))
        chg.val.tlmgSystemCIncludePath=hObj.tlmgSystemCIncludePathDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgSystemCLibPath_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    l_checkForCompDir('tlmgSystemCLibPath',propVal);

    if(isempty(propVal))
        chg.val.tlmgSystemCLibPath=hObj.tlmgSystemCLibPathDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgSystemCLibName_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    if(isempty(propVal))
        chg.val.tlmgSystemCLibName=hObj.tlmgSystemCLibNameDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgTLMIncludePath_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    l_checkForCompDir('tlmgTLMIncludePath',propVal);

    if(isempty(propVal))
        chg.val.tlmgTLMIncludePath=hObj.tlmgTLMIncludePathDefault;
        return;
    end

    if(isempty(prev_chg))
        chg=struct([]);
    end
end

function chg=l_tlmgCrossTargetOnOff_cb(~,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    switch(propVal)
    case 'off'
        chg.vis.tlmgTbGroup=true;
        chg.vis.tlmgTbBtnGroup=true;
        chg.vis.tlmgCompilerSelect=true;
    case 'on'
        chg.vis.tlmgTbGroup=false;
        chg.vis.tlmgTbBtnGroup=false;
        chg.vis.tlmgCompilerSelect=false;
    end
end

function chg=l_tlmgTargetOSSelect_cb(hObj,propVal,prev_chg)%#ok<DEFNU>
    if(~isempty(prev_chg))
        chg=prev_chg;
    end

    cs=hObj.getConfigSet();
    l_host=computer;

    switch(propVal)
    case 'Linux 64'
        setValAndEnForce(cs,'ProdHWDeviceType','Intel->x86-64 (Linux 64)',false);
        if(strcmp(l_host,'GLNXA64'))
            chg.val.tlmgCrossTargetOnOff='off';
        else
            chg.val.tlmgCrossTargetOnOff='on';
        end

    case 'Windows 64'
        setValAndEnForce(cs,'ProdHWDeviceType','Intel->x86-64 (Windows64)',false);
        if(strcmp(l_host,'PCWIN64'))
            chg.val.tlmgCrossTargetOnOff='off';
        else
            chg.val.tlmgCrossTargetOnOff='on';
        end

    otherwise
        if(strcmp(l_host,'GLNXA64'))
            setValAndEnForce(cs,'ProdHWDeviceType','Intel->x86-64 (Linux 64)',false);

        elseif(strcmp(l_host,'PCWIN64'))
            setValAndEnForce(cs,'ProdHWDeviceType','Intel->x86-64 (Windows64)',false);
        end
        chg.val.tlmgCrossTargetOnOff='off';
    end
    hh=targetrepository.getHardwareImplementationHelper();
    device=hh.getDevice(get_param(cs,'ProdHWDeviceType'));
    hwinfo=RTW.getParameterMapForTargetRepositoryObject(device);

    setValAndEnForce(cs,'ProdBitPerChar',hwinfo.BitPerChar,true);
    setValAndEnForce(cs,'ProdBitPerShort',hwinfo.BitPerShort,true);
    setValAndEnForce(cs,'ProdBitPerInt',hwinfo.BitPerInt,true);
    setValAndEnForce(cs,'ProdBitPerLong',hwinfo.BitPerLong,true);
    setValAndEnForce(cs,'ProdBitPerLongLong',hwinfo.BitPerLongLong,true);
    setValAndEnForce(cs,'ProdWordSize',hwinfo.WordSize,true);

    setValAndEnForce(cs,'ProdEndianess',hwinfo.Endianess,true);
    setValAndEnForce(cs,'ProdIntDivRoundTo',hwinfo.IntDivRoundTo,true);
    setValAndEnForce(cs,'ProdLargestAtomicInteger',hwinfo.LargestAtomicInteger,true);
    setValAndEnForce(cs,'ProdLargestAtomicFloat',hwinfo.LargestAtomicFloat,true);
    setValAndEnForce(cs,'ProdShiftRightIntArith',hwinfo.ShiftRightIntArith,true);
    setValAndEnForce(cs,'ProdLongLongMode','on',false);
    setValAndEnForce(cs,'ProdBitPerFloat',hwinfo.BitPerFloat,true);
    setValAndEnForce(cs,'ProdBitPerDouble',hwinfo.BitPerDouble,true);
    setValAndEnForce(cs,'ProdBitPerPointer',hwinfo.BitPerPointer,true);
    setValAndEnForce(cs,'ProdBitPerSizeT',hwinfo.BitPerSizeT,true);
    setValAndEnForce(cs,'ProdBitPerPtrDiffT',hwinfo.BitPerPtrDiffT,true);

    if any(strcmp('No supported compiler found',hObj.tlmgCompilerSelectDetected))
        chg.vis.tlmgTbBtnGroup=false;
    end

    chg=l_tlmgCrossTargetOnOff_cb(hObj,chg.val.tlmgCrossTargetOnOff,chg);
end





function setValAndEn(cs,prop,val,en)
    if(cs.getPropEnabled(prop))
        cs.setProp(prop,val);
        cs.setPropEnabled(prop,en);
    else
        assert(en==false);
    end
end

function setValAndEnForce(cs,prop,val,en)
    cs.setPropEnabled(prop,true);
    setValAndEn(cs,prop,val,en);
end













function l_checkForCompDir(propName,propVal)%#ok<INUSD>
    return;















end

































