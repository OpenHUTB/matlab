function rtwconfiguredemo(varargin)


































    if nargin<2
        DAStudio.error('rtwdemos:general:NeedTwoOrMoreArgs')
    end

    ismatch=strcmp(varargin{2},{'fixed','floating','noop'});

    if nargin==4&&~isempty(ismatch)

        model=varargin{1};
        fpMode=varargin{2};
        forGRT=varargin{3};
        overrides=varargin{4};
    else

        model=varargin{1};
        target=varargin{2};

        switch target
        case 'GRT'
            forGRT=true;
        case 'ERT'





            if license('test','RTW_Embedded_Coder')
                forGRT=false;
            else
                uiwait(msgbox(DAStudio.message('rtwdemos:rtwconfiguredemo:switchtogrt')));
                setActiveConfigSet(model,'ConfigurationGRT');
                forGRT=true;
            end
        otherwise
            DAStudio.error('rtwdemos:rtwconfiguredemo:invalidtarget',target);
        end



        fpMode='noop';
        params={};

        if nargin>2
            paramIdx=1;
            for argIdx=1:nargin-2
                arg=varargin{argIdx+2};
                if argIdx==1&&(isequal(arg,'fixed')||isequal(arg,'float'))
                    switch arg
                    case 'fixed'
                        fpMode='fixed';
                    case 'float'
                        fpMode='floating';
                    end
                else
                    params{paramIdx}=arg;%#ok
                    paramIdx=paramIdx+1;
                end
            end
        end


        nParams=length(params);
        if nParams>0
            overrides='{';
            comma='';
            for paramIdx=1:nParams
                if paramIdx==2
                    comma=',';
                end
                overrides=strcat(overrides,comma,'''',params{paramIdx},'''');
            end
            overrides=strcat(overrides,'}');
        else
            overrides={};
        end
    end


    rtwconfiguredemo_core(model,fpMode,forGRT,overrides);

end

function rtwconfiguredemo_core(model,fpMode,forGRT,overrides)











    if isempty(overrides)
        overrides={};
    else
        overrides=eval(overrides);
    end
    if~iscell(overrides)
        DAStudio.error('rtwdemos:rtwconfiguredemo:overrides');
    end



    isDirty=strcmp(get_param(model,'Dirty'),'on');



    cs=getActiveConfigSet(model);

    isERT=strcmp(get_param(cs,'IsERTTarget'),'on');
    if isERT
        origRateTransitionBlockCode=get_param(model,'RateTransitionBlockCode');
        origFilePackaging=get_param(model,'ERTFilePackagingFormat');
    else
        origRateTransitionBlockCode='Inline';
        origFilePackaging='CompactWithDataFile';
    end



    overrideValues=cell(length(overrides),1);
    overrideFlag(1:length(overrides))=false;
    for i=1:length(overrides)
        if isValidParam(cs,overrides{i})
            overrideValues{i}=get_param(cs,overrides{i});
            overrideFlag(i)=true;
        else
            overrideFlag(i)=false;
        end
    end


    rtwconfiguremodel(model,'Specified','fxpMode',fpMode,'forGRT',forGRT,...
    'optimized',true,'forDSP',false,'nonFinites',false);



    cs=getActiveConfigSet(model);


    for i=1:length(overrides)
        if~overrideFlag(i)
            if isValidParam(cs,overrides{i})
                overrideValues{i}=get_param(cs,overrides{i});
                overrideFlag(i)=true;
            else
                MSLDiagnostic('rtwdemos:rtwconfiguredemo:invalidparam',overrides{i}).reportAsWarning;
            end
        end
    end


    value=rtwhostwordlengths();
    set_param(cs,'ProdHWDeviceType','Specified');
    set_param(cs,'ProdBitPerChar',value.CharNumBits);
    set_param(cs,'ProdBitPerShort',value.ShortNumBits);
    set_param(cs,'ProdBitPerInt',value.IntNumBits);
    set_param(cs,'ProdBitPerLong',value.LongNumBits);
    set_param(cs,'ProdBitPerLongLong',value.LongLongNumBits);
    set_param(cs,'ProdWordSize',value.WordSize);
    set_param(cs,'ProdBitPerPointer',value.PointerNumBits);
    set_param(cs,'ProdBitPerSizeT',value.SizeTNumBits);
    set_param(cs,'ProdBitPerPtrDiffT',value.PtrDiffTNumBits);

    if value.LongLongMode==1;
        set_param(cs,'ProdLongLongMode','on');
    else
        set_param(cs,'ProdLongLongMode','off');
    end

    value=rtw_host_implementation_props;
    if value.ShiftRightIntArith==true;
        set_param(cs,'ProdShiftRightIntArith','on');
    else
        set_param(cs,'ProdShiftRightIntArith','off');
    end
    set_param(cs,'ProdIntDivRoundTo',value.IntDivRoundTo);
    set_param(cs,'ProdEndianess',value.Endianess);

    set_param(cs,'ProdEqTarget','on');

    set_param(cs,'GRTInterface','off');
    set_param(cs,'SupportNonFinite','off');

    if~forGRT
        set_param(cs,'SupportComplex','off');
        set_param(cs,'SupportContinuousTime','off');
        set_param(cs,'IncludeERTFirstTime','off');
        set_param(cs,'SupportNonInlinedSFcns','off');
        set_param(cs,'EnhancedBackFolding','on');
        set_param(cs,'BooleansAsBitfields','on');
        set_param(cs,'UseDivisionForNetSlopeComputation','on');
        set_param(cs,'PassReuseOutputArgsAs','Individual arguments');
        set_param(cs,'GenerateCodeMetricsReport','on');
        set_param(cs,'GenerateCodeReplacementReport','off');
    end

    isERT=strcmp(get_param(cs,'IsERTTarget'),'on');
    if isERT
        set_param(model,'RateTransitionBlockCode',origRateTransitionBlockCode);
        set_param(model,'ERTFilePackagingFormat',origFilePackaging);
    end

    for i=1:length(overrides)
        if overrideFlag(i)&&isValidParam(cs,overrides{i})
            set_param(cs,overrides{i},overrideValues{i});
        end
    end


    if~isDirty
        set_param(model,'Dirty','off');
    end

end
