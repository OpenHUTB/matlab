classdef(Sealed)CoderConfigController<coderapp.internal.config.AbstractController



    properties(Constant,Access=private)
        TLS_C={'Auto','C89/C90 (ANSI)','C99 (ISO)'}
        TLS_CPP={'C++03 (ISO)','C++11 (ISO)'}
        AUTO_TOOLCHAIN=coder.make.internal.getInfo('default-toolchain')
        HAS_CODER_MATLABCODER=~isempty(which('coder.MATLABCodeTemplate'))
    end

    properties(Access=private)

SampleConfig

CrlConfig
    end

    methods
        function this=CoderConfigController()
            this.SampleConfig=coder.config('lib','ecoder',true);
            this.CrlConfig=coder.config('lib','ecoder',true);
        end

        function updateBuildType(this,configSlot,boundConfig,isFiaccel)
            import coderapp.internal.coderconfig.BuildType;

            strVal=this.get();
            if~isempty(strVal)
                next=BuildType(this.get());
            else
                next=BuildType('LIB');
            end

            if isempty(configSlot)
                if~isempty(boundConfig)
                    if isa(boundConfig,'coder.EmbeddedCodeConfig')||isa(boundConfig,'coder.CodeConfig')
                        allowed=BuildType({'LIB','DLL','EXE'});
                        current=this.get();
                        if isempty(current)||~ismember(BuildType(current),allowed)
                            next=BuildType(boundConfig.OutputType);
                        end
                    else
                        allowed=BuildType('MEX');
                        next=allowed;
                    end
                else
                    allowed=enumeration('coderapp.internal.coderconfig.BuildType');
                end
            else
                switch configSlot
                case 'rtw'
                    allowed=BuildType({'LIB','DLL','EXE'});
                    if this.get=="MEX"
                        next=BuildType('LIB');
                    end
                case{'mex','check'}
                    allowed=BuildType('MEX');
                    next=allowed;
                otherwise
                    error('Unrecognized configSlot value: %s',configSlot);
                end
            end

            options=[allowed.Option];
            this.set('AllowedValues',options);
            this.set('DefaultValue',next.Option.Value);

            editable=~isscalar(allowed);
            this.set('Enabled',editable);
            this.set('Visible',editable);

            if next=="MEX"
                if isFiaccel
                    this.changePerspective('fiaccel');
                else
                    this.changePerspective('mex');
                end
            else
                this.changePerspective('c');
            end
        end

        function updateTargetLang(this,gpuEnabled,dlEnabled,dlTargetLib,boundConfig)
            import('coderapp.internal.dl.DeepLearningTargetLibrary');

            forcedLang='';
            if gpuEnabled
                forcedLang='C++';
            elseif dlEnabled
                switch dlTargetLib
                case DeepLearningTargetLibrary.None.Value
                case DeepLearningTargetLibrary.CMSISNN.Value
                    forcedLang='C';
                otherwise
                    forcedLang='C++';
                end
            end

            options=this.get('AllowedValues');
            langs={options.Value};
            cOpt=options(langs=="C");
            cOpt.Enabled=isempty(forcedLang);
            this.set('AllowedValues',[cOpt,options(langs~="C")]);

            if~isempty(forcedLang)
                if forcedLang=="C++"&&~isempty(boundConfig)
                    this.set('DefaultValue','C');

                    this.SetAsExternal=true;
                end
                this.set(forcedLang);
            else
                this.set('DefaultValue','C');
            end
        end

        function updateMaxIdLength(this,targetLang)

            switch targetLang
            case 'C'
                if this.get()==1024
                    this.set(31);
                else
                    this.set('DefaultValue',31);
                end
            case 'C++'
                if this.get()==31
                    this.set(1024);
                else
                    this.set('DefaultValue',1024);
                end
            end
        end

        function initToolchains(this)
            this.set('DefaultValue',this.AUTO_TOOLCHAIN);
        end

        function updateToolchains(this,gpuEnabled)
            if this.Awake
                toolchains=union(coder.make.internal.guicallback.getToolchains(),this.AUTO_TOOLCHAIN);
                opts=repmat(coderapp.internal.config.data.EnumOption,1,numel(toolchains));
                [opts.Value]=toolchains{:};
                for i=find(contains(toolchains,'NVIDIA'))
                    opts(i).Enabled=gpuEnabled~=strcmp(toolchains{i},'GNU GCC for NVIDIA Embedded Processors');
                end
                this.set('AllowedValues',opts);
            else
                this.useCurrentValueAsEnumeration();
            end
        end

        function updateBuildConfigurations(this,toolchain)
            if this.Awake
                try
                    [buildConfigs,defaultValue]=coder.make.internal.guicallback.getBuildConfigurations(toolchain);
                catch
                    this.import('AllowedValues',{});
                    return
                end
                if~strcmp(defaultValue,'Faster Runs')&&any(contains(buildConfigs,'Faster Runs'))
                    defaultValue='Faster Runs';
                end
                this.import('AllowedValues',buildConfigs);
                this.set('DefaultValue',defaultValue);
            else
                this.useCurrentValueAsEnumeration();
            end
        end

        function updateToolchainOptions(this,buildConfig,toolchain)
            if~this.Awake
                return
            end
            opts=coder.make.internal.guicallback.getBuildConfigOptionsAndValues(...
            toolchain,false,buildConfig,false);
            if isempty(opts)
                opts={};
            end
            current=this.get();
            if buildConfig~="Specify"||~isequal(opts(1:2:end),current(1:2:end))
                this.set(opts);
            else
                this.set('DefaultValue',opts);
            end
        end

        function updateTargetLangStandard(this,targetLang)
            switch targetLang
            case 'C++'
                options=[this.TLS_CPP,this.TLS_C];
            otherwise
                options=this.TLS_C;
            end
            this.import('AllowedValues',options);
        end

        function updateCodeReplacementLibraries(this)
            if~this.Awake
                this.useCurrentValueAsEnumeration();
                return
            end
            isErt=this.value('useEmbeddedCoder');
            if isErt
                arg.IsERTTarget='on';
            else
                arg.IsERTTarget='off';
            end
            [arg.TargetLang,arg.TargetLangStandard,arg.ProdHWDeviceVendor,arg.ProdHWDeviceType]=this.value(...
            'targetLang','targetLangStandard','prodDeviceVendor','prodDeviceType');



            this.CrlConfig.TargetLang=arg.TargetLang;
            this.CrlConfig.TargetLangStandard=arg.TargetLangStandard;
            arg.TargetLangStandard=emlcprivate('getActualTargetLangStandard',this.CrlConfig);

            try
                registry=emlcprivate('emcGetTargetRegistry');

                filtered=coder.internal.getTflList4Target(registry,arg.ProdHWDeviceVendor,arg.ProdHWDeviceType,arg);
                unfiltered=registry.TargetFunctionLibraries;
                unfiltered=sort({unfiltered([unfiltered.IsVisible]&~[unfiltered.IsSimTfl]&(isErt|~[unfiltered.IsERTOnly])).Name});
            catch me %#ok<NASGU>
                unfiltered={};
                filtered={};
            end

            if~isempty(unfiltered)

                selectable=num2cell(ismember(unfiltered,filtered));
                options=repmat(coderapp.internal.config.data.EnumOption,1,numel(unfiltered));
                [options.Value]=unfiltered{:};
                [options.Enabled]=selectable{:};
            else
                options=coderapp.internal.config.data.EnumOption.empty();
            end

            current=this.get();
            grandfather=false;
            if~any(strcmp(current,unfiltered))

                grandfather=true;
            elseif~any(strcmp(current,filtered))

                grandfather=true;
            end
            if grandfather
                grandfathered=coderapp.internal.config.data.EnumOption();
                grandfathered.Value=current;
                grandfathered.Enabled=false;
                options=[grandfathered,options];
            end

            [~,nIdx]=ismember('None',{options.Value});
            if nIdx
                none=options(nIdx);
                options(nIdx)=[];
            else
                none=coderapp.internal.config.data.EnumOption();
                none.Value='None';
            end
            none.DisplayValue=message('coderApp:config:coderOptions:genericNone').getString();
            none.Enabled=true;
            this.set('AllowedValues',[none,options]);
        end

        function updateInstructionSetExtensions(this)
            if~this.Awake
                this.useCurrentValueAsEnumeration();
                return
            end

            [hwDeviceVendor,hwDeviceType,~,isERT]=getEffectiveHardware(this);
            isVisible=this.value("x_instructionSetVisible");

            if~isVisible
                this.set('Visible',false,'Value','None');
                return;
            else
                this.set('Visible',true);
            end

            try





                emptyValue='';
                [entries,default]=emlcprivate('getAvailableInstructionSetExtensions',...
                emptyValue,hwDeviceVendor,hwDeviceType,isERT);
                options=repmat(coderapp.internal.config.data.EnumOption,1,numel(entries));
                [options.Value]=entries{:};
            catch me %#ok<NASGU>
                options=coderapp.internal.config.data.EnumOption.empty();
                default='None';
            end

            [~,nIdx]=ismember('None',{options.Value});
            if nIdx
                none=options(nIdx);
                options(nIdx)=[];
            else
                none=coderapp.internal.config.data.EnumOption();
                none.Value='None';
            end




            this.set('Value',default);

            none.DisplayValue=message('coderApp:config:coderOptions:genericNone').getString();
            none.Enabled=true;

            this.set('AllowedValues',[none,options]);




            this.set('DefaultValue','None');
        end

        function updateOptimizeReductions(this)
            instructionSetExtensions=this.value("instructionSetExtensions");

            automaticParallelizationEnabled=this.value("enableAutoParallelization");


            this.set('Visible',this.value("x_notGpuEnabled"));

            if automaticParallelizationEnabled||~strcmpi(instructionSetExtensions,"None")
                this.set('Enabled',true);
            else
                this.set('Enabled',false);
            end

        end

        function updateInstructionSetVisible(this)
            [hwDeviceVendor,hwDeviceType,gpuEnabled,isERT]=getEffectiveHardware(this);

            isVisible=~gpuEnabled&&...
            emlcprivate('isInstructionSetExtensionsAvailable',hwDeviceVendor,hwDeviceType,isERT);

            this.set('Value',isVisible);

        end

        function updatePathSepDelimited(this,defaultConfig)
            this.set('DefaultValue',this.importPathSepString(...
            defaultConfig.(this.metadata('objectProperty'))));
        end

        function updateSemicolonDelimited(this,defaultConfig)
            this.set('DefaultValue',this.importSemicolonString(...
            defaultConfig.(this.metadata('objectProperty'))));
        end

        function value=validateIdentifierFormat(this,value)

            this.SampleConfig.(this.metadata('objectProperty'))=value;
        end

        function value=validateReplacementType(this,value)



            rt=coder.ReplacementTypes();
            rt.(this.metadata('objectProperty'))=value;
        end

        function value=validateCppNamespace(this,value)
            [errStr,value]=coder.internal.validateCppIdentifierName(value,'');
            if~isempty(errStr)
                error(message('Coder:FE:InvalidNamespace',value,this.get('Name')));
            end
        end
    end

    methods(Static)
        function value=importPathSepString(value)
            value=delimitedToCell(value,pathsep());
        end

        function str=exportPathSepString(value)
            str=cellstr(value);
            if isempty(value)||(length(str)==1&&isempty(str{1}))
                str='';
            end
        end

        function str=toCellStringCode(value)
            value=coderapp.internal.coderconfig.CoderConfigController.exportPathSepString(value);
            str=coderapp.internal.value.valueToExpression(value);
        end

        function value=importSemicolonString(value)
            value=delimitedToCell(value,';');
        end

        function str=exportSemicolonString(value)
            str=strjoin(value,';');
        end

        function majority=importMajority(value)
            if ischar(value)
                majority=value;
            elseif value
                majority='row';
            else
                majority='column';
            end
        end

        function isRowMajor=exportMajority(value)
            isRowMajor=strcmp(value,'row');
        end

        function str=majorityToCode(value)
            if value=="row"
                str='true';
            else
                str='false';
            end
        end

        function template=importCodeTemplate(template)
            if isempty(template)||~isobject(template)
                template='';
                return
            end
            template=template.CGTFile;
            if isempty(fileparts(template))
                whiched=which(template);
                if isfile(whiched)
                    template=whiched;
                else
                    template=fullfile(pwd,template);
                end
            end
        end

        function template=exportCodeTemplate(templateFile)


            if~coderapp.internal.coderconfig.CoderConfigController.HAS_CODER_MATLABCODER
                template=[];
                return
            end
            template=coder.MATLABCodeTemplate.empty();
            if isfile(templateFile)
                try
                    template=coder.MATLABCodeTemplate(templateFile);
                catch me %#ok<NASGU>
                end
            end
        end

        function code=codeTemplateToCode(templateFile)
            if~isempty(templateFile)
                code=sprintf('coder.MATLABCodeTemplate(%s)',mat2str(string(templateFile)));
            else
                code='coder.MATLABCodeTemplate.empty()';
            end
        end

        function lowered=buildTypeToCode(str)
            lowered=mat2str(string(lower(str)));
        end

        function value=validateCppClassName(value)
            [errStr,value]=coder.internal.validateCppIdentifierName(value,'');
            if~isempty(errStr)
                error(message('Coder:FE:InvalidClassName'));
            end
        end

        function code=customToolchainOptionsToCode(tcOptions)
            code=coderapp.internal.value.valueToExpression(cellstr(tcOptions));
        end
    end

    methods(Access=private)
        function useCurrentValueAsEnumeration(this)
            current=this.get();
            if isempty(current)
                allowedVals={};
            else
                allowedVals={current};
            end
            this.import('AllowedValues',allowedVals);
        end

        function[hwDeviceVendor,hwDeviceType,gpuEnabled,isERT]=getEffectiveHardware(this)
            [prodEqTarget,prodHWDeviceVendor,prodHWDeviceType,targetHWDeviceVendor,targetHWDeviceType,gpuEnabled,isERT]=this.value(...
            'prodEqTarget','prodDeviceVendor','prodDeviceType','targetDeviceVendor','targetDeviceType','gpuEnabled','useEmbeddedCoder');

            if prodEqTarget
                hwDeviceVendor=prodHWDeviceVendor;
                hwDeviceType=prodHWDeviceType;
            else
                hwDeviceVendor=targetHWDeviceVendor;
                hwDeviceType=targetHWDeviceType;
            end

        end
    end
end


function value=delimitedToCell(value,delimiter)
    if isempty(value)
        value={};
    elseif isstring(value)&&numel(value)>1





        value=cellstr(value);
    elseif ischar(value)||isstring(value)

        value=strsplit(char(value),delimiter);
    end




end
