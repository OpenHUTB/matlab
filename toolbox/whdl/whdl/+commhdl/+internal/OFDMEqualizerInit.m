function OFDMEqualizerInit()




%#codegen

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end

    Simulink.suppressDiagnostic(gcb,'SimulinkFixedPoint:util:Overflowoccurred');
    Simulink.suppressDiagnostic(gcb,'SimulinkFixedPoint:util:fxpParameterPrecisionLoss');
    Simulink.suppressDiagnostic(gcb,'SimulinkFixedPoint:util:fxpParameterOverflow');


    EqMdUsed=get_param(gcb,'EqualizationMethod');


    blkNoiseVariance=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','noiseVar');
    if strcmp(EqMdUsed,'MMSE')
        if strcmp(get_param([blkNoiseVariance{1}],'BlockType'),'Constant')
            replace_block([blkNoiseVariance{1}],'Constant','Inport','noprompt');
            set_param([blkNoiseVariance{1}],'BackgroundColor','lightblue');
        end
    else
        if strcmp(get_param([blkNoiseVariance{1}],'BlockType'),'Inport')
            replace_block([blkNoiseVariance{1}],'Inport','Constant','noprompt');
            set_param([blkNoiseVariance{1}],'Value','0','SampleTime','-1','OutDataTypeStr','fixdt(0,1,0)');
        end
    end

    resetPort=get_param(gcb,'resetPort');


    blkReset=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','reset');
    if strcmp(resetPort,'on')
        set_param([gcb,'/Validation of input arguments/OFDMChEqualizerCheckType'],'ResetInputPort','on');
        if strcmp(get_param([blkReset{1}],'BlockType'),'Constant')
            replace_block([blkReset{1}],'Constant','Inport','noprompt');
            set_param([blkReset{1}],'BackgroundColor','lightblue');
        end
    else
        set_param([gcb,'/Validation of input arguments/OFDMChEqualizerCheckType'],'ResetInputPort','off');
        if strcmp(get_param([blkReset{1}],'BlockType'),'Inport')
            replace_block([blkReset{1}],'Inport','Constant','noprompt');
            set_param([blkReset{1}],'Value','0','SampleTime','-1','OutDataTypeStr','boolean');
        end
    end


    maxhEstLenPerSym=get_param(gcb,'MaxLenChEstiPerSym');
    [maxhEstLenPerSymVal,status]=str2num(maxhEstLenPerSym);
    if status==true
        validateattributes(maxhEstLenPerSymVal,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMEqualizer','Maximum length of channel estimate per symbol');
        if isa(maxhEstLenPerSymVal,'embedded.fi')
            [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(maxhEstLenPerSymVal);
            if FL>0||signedBit~=0||WL<2
                coder.internal.error('whdl:OFDMEqualizer:InvDataMaxhEstLen');
            end
        end
        maxhEstLenPerSymVal=double(maxhEstLenPerSymVal);
        validateattributes(maxhEstLenPerSymVal,{'numeric'},{'integer','scalar','>=',2,'<=',65536},'OFDMEqualizer','Maximum length of channel estimate per symbol');
    end
    set_param([gcb,'/Validation of input arguments/maxChanLenEstPerSym'],'Value',maxhEstLenPerSym,'SampleTime','-1');


    if strcmp(EqMdUsed,'MMSE')
        set_param([blkNoiseVariance{1}],'Port',num2str(3))
    end
    if strcmp(resetPort,'on')
        if strcmp(EqMdUsed,'MMSE')
            set_param([blkReset{1}],'Port',num2str(7))
        else
            set_param([blkReset{1}],'Port',num2str(6))
        end
    end
end
