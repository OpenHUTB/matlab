function schema(hobj)















    l_tlmgPayloadInBufferDepthDefault=1;
    l_tlmgPayloadOutBufferDepthDefault=1;
    l_tlmgMaxQuantumTimeDefault=1000;

    l_tlmgAlgorithmProcessingTimeDefault=100;
    l_tlmgFirstWriteTimeDefault=10;
    l_tlmgSubsequentWritesInBurstTimeDefault=10;
    l_tlmgFirstReadTimeDefault=10;
    l_tlmgSubsequentReadsInBurstTimeDefault=10;

    l_tlmgGenerateTestbenchOnOff='on';
    l_tlmgSystemCIncludePathDefault='$(SYSTEMC_INC_PATH)';
    l_tlmgSystemCLibPathDefault='$(SYSTEMC_LIB_PATH)';
    l_tlmgSystemCLibNameDefault='$(SYSTEMC_LIB_NAME)';
    l_tlmgTLMIncludePathDefault='$(TLM_INC_PATH)';
    l_tlmgSCMLIncludePathDefault='$(SCML_INC_PATH)';
    l_tlmgSCMLLibPathDefault='$(SCML_LIB_PATH)';
    l_tlmgSCMLLibNameDefault='$(SCML_LIB_NAME)';
    l_tlmgSCMLLoggingLibNameDefault='$(SCML_LOGGING_LIB_NAME)';
    l_tlmgCompilerSelectVSSupported={{'Microsoft Visual C++ 2017','VS150COMNTOOLS'},...
    {'Microsoft Visual C++ 2015','VS140COMNTOOLS'},...
    {'Microsoft Visual C++ 2013','VS120COMNTOOLS'},...
    {'Microsoft Visual C++ 2012','VS110COMNTOOLS'},...
    {'Microsoft Visual C++ 2010','VS100COMNTOOLS'},...
    {'Microsoft Visual C++ 2008','VS90COMNTOOLS'},...
    {'Microsoft Windows SDK 7.1','SDK71'}};

    l_tlmgCompilerSelectDetected={};
    if ispc

        for i=1:(numel(l_tlmgCompilerSelectVSSupported)-1)

            if strcmp(l_tlmgCompilerSelectVSSupported{i}{2},'VS150COMNTOOLS')
                comp=coder.make.internal.getMexCompInfoFromKey('Microsoft-15.0');
                if~isempty(comp)
                    if exist(comp.comp.Location,'dir')
                        l_tlmgCompilerSelectDetected={l_tlmgCompilerSelectDetected{:},l_tlmgCompilerSelectVSSupported{i}{1}};
                    end
                end
            else

                env=getenv(l_tlmgCompilerSelectVSSupported{i}{2});
                if~isempty(env)&&exist(env,'dir')==7
                    l_tlmgCompilerSelectDetected={l_tlmgCompilerSelectDetected{:},l_tlmgCompilerSelectVSSupported{i}{1}};
                end
            end
        end

        rootKey='HKEY_LOCAL_MACHINE';
        subKey='SOFTWARE\Wow6432Node\Microsoft\Microsoft SDKs\Windows\v7.1';
        try
            key=winqueryreg(rootKey,subKey,'InstallationFolder');
            if~isempty(key)&&exist(key,'dir')==7
                l_tlmgCompilerSelectDetected={l_tlmgCompilerSelectDetected{:},l_tlmgCompilerSelectVSSupported{numel(l_tlmgCompilerSelectVSSupported)}{1}};
            end
        catch
        end

        if isempty(l_tlmgCompilerSelectDetected)
            l_tlmgCompilerSelectDetected={'No supported compiler found'};
        end
    else
        l_tlmgCompilerSelectDetected={'GNU gcc/g++'};
    end



    add_prop(hobj,'tlmgComponentSocketMapping','tlmgComponentSocketMappingEnumT','One combined TLM socket for input data, output data, and control');
    add_prop(hobj,'tlmgComponentAddressing','tlmgComponentAddressingEnumT','No memory map');
    add_prop(hobj,'tlmgComponentAddressingInput','tlmgComponentAddressingEnumT','No memory map');
    add_prop(hobj,'tlmgComponentAddressingOutput','tlmgComponentAddressingEnumT','No memory map');
    add_prop(hobj,'tlmgAutoAddressSpecType','tlmgAddressSpecEnumT','Single input and output address offsets');
    add_prop(hobj,'tlmgAutoAddressSpecTypeInput','tlmgAddressSpecEnumT','Single input and output address offsets');
    add_prop(hobj,'tlmgAutoAddressSpecTypeOutput','tlmgAddressSpecEnumT','Single input and output address offsets');
    add_prop(hobj,'tlmgCommandStatusRegOnOff','slbool','off');
    add_prop(hobj,'tlmgTestAndSetRegOnOff','slbool','off');
    add_prop(hobj,'tlmgTunableParamRegOnOff','slbool','off');
    add_prop(hobj,'tlmgCommandStatusRegOnOffInoutput','slbool','off');
    add_prop(hobj,'tlmgTestAndSetRegOnOffInoutput','slbool','off');
    add_prop(hobj,'tlmgTunableParamRegOnOffInoutput','slbool','off');
    add_prop(hobj,'tlmgIPXactPath','string','');
    add_prop(hobj,'tlmgIPXactUnmapped','slbool','off');
    add_prop(hobj,'tlmgIPXactUnmappedSig','slbool','off');
    add_prop(hobj,'tlmgSCMLOnOff','slbool','off');


    add_prop(hobj,'tlmgProcessingType','tlmgProcessingTypeEnumT','SystemC Thread');
    add_prop(hobj,'tlmgIrqPortOnOff','slbool','on');
    add_fixed_prop(hobj,'tlmgPayloadBufferingOnOff','slbool','off');
    add_fixed_prop(hobj,'tlmgPayloadInBufferDepth','slint',l_tlmgPayloadInBufferDepthDefault);
    add_fixed_prop(hobj,'tlmgPayloadOutBufferDepth','slint',l_tlmgPayloadOutBufferDepthDefault);
    add_fixed_prop(hobj,'tlmgTempDecouplOnOff','slbool','off');
    add_fixed_prop(hobj,'tlmgMaxQuantumTime','double',l_tlmgMaxQuantumTimeDefault);


    add_prop(hobj,'tlmgAlgorithmProcessingTime','double',l_tlmgAlgorithmProcessingTimeDefault);
    add_prop(hobj,'tlmgFirstWriteTime','double',l_tlmgFirstWriteTimeDefault);
    add_prop(hobj,'tlmgSubsequentWritesInBurstTime','double',l_tlmgSubsequentWritesInBurstTimeDefault);
    add_prop(hobj,'tlmgFirstReadTime','double',l_tlmgFirstReadTimeDefault);
    add_prop(hobj,'tlmgSubsequentReadsInBurstTime','double',l_tlmgSubsequentReadsInBurstTimeDefault);

    add_prop(hobj,'tlmgFirstWriteTimeInput','double',l_tlmgFirstWriteTimeDefault);
    add_prop(hobj,'tlmgSubsequentWritesInBurstTimeInput','double',l_tlmgSubsequentWritesInBurstTimeDefault);
    add_prop(hobj,'tlmgFirstReadTimeOutput','double',l_tlmgFirstReadTimeDefault);
    add_prop(hobj,'tlmgSubsequentReadsInBurstTimeOutput','double',l_tlmgSubsequentReadsInBurstTimeDefault);
    add_prop(hobj,'tlmgFirstWriteTimeCtrl','double',l_tlmgFirstWriteTimeDefault);
    add_prop(hobj,'tlmgSubsequentWritesInBurstTimeCtrl','double',l_tlmgSubsequentWritesInBurstTimeDefault);
    add_prop(hobj,'tlmgFirstReadTimeCtrl','double',l_tlmgFirstReadTimeDefault);
    add_prop(hobj,'tlmgSubsequentReadsInBurstTimeCtrl','double',l_tlmgSubsequentReadsInBurstTimeDefault);




    add_prop(hobj,'tlmgUserTagForNaming','string','');


    add_prop(hobj,'tlmgGenerateTestbenchOnOff','slbool',l_tlmgGenerateTestbenchOnOff);
    add_prop(hobj,'tlmgVerboseTbMessagesOnOff','slbool','off');
    add_prop(hobj,'tlmgRuntimeTimingMode','tlmgRuntimeTimingModeEnumT','With timing');
    add_prop(hobj,'tlmgInputBufferTriggerMode','tlmgInputBufferTriggerModeEnumT','Automatic');
    add_prop(hobj,'tlmgOutputBufferTriggerMode','tlmgOutputBufferTriggerModeEnumT','Automatic');
    add_prop(hobj,'tlmgKeepInputBufferFullOnOff','slbool','on','off');
    add_prop(hobj,'tlmgKeepOutputBufferFullOnOff','slbool','on','off');


    add_prop(hobj,'tlmgSystemCIncludePath','string',l_tlmgSystemCIncludePathDefault);
    add_prop(hobj,'tlmgSystemCLibPath','string',l_tlmgSystemCLibPathDefault);
    add_prop(hobj,'tlmgSystemCLibName','string',l_tlmgSystemCLibNameDefault);
    add_prop(hobj,'tlmgTLMIncludePath','string',l_tlmgTLMIncludePathDefault);
    add_prop(hobj,'tlmgSCMLIncludePath','string',l_tlmgSCMLIncludePathDefault);
    add_prop(hobj,'tlmgSCMLLibPath','string',l_tlmgSCMLLibPathDefault);
    add_prop(hobj,'tlmgSCMLLibName','string',l_tlmgSCMLLibNameDefault);
    add_prop(hobj,'tlmgSCMLLoggingLibName','string',l_tlmgSCMLLoggingLibNameDefault);
    add_prop(hobj,'tlmgCompilerSelect','string',l_tlmgCompilerSelectDetected{1});
    add_prop(hobj,'tlmgTargetOSSelect','tlmgTargetOSSelectEnumT','Current Host');
    add_prop(hobj,'tlmgCrossTargetOnOff','slbool','off','off');











    add_noncc_prop(hobj,'propsThatCanDirtyModel','MATLAB array',hobj.Properties);
    add_noncc_prop(hobj,'postSetListener','handle','');





    add_fixed_prop(hobj,'tlmgPayloadInBufferDepthDefault','slint',l_tlmgPayloadInBufferDepthDefault);
    add_fixed_prop(hobj,'tlmgPayloadOutBufferDepthDefault','slint',l_tlmgPayloadOutBufferDepthDefault);
    add_fixed_prop(hobj,'tlmgMaxQuantumTimeDefault','double',l_tlmgMaxQuantumTimeDefault);

    add_fixed_prop(hobj,'tlmgAlgorithmProcessingTimeDefault','double',l_tlmgAlgorithmProcessingTimeDefault);
    add_fixed_prop(hobj,'tlmgFirstWriteTimeDefault','double',l_tlmgFirstWriteTimeDefault);
    add_fixed_prop(hobj,'tlmgSubsequentWritesInBurstTimeDefault','double',l_tlmgSubsequentWritesInBurstTimeDefault);
    add_fixed_prop(hobj,'tlmgFirstReadTimeDefault','double',l_tlmgFirstReadTimeDefault);
    add_fixed_prop(hobj,'tlmgSubsequentReadsInBurstTimeDefault','double',l_tlmgSubsequentReadsInBurstTimeDefault);

    add_fixed_prop(hobj,'tlmgGenerateTestbenchOnOffDefault','slbool',l_tlmgGenerateTestbenchOnOff);

    add_fixed_prop(hobj,'tlmgSystemCIncludePathDefault','string',l_tlmgSystemCIncludePathDefault);
    add_fixed_prop(hobj,'tlmgSystemCLibPathDefault','string',l_tlmgSystemCLibPathDefault);
    add_fixed_prop(hobj,'tlmgSystemCLibNameDefault','string',l_tlmgSystemCLibNameDefault);
    add_fixed_prop(hobj,'tlmgTLMIncludePathDefault','string',l_tlmgTLMIncludePathDefault);
    add_fixed_prop(hobj,'tlmgSCMLIncludePathDefault','string',l_tlmgSCMLIncludePathDefault);
    add_fixed_prop(hobj,'tlmgSCMLLibPathDefault','string',l_tlmgSCMLLibPathDefault);
    add_fixed_prop(hobj,'tlmgSCMLLibNameDefault','string',l_tlmgSCMLLibNameDefault);
    add_fixed_prop(hobj,'tlmgSCMLLoggingLibNameDefault','string',l_tlmgSCMLLoggingLibNameDefault);
    add_fixed_prop(hobj,'tlmgCompilerSelectVSSupported','MATLAB array',l_tlmgCompilerSelectVSSupported);
    add_fixed_prop(hobj,'tlmgCompilerSelectDetected','MATLAB array',l_tlmgCompilerSelectDetected);




    add_prop(hobj,'tlmgTbExeDir','string','');



    p=add_prop(hobj,'tlmgDisabledVerifyButton','string','Verify TLM Component','on','on');
    p.AccessFlags.Serialize='off';
    p=add_prop(hobj,'tlmgEnabledVerifyButton','string','Verify TLM Component','on','on');
    p.AccessFlags.Serialize='off';
    p=add_prop(hobj,'tlmgSubsystemPath','string','','on','on');
    p.AccessFlags.Serialize='off';
    p=add_prop(hobj,'tlmgSubsystemName','string','','on','on');
    p.AccessFlags.Serialize='off';



    add_fixed_prop(hobj,'tlmgComponentEnv','tlmgComponentEnvEnumT','OSCI TLM2');
    add_fixed_prop(hobj,'tlmgIrqPortType','tlmgIrqPortTypeEnumT','Create IRQ Port as an sc_signal');
    add_fixed_prop(hobj,'tlmgLooselyTimedMode','tlmgLooselyTimedModeEnumT','Loosely Timed with No Temporal Decoupling');
    add_fixed_prop(hobj,'tlmgBusWidth','slint',32);
    add_fixed_prop(hobj,'tlmgFixedPointStorage','tlmgFixedPointStorageEnumT','Use SystemC int data type for Simulink fixed point data type');
    add_fixed_prop(hobj,'tlmgPayloadByteEnOnOff','slbool','off');





















    add_fixed_prop(hobj,'tlmgTbNumVectors','slint','0');






    add_noncc_prop(hobj,'editWidgetList','MATLAB array','');
    add_noncc_prop(hobj,'dlgCb','MATLAB array','');













    m=schema.method(hobj,'getExtensionUpdate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};



    m=schema.method(hobj,'getExtensionCompatibleProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hobj,'getExtensionDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hobj,'dialogExtensionCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','string'};
    s.OutputTypes={};


    m=schema.method(hobj,'propValueChangeCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    m=schema.method(hobj,'verifyTlmComp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    m=schema.method(hobj,'pushIPXactButton');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};


    m=schema.method(hobj,'isUsingEditWidget');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};


    m=schema.method(hobj,'genTag');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};


    m=schema.method(hobj,'getPropFromTag');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};


    m=schema.method(hobj,'getPropType');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};


end



function p=add_prop(hobj,name,type,default,varargin)
    p=Simulink.TargetCCProperty(hobj,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_PROCESS');

    p.FactoryValue=default;
    if(nargin==5)
        p.Visible=varargin{1};
    end
    if(nargin==6)
        p.AccessFlags.PublicSet=varargin{2};
    end

end


function p=add_fixed_prop(hobj,name,type,default)
    p=Simulink.TargetCCProperty(hobj,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');

    p.FactoryValue=default;
    p.Visible='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Serialize='off';
end


function p=add_noncc_prop(hobj,name,type,default)
    p=Simulink.TargetCCProperty(hobj,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');

    p.FactoryValue=default;
    p.Visible='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Serialize='off';
end


