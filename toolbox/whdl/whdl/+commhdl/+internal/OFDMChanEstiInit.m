function OFDMChanEstiInit()




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

    enableTimeAvg=get_param(gcb,'timeAvgCheckBox');
    enableInterp=get_param(gcb,'enableInterpCheckBox');


    blkNumValidSubCar=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','numValidSubCarPerSym');
    if strcmp(enableTimeAvg,'on')||(~strcmp(enableTimeAvg,'on')&&strcmp(enableInterp,'on'))
        if strcmp(get_param([blkNumValidSubCar{1}],'BlockType'),'Constant')
            replace_block([blkNumValidSubCar{1}],'Constant','Inport','noprompt');
            set_param([blkNumValidSubCar{1}],'BackgroundColor','lightblue');
        end
    else
        if strcmp(get_param([blkNumValidSubCar{1}],'BlockType'),'Inport')
            replace_block([blkNumValidSubCar{1}],'Inport','Constant','noprompt');
            set_param([blkNumValidSubCar{1}],'Value','1','SampleTime','-1','OutDataTypeStr','fixdt(0,16,0)');
        end
    end

    enableReset=get_param(gcb,'resetPort');


    blkReset=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','reset');
    if strcmp(enableReset,'on')
        set_param([gcb,'/Validation of input arguments/OFDMChEstiCheckType'],'ResetInputPort','on');
        if strcmp(get_param([blkReset{1}],'BlockType'),'Constant')
            replace_block([blkReset{1}],'Constant','Inport','noprompt');
            set_param([blkReset{1}],'BackgroundColor','lightblue');
        end
    else
        set_param([gcb,'/Validation of input arguments/OFDMChEstiCheckType'],'ResetInputPort','off');
        if strcmp(get_param([blkReset{1}],'BlockType'),'Inport')
            replace_block([blkReset{1}],'Inport','Constant','noprompt');
            set_param([blkReset{1}],'Value','0','SampleTime','-1','OutDataTypeStr','boolean');
        end
    end



    blkNumSymAvg=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','numSymAvg');
    if strcmp(enableTimeAvg,'on')
        numSymAvg=get_param(gcb,'numOFDMSymToBeAvg');
        [numSymAvgVal,status]=str2num(numSymAvg);
        if status==true
            validateattributes(numSymAvgVal,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMChannelEstimator','Number of symbols to be averaged');
            if isa(numSymAvgVal,'embedded.fi')
                [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(numSymAvgVal);
                if FL>0||signedBit~=0||WL<2
                    coder.internal.error('whdl:OFDMChEstimator:InvDataNumSymToBeAvgd');
                end
            end
            numSymAvgVal=double(numSymAvgVal);
            validateattributes(numSymAvgVal,{'numeric'},{'integer','scalar','>=',2,'<=',14},'OFDMChannelEstimator','Number of symbols to be averaged');
        end
        replace_block([blkNumSymAvg{1}],'Constant','Constant','noprompt');
        set_param([gcb,'/Validation of input arguments/numSymAvg'],'Value',numSymAvg,'SampleTime','-1');
    else
        set_param(gcb,'numOFDMSymToBeAvg','2');
        replace_block([blkNumSymAvg{1}],'Constant','Constant','noprompt');
        set_param([gcb,'/Validation of input arguments/numSymAvg'],'OutDataTypeStr','fixdt(0,4,0)','Value','2','SampleTime','-1');
    end



    blkMaxNumScPerSym=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','maxNumScPerSym');
    if strcmp(enableTimeAvg,'on')||strcmp(enableInterp,'on')
        maxnScPerSym=get_param(gcb,'maxNumSubCarPerSym');
        [maxnScPerSymVal,status]=str2num(maxnScPerSym);
        if status==true
            validateattributes(maxnScPerSymVal,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMChannelEstimator','Maximum number of subcarriers per symbol');
            if isa(maxnScPerSymVal,'embedded.fi')
                [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(maxnScPerSymVal);
                if FL>0||signedBit~=0||WL<2
                    coder.internal.error('whdl:OFDMChEstimator:InvDataMaxNumScPerSym');
                end
            end
            maxnScPerSymVal=double(maxnScPerSymVal);
            validateattributes(maxnScPerSymVal,{'numeric'},{'integer','scalar','>=',2,'<=',65536},'OFDMChannelEstimator','Maximum number of subcarriers per symbol');
        end
        replace_block([blkMaxNumScPerSym{1}],'Constant','Constant','noprompt');
        set_param([gcb,'/Validation of input arguments/maxNumScPerSym'],'Value',maxnScPerSym,'SampleTime','-1');
    else
        set_param(gcb,'maxNumSubCarPerSym','52');
        replace_block([blkMaxNumScPerSym{1}],'Constant','Constant','noprompt');
        set_param([gcb,'/Validation of input arguments/maxNumScPerSym'],'OutDataTypeStr','fixdt(0,17,0)','Value','52','SampleTime','-1');
    end



    blkInterpFac=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','interpFactor');
    if strcmp(enableInterp,'on')
        interpolFac=get_param(gcb,'interpFac');
        [interpolFacVal,status]=str2num(interpolFac);
        if status==true
            validateattributes(interpolFacVal,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMChannelEstimator','Interpolation factor');
            if isa(interpolFacVal,'embedded.fi')
                [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(interpolFacVal);
                if FL>0||signedBit~=0||WL<2
                    coder.internal.error('whdl:OFDMChEstimator:InvalidDataTypeInterpFac');
                end
            end
            interpolFacVal=double(interpolFacVal);
            validateattributes(interpolFacVal,{'numeric'},{'integer','scalar','>=',2,'<=',12},'OFDMChannelEstimator','Interpolation factor');
            if(maxnScPerSymVal<=interpolFacVal)
                coder.internal.error('whdl:OFDMChEstimator:maxNumSPSLessEqinterpFacErr');
            end
        end
        replace_block([blkInterpFac{1}],'Constant','Constant','noprompt');
        set_param([gcb,'/Validation of input arguments/interpFactor'],'Value',interpolFac,'SampleTime','-1');
    else
        set_param(gcb,'interpFac','3');
        replace_block([blkInterpFac{1}],'Constant','Constant','noprompt');
        set_param([gcb,'/Validation of input arguments/interpFactor'],'OutDataTypeStr','fixdt(0,4,0)','Value','3','SampleTime','-1');
    end

    n=5;
    if strcmp(enableTimeAvg,'on')||(~strcmp(enableTimeAvg,'on')&&strcmp(enableInterp,'on'))
        set_param([blkNumValidSubCar{1}],'Port',num2str(n))
        n=n+1;
    end
    if strcmp(enableReset,'on')
        set_param([blkReset{1}],'Port',num2str(n))
    end
end
