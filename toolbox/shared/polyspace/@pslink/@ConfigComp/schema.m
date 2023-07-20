

function schema


    hPkg=findpackage('pslink');
    hSuperCls=findclass(findpackage('Simulink'),'CustomCC');


    hThisCls=schema.class(hPkg,'ConfigComp',hSuperCls);


    if isempty(findtype('PSEnumModelRefVerifDepth'))
        schema.EnumType('PSEnumModelRefVerifDepth',{'Current model only','1','2','3','All'});
    end

    if isempty(findtype('PSEnumInputRangeMode'))
        schema.EnumType('PSEnumInputRangeMode',{'DesignMinMax','FullRange'});
    end

    if isempty(findtype('PSEnumParamRangeMode'))
        schema.EnumType('PSEnumParamRangeMode',{'DesignMinMax','None'});
    end

    if isempty(findtype('PSEnumOutputRangeMode'))
        schema.EnumType('PSEnumOutputRangeMode',{'DesignMinMax','None'});
    end

    if isempty(findtype('PSEnumVerificationSettings'))
        schema.EnumType('PSEnumVerificationSettings',{...
'PrjConfig'...
        ,'PrjConfigAndMisraAGC'...
        ,'PrjConfigAndMisra'...
        ,'MisraAGC'...
        ,'Misra'...
        ,'PrjConfigAndMisraC2012'...
        ,'MisraC2012'...
        });
    end

    if isempty(findtype('PSEnumSfcnVerificationSettings'))
        schema.EnumType('PSEnumSfcnVerificationSettings',{...
'PrjConfig'...
        ,'PrjConfigAndMisra'...
        ,'PrjConfigAndMisraC2012'...
        ,'Misra'...
        ,'MisraC2012'...
        });
    end

    if isempty(findtype('PSEnumCxxVerificationSettings'))
        schema.EnumType('PSEnumCxxVerificationSettings',{...
'PrjConfig'...
        ,'PrjConfigAndMisraCxx'...
        ,'PrjConfigAndJSF'...
        ,'MisraCxx'...
        ,'JSF'...
        });
    end

    if isempty(findtype('PSEnumVerificationMode'))
        schema.EnumType('PSEnumVerificationMode',{...
'BugFinder'...
        ,'CodeProver'...
        });
    end

    if isempty(findtype('PSEnumCheckConfigBeforeAnalysis'))
        schema.EnumType('PSEnumCheckConfigBeforeAnalysis',{...
'Off'...
        ,'OnWarn'...
        ,'OnHalt'...
        });
    end



    hProp=schema.prop(hThisCls,'PSSystemToAnalyze','mxArray');
    hProp.Visible='off';
    hProp.FactoryValue=[];
    hProp.AccessFlags.Serialize='off';

    hProp=schema.prop(hThisCls,'PSVerificationMode','PSEnumVerificationMode');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSVerificationSettings','PSEnumVerificationSettings');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSCxxVerificationSettings','PSEnumCxxVerificationSettings');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSOpenProjectManager','MATLAB array');
    hProp.Visible='on';
    hProp.FactoryValue='off';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSResultDir','string');
    hProp.Visible='on';
    hProp.FactoryValue='';

    hProp=schema.prop(hThisCls,'PSAddSuffixToResultDir','MATLAB array');
    hProp.Visible='on';
    hProp.FactoryValue='off';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSEnableAdditionalFileList','MATLAB array');
    hProp.Visible='on';
    hProp.FactoryValue='off';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSAdditionalFileList','MATLAB array');
    hProp.Visible='on';
    hProp.FactoryValue={};
    hProp.SetFunction=@localSetCellStr;

    hProp=schema.prop(hThisCls,'PSSendToPolyspaceServer','MATLAB array');
    hProp.Visible='off';
    hProp.FactoryValue='off';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSModelRefVerifDepth','PSEnumModelRefVerifDepth');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSModelRefByModelRefVerif','MATLAB array');
    hProp.Visible='on';
    hProp.FactoryValue='on';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSInputRangeMode','PSEnumInputRangeMode');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSParamRangeMode','PSEnumParamRangeMode');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSOutputRangeMode','PSEnumOutputRangeMode');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSAutoStubLUT','MATLAB array');
    hProp.Visible='on';
    hProp.FactoryValue='off';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSCheckConfigBeforeAnalysis','PSEnumCheckConfigBeforeAnalysis');
    hProp.Visible='on';
    hProp.FactoryValue='OnWarn';

    hProp=schema.prop(hThisCls,'PSEnablePrjConfigFile','MATLAB array');
    hProp.Visible='on';
    hProp.FactoryValue='off';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSPrjConfigFile','string');
    hProp.Visible='on';
    hProp.FactoryValue='';

    hProp=schema.prop(hThisCls,'PSAddToSimulinkProject','MATLAB array');
    hProp.Visible='on';
    hProp.FactoryValue='off';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSGenerateBugFinderDesignRanges','MATLAB array');
    hProp.Visible='off';
    hProp.FactoryValue='on';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;

    hProp=schema.prop(hThisCls,'PSCompListener','handle.listener vector');
    hProp.Visible='off';
    hProp.FactoryValue=[];
    hProp.AccessFlags.PublicSet='off';
    hProp.AccessFlags.PublicGet='off';
    hProp.AccessFlags.Serialize='off';

    hProp=schema.prop(hThisCls,'PSVerifAllSFcnInstances','MATLAB array');
    hProp.Visible='off';
    hProp.FactoryValue='off';
    hProp.SetFunction=@localSetBoolOrOnOff;
    hProp.GetFunction=@localGetBoolOrOnOff;


    hMethod=schema.method(hThisCls,'getName');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle'};
    hSig.OutputTypes={'string'};

    hMethod=schema.method(hThisCls,'update');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle','string'};
    hSig.OutputTypes={};

    hMethod=schema.method(hThisCls,'okToAttach');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle','handle'};
    hSig.OutputTypes={'bool'};

    hMethod=schema.method(hThisCls,'okToDetach');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle','string'};
    hSig.OutputTypes={'bool'};

    hMethod=schema.method(hThisCls,'isVisible');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle'};
    hSig.OutputTypes={'bool'};

    hMethod=schema.method(hThisCls,'skipModelReferenceComparison');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle'};
    hSig.OutputTypes={'bool'};

    hMethod=schema.method(hThisCls,'dialogCB');
    hSig=hMethod.Signature;
    hSig.varargin='on';
    hSig.InputTypes={'handle','handle','string','mxArray'};
    hSig.OutputTypes={};

    hMethod=schema.method(hThisCls,'getDisplayLabel');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle'};
    hSig.OutputTypes={'ustring'};

    schema.method(hThisCls,'pConvertToBool','static');



    function val=localSetCellStr(~,val)

        if~iscellstr(val)
            error('pslink:addtlFilesCellStr',DAStudio.message('polyspace:gui:pslink:addtlFilesCellStr'));
        end

        function val=localSetBoolOrOnOff(~,val)

            assert(islogical(val)||...
            (isnumeric(val)&&numel(val)==1&&(val==0||val==1))||...
            (ischar(val)&&ismember(val,{'on','off'})));

            function out=localGetBoolOrOnOff(~,val)

                if islogical(val)
                    if val==true
                        out='on';
                    else
                        out='off';
                    end
                elseif isnumeric(val)
                    if val==1
                        out='on';
                    else
                        out='off';
                    end
                else
                    out=val;
                end

