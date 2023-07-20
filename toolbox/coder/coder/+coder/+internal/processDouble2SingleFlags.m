function codegen_args=processDouble2SingleFlags(client,codegen_args)



    try
        codegen_args=processDouble2SingleFlagsImpl(client,codegen_args);
    catch ex
        throwAsCaller(ex);
    end
end

function codegen_args=processDouble2SingleFlagsImpl(client,codegen_args)
    singleCFlagPos=[];


    if strcmp(client,'convertToSingle')
        codegen_args=convertStringsToChars(codegen_args);

        cfgFound=false;
        for ii=1:numel(codegen_args)
            arg=codegen_args{ii};
            if isa(arg,'char')&&~isempty(arg)
                if arg(1)=='-'
                    switch arg(2:end)
                    case{'args','globals'}


                    case{'config'}
                        if cfgFound
                            error(message('Coder:FXPCONV:DTS_MultipleConfig'));
                        end
                        cfgFound=true;
                        if ii+1>numel(codegen_args)
                            error(message('Coder:FXPCONV:DTS_MissingConfig'));
                        end
                        if~isa(codegen_args{ii+1},'coder.SingleConfig')
                            error(message('Coder:FXPCONV:DTS_InvalidConfig'));
                        end
                        validateIfSingleCfg(codegen_args{ii+1});
                    otherwise
                        error(message('Coder:FXPCONV:DTS_InvalidOption',arg));
                    end
                end
            end
        end

        configFlagPos=[];

        for ii=1:numel(codegen_args)
            arg=convertStringsToChars(codegen_args{ii});
            if isa(arg,'char')&&strcmp(arg,'-config')
                configFlagPos=ii;
                break;
            end
        end

        if isempty(configFlagPos)

            codegen_args{end+1}='-config';
            codegen_args{end+1}=coder.config('single');
        end
        return;
    end

    for ii=1:numel(codegen_args)
        arg=convertStringsToChars(codegen_args{ii});
        if isa(arg,'char')&&strcmp(arg,'-singleC')
            singleCFlagPos(end+1)=ii;%#ok<AGROW>
        end
    end

    if~isempty(singleCFlagPos)
        assertFixedPointDesignerLicense();

        switch client
        case{'codegen'}

        otherwise
            return;
        end


        codegen_args(singleCFlagPos)=[];


        coderCfg=[];
        featureCtrl=[];
        ii=1;
        while ii<=numel(codegen_args)
            arg=convertStringsToChars(codegen_args{ii});
            if isa(arg,'coder.Config')

                coderCfg=copy(arg);
                codegen_args{ii}=coderCfg;
                break;
            elseif isa(arg,'coder.FixPtConfig')
                coderCfg=arg;
                break;
            elseif ischar(arg)
                defConfigPrefix='-config:';
                if strncmp(arg,defConfigPrefix,numel(defConfigPrefix))
                    cfgType=arg(numel(defConfigPrefix)+1:end);
                    switch cfgType
                    case{'mex','lib','dll','exe'}

                        coderCfg=defaultConfig(cfgType);
                        codegen_args(ii)=[];
                        codegen_args=cell_insert(codegen_args,ii,'-config',coderCfg);
                        ii=ii+2;
                        continue;
                    otherwise
                        error(message('Coder:FXPCONV:DTSSingleCNotSupportedWithOption',cfgType));
                    end
                end
            elseif isa(arg,'coder.internal.FeatureControl')
                featureCtrl=arg;
            end

            ii=ii+1;
        end

        if~isempty(coderCfg)
            cfgClass=class(coderCfg);
            switch cfgClass
            case{'coder.EmbeddedCodeConfig','coder.MexCodeConfig','coder.CodeConfig'}

            otherwise
                error(message('Coder:FXPCONV:DTSSingleCNotSupportedWithConfig',cfgClass));
            end
        end

        if isempty(coderCfg)


            coderCfg=defaultConfig('mex');
            codegen_args{end+1}='-config';
            codegen_args{end+1}=coderCfg;
        end

        cfg=internal.float2fixed.F2FConfig;
        cfg.DoubleToSingle=true;
        coder.internal.initializeF2FConfig(cfg,coderCfg);



        coderCfg.F2FConfig=cfg;

        if isprop(coderCfg,'HighlightPotentialDataTypeIssues')
            coderCfg.HighlightPotentialDataTypeIssues=true;
        else
            if isempty(featureCtrl)
                featureCtrl=coder.internal.FeatureControl;
                codegen_args{end+1}='-feature';
                codegen_args{end+1}=featureCtrl;
            end
            featureCtrl.HighlightPotentialDataTypeIssues=true;
        end





        addpath([matlabroot,'/toolbox/coder/float2fixed/dtslib/'])
    else

        ii=1;
        singleCfg=[];
        otherCfgs={};
        featureCtrl=[];
        while ii<=numel(codegen_args)
            arg=convertStringsToChars(codegen_args{ii});
            if isa(arg,'char')
                switch arg
                case '-config'
                    cfgPos=ii+1;
                    if cfgPos<=numel(codegen_args)
                        validateIfSingleCfg(codegen_args{cfgPos});
                    end
                    ii=ii+2;
                    continue;
                case '-double2single'
                    assertFixedPointDesignerLicense();
                    cfgPos=ii+1;
                    if cfgPos<=numel(codegen_args)
                        cfg=codegen_args{cfgPos};
                        if isa(cfg,'coder.SingleConfig')
                            codegen_args{ii}='-float2fixed';
                            validateIfSingleCfg(cfg);
                        else
                            error(message('Coder:FXPCONV:DTSMissingConfig'));
                        end
                    else
                        error(message('Coder:FXPCONV:DTSMissingConfig'));
                    end
                    ii=ii+2;
                    continue;

                case '-config:single'
                    assertFixedPointDesignerLicense();
                    codegen_args(ii)=[];
                    singleCfg=coder.config('single');
                    codegen_args=cell_insert(codegen_args,ii,'-float2fixed',singleCfg);
                    ii=ii+2;
                    continue;

                case{'-float2fixed'}
                    assertFixedPointDesignerLicense();
                    cfgPos=ii+1;
                    if cfgPos<=numel(codegen_args)
                        cfg=codegen_args{cfgPos};
                        if isa(cfg,'coder.SingleConfig')
                            error(message('Coder:FXPCONV:DTSIncorrectOption',arg));
                        end
                    end
                    ii=ii+2;
                    continue;
                end
            end

            if isa(arg,'coder.internal.FeatureControl')
                featureCtrl=arg;
            end
            ii=ii+1;
        end

        if~isempty(singleCfg)

            ii=1;
            while ii<=numel(codegen_args)
                arg=convertStringsToChars(codegen_args{ii});
                if isa(arg,'char')
                    switch arg
                    case{'-config:lib','-config:mex','-config:exe','-config:dll'}
                        cfgType=strrep(arg,'-config:','');
                        cfg=defaultConfig(cfgType);
                        codegen_args(ii)=[];
                        codegen_args=cell_insert(codegen_args,ii,'-config',cfg);

                        continue;
                    end
                elseif isa(arg,'coder.Config')
                    otherCfgs{end+1}=arg;%#ok<AGROW>
                end
                ii=ii+1;
            end


            for ii=1:numel(codegen_args)
                arg=convertStringsToChars(codegen_args{ii});
                if isa(arg,'coder.SingleConfig')
                    singleCfgSpecified=true;
                elseif ischar(arg)&&strcmp(arg,'-double2single')
                    codegen_args{ii}='-config';
                end
            end

            if~singleCfgSpecified
                return;
            end


            cfgSet=false;
            if~isempty(otherCfgs)
                for ii=1:numel(otherCfgs)
                    cfg=otherCfgs{ii};
                    if isprop(cfg,'HighlightPotentialDataTypeIssues')
                        cfg.HighlightPotentialDataTypeIssues=true;
                        cfgSet=true;
                    end
                end
            end

            if~cfgSet

                if isempty(featureCtrl)
                    featureCtrl=coder.internal.FeatureControl;
                    codegen_args{end+1}='-feature';
                    codegen_args{end+1}=featureCtrl;
                end
                featureCtrl.HighlightPotentialDataTypeIssues=true;
            end
        end
    end

    function validateIfSingleCfg(cfg)
        if isa(cfg,'coder.SingleConfig')
            if isempty(cfg)
                error(message('Coder:FXPCONV:DTS_EmptyConfig'));
            end
            if cfg.TestNumerics&&isempty(cfg.TestBenchName)
                error(message('Coder:FXPCONV:DTS_NoTestBenchSpecified'));
            end

            singleCfg=cfg;
        else
            otherCfgs{end+1}=cfg;
        end
    end
end

function c=cell_insert(c,idx,varargin)
    what=varargin;
    c=[c(1:idx-1),what,c(idx:end)];
end

function f=assertFixedPointDesignerLicense()
    f=[];
    if~builtin('license','test','Fixed_Point_Toolbox')
        error(message('Coder:FXPCONV:DTS_RequiresFixedPointDesigner'));
    end
end

function cfg=defaultConfig(type)
    ecoder=license('test','RTW_Embedded_Coder');
    cfg=coder.config(type,'ecoder',ecoder);
end

