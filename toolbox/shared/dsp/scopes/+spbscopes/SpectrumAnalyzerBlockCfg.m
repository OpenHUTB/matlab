classdef SpectrumAnalyzerBlockCfg<Simulink.scopes.ScopeBlockSpecification




    properties(Transient)
        executedStartFcn=false;
        executedMdlStart=false;
    end

    properties(Access=private,Transient)
FileMenuOpeningListener
    end

    properties(Access=private,Constant,Transient)
        DSTVersion=ver('dsp');
        SimscapeVersion=ver('simscape');
        RFBlocksetVersion=ver('rfblks');
    end

    methods

        function this=SpectrumAnalyzerBlockCfg(varargin)


            mlock;
            this@Simulink.scopes.ScopeBlockSpecification(varargin{:});
        end
    end

    methods

        function hCopy=copy(this)
            hCopy=copy@Simulink.scopes.ScopeBlockSpecification(this);
            hCopy.OpenAtMdlStart=this.OpenAtMdlStart;
        end

        function openAtMdlStart=getOpenAtMdlStart(this)
            openAtMdlStart=this.OpenAtMdlStart;
        end

        function b=getNeedRuntimeCallbacks(~)

            b=false;
        end

        function setBlockParams(this,varargin)
            if nargin>1
                setBlockParam(this.Scope,varargin{:});
            end
        end

        function setScopeParams(~)

        end

        function b=showConfiguration(~)


            b=false;
        end

        function appName=getScopeTag(~)

            appName='Spectrum Analyzer';
        end

        function hTypes=getHiddenTypes(~)
            hTypes={'Sources','Visuals'};
        end

        function hiddenExts=getHiddenExtensions(~)


            hiddenExts={'Core:Source UI',...
            'Visuals',...
            'Tools:Instrumentation Sets',...
            'Tools:Image Tool',...
            'Tools:Pixel Region',...
            'Tools:Image Navigation Tools',...
            };
        end

        function measurementTags=getSupportedMeasurements(this)
            [~,~,licenseType]=checkLicense(this,false);
            if any(strcmp(licenseType,{'Simscape','RFBlockset'}))
                measurementTags={'fcursors','peaks','distortion'};
            else
                measurementTags={'fcursors','peaks','channel','distortion','ccdf'};
            end
        end

        function mdlStart(this)

            this.executedMdlStart=true;
            startFcn(this);
        end


        function onScopeLaunched(this)

            hFrameWork=this.Scope.Framework;
            if isempty(hFrameWork)
                return;
            end

            hVisual=hFrameWork.Visual;
            if isempty(hVisual)
                return;
            end


            dirtyState=getDirtyStatus(hVisual);
            ccleanup=onCleanup(@()restoreDirtyStatus(hVisual,dirtyState));

            if~this.executedStartFcn&&this.executedMdlStart
                startFcn(this);
            end
        end


        function mdlTerminate(this)

            hFrameWork=this.Scope.Framework;
            if~isempty(hFrameWork)
                hVisual=hFrameWork.Visual;
                hVisual.DataBuffer.flush;

            end

            this.executedStartFcn=false;
            this.executedMdlStart=false;
        end

        function renderMenus(this,hScope)


            this.FileMenuOpeningListener=event.listener(hScope,...
            'FileMenuOpening',@this.onFileMenuOpening);
        end

        function onFileMenuOpening(this,hScope,~)



            hFileMenu=findobj(hScope.Parent,'Tag','uimgr.uimenugroup_File');
            hOpen=findobj(hFileMenu,'Tag','uimgr.spctogglemenu_OpenAtMdlStart');
            hNumInputs=findobj(hFileMenu,'Tag','uimgr.uimenugroup_NumberOfInputPorts');

            if isempty(hOpen)
                hOpen=uimenu('Parent',hFileMenu,...
                'Tag','uimgr.spctogglemenu_OpenAtMdlStart',...
                'Position',1,...
                'Label',getString(message('Spcuilib:scopes:OpenAtMdlStart')),...
                'Callback',@(h,ev)toggleOpenAtMdlStart(this));

                hNumInputs=uimenu('Parent',hFileMenu,...
                'Tag','uimgr.uimenugroup_NumberOfInputPorts',...
                'Position',2,...
                'Label',getString(message('Spcuilib:scopes:NumInputPortsWithKBShortcut')),...
                'Callback',@this.numInputPortsCB);

                cb=@this.numInputsCallback;

                uimenu('Parent',hNumInputs,...
                'Tag','uimgr.spctogglemenu_1',...
                'Label','1',...
                'Callback',cb);
                uimenu('Parent',hNumInputs,...
                'Label','2',...
                'Tag','uimgr.spctogglemenu_2',...
                'Callback',cb);
                uimenu('Parent',hNumInputs,...
                'Label','3',...
                'Tag','uimgr.spctogglemenu_3',...
                'Callback',cb);
                uimenu('Parent',hNumInputs,...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'Label',getString(message('Spcuilib:scopes:MenuMore')),...
                'Tag','uimgr.spctogglemenu_More',...
                'Callback',cb);


                set(findobj(hFileMenu,'Parent',hFileMenu,'Position',3),'Separator','on');
            end


            isStopped=strcmp(get_param(bdroot(this.Block.Handle),'SimulationStatus'),'stopped');
            set(hOpen,'Checked',uiservices.logicalToOnOff(this.OpenAtMdlStart));
            set(hNumInputs,'Enable',uiservices.logicalToOnOff(isStopped));
        end

        function[mApp,mExample,mAbout]=createHelpMenuItems(this,mHelp)

            [~,~,licenseType]=checkLicense(this,false);
            if any(strcmp(licenseType,{'Simscape','RFBlockset'}))





                if strcmp(licenseType,'RFBlockset')
                    mapFileLocation=fullfile(docroot,'simrf','helptargets.map');
                else
                    mapFileLocation=fullfile(docroot,'physmod','simscape','helptargets.map');
                end

                mApp=uimenu(mHelp,...
                'Tag','uimgr.uimenu_Spectrum Analyzer',...
                'Label',getString(message('dspshared:SpectrumAnalyzer:SpectrumAnalyzerBlockHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'spectrumanalyzer'));

                mExample=[];


                mAbout=uimenu(mHelp,...
                'Tag','uimgr.uimenu_About',...
                'Label',getString(message('dspshared:SpectrumAnalyzer:AboutSpectrumAnalyzerMenu')),...
                'Callback',@(hco,ev)aboutSpectrumAnalyzer);
            else
                mapFileLocation=fullfile(docroot,'toolbox','dsp','dsp.map');

                mApp(1)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_Spectrum Analyzer',...
                'Label',getString(message('dspshared:SpectrumAnalyzer:SpectrumAnalyzerBlockHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'dspspectrumanalyzer'));

                mApp(2)=uimenu(mHelp,...
                'Tag','uimgr.uimenu_DSP System Toolbox',...
                'Label',getString(message('dspshared:SpectrumAnalyzer:DSPSystemToolboxHelp')),...
                'Callback',@(hco,ev)helpview(mapFileLocation,'dspinfo'));




                mExample=uimenu(mHelp,...
                'Tag','uimgr.uimenu_DSP System Toolbox Demos',...
                'Label',getString(message('dspshared:SpectrumAnalyzer:DSPSystemToolboxDemos')),...
                'Callback',@(hco,ev)demo('toolbox','dsp'));



                mAbout=uimenu(mHelp,...
                'Tag','uimgr.uimenu_About',...
                'Label',getString(message('Spcuilib:scopes:AboutDSPSystemToolbox')),...
                'Callback',@(hco,ev)aboutdspsystbx);

            end
        end

        function cfgFile=getConfigurationFile(~)
            cfgFile='spectrumanalyzerblock.cfg';
        end

        function helpArgs=getHelpArgs(~,key)
            if strcmp(key,'PlotNavigationSuffix')
                helpArgs='SA';
            else
                helpArgs=[];
            end
        end

        function configClass=getConfigurationClass(~)



            configClass='spbscopes.SpectrumAnalyzerConfiguration';
        end

        function startFcn(this)

            hFrameWork=this.Scope.Framework;
            if~isempty(hFrameWork)

                this.executedStartFcn=true;




                [success,errMsg]=checkLicense(this,true);
                if~success
                    error(errMsg);
                end

                hVisual=hFrameWork.Visual;
                hPlotter=[];
                if~isempty(hVisual)
                    hPlotter=hFrameWork.Visual.Plotter;
                end
                if~isempty(hPlotter)
                    maxDims=hPlotter.MaxDimensions;
                    nChannels=prod(maxDims(1,2:end));

                    if nChannels>100
                        error((message('dspshared:SpectrumAnalyzer:TooManyInputChannels',100)));
                    end
                end

                if~isempty(hVisual)


                    dirtyState=getDirtyStatus(hVisual);
                    c=onCleanup(@()restoreDirtyStatus(hVisual,dirtyState));

                    hVisual.DataBuffer=get_param(this.Block.handle,'Timebuffer');
                    hVisual.SpectrumObject.DataBuffer=get_param(this.Block.handle,'Timebuffer');


                    isInputComplex=logical(hFrameWork.DataSource.BlockHandle.CompiledPortComplexSignals.Inport);
                    nSignals=1;
                    maxNumTimeSteps=1;
                    setupBufferParams(hVisual.DataBuffer,...
                    nSignals,...
                    [],...
                    maxNumTimeSteps,...
                    [],...
                    any(isInputComplex));

                    setLegacyMode(this);

                    loadLineProperties(hVisual);
                    onSourceRun(hVisual);
                end
            end
        end

        function b=showKeyboardCommand(~)


            b=false;
        end

        function b=showMessageLog(~)


            b=false;
        end

        function pos=getDefaultPosition(~)



            pos=uiscopes.getDefaultPosition([800,450]);
        end

        function evalAndSetNumInputPorts(this,numInputPorts)
            if~isempty(numInputPorts)&&ischar(numInputPorts)




                numInputPortsVal=str2num(numInputPorts);%#ok<ST2NM>
                if isempty(numInputPortsVal)





                    if~isvarname(numInputPorts)
                        uiscopes.errorHandler(getString(message('Spcuilib:scopes:InvalidVariableName',numInputPorts)));
                        return
                    end
                    try
                        numInputPortsVal=evalVarInMdlOrBaseWS(this,numInputPorts);
                    catch meNotUsed %#ok<NASGU>
                        uiscopes.errorHandler(getString(message('Spcuilib:scopes:VariableNotFound',numInputPorts)));
                        return
                    end
                    if~isnumeric(numInputPortsVal)
                        uiscopes.errorHandler(getString(message(...
                        'dspshared:SpectrumAnalyzer:invalidVariableForNumberOfInputPorts',numInputPorts)));
                        return
                    end
                end


                hFrameWork=this.Scope.Framework;
                if~isempty(hFrameWork)
                    hVisual=hFrameWork.Visual;


                    if strcmpi(hVisual.pFrequencyVectorSource,'InputPort')&&...
                        strcmpi(hVisual.pFrequencyInputRBWSource,'InputPort')&&...
                        numInputPortsVal<3
                        uiscopes.errorHandler(getString(message(...
                        'dspshared:SpectrumAnalyzer:invalidNumberOfInputPortsFreqAndRBWEnabled')))
                        return;
                    elseif(strcmpi(hVisual.pFrequencyVectorSource,'InputPort')||...
                        strcmpi(hVisual.pFrequencyInputRBWSource,'InputPort'))&&...
                        numInputPortsVal<2
                        if strcmpi(hVisual.pFrequencyVectorSource,'InputPort')
                            uiscopes.errorHandler(getString(message(...
                            'dspshared:SpectrumAnalyzer:invalidNumberOfInputPortsFreqOrRBWEnabled','FrequencyVectorSource')));
                        else
                            uiscopes.errorHandler(getString(message(...
                            'dspshared:SpectrumAnalyzer:invalidNumberOfInputPortsFreqOrRBWEnabled','RBWSource')));
                        end
                        return;
                    end
                end


                try
                    Simulink.scopes.setBlockParam(this.Block,'NumInputPorts',num2str(double(numInputPortsVal)));
                catch ME
                    uiscopes.errorHandler(ME.message);
                end

            end
        end
    end

    methods(Access=protected)
        function defOpen=getDefaultOpenAtMdlStart(~)
            defOpen=true;
        end


        function retVal=getDefaultConfigParams(this)

            persistent defaultConfigParams;

            if isempty(defaultConfigParams)
                defaultConfigParams=extmgr.ConfigurationSet.createAndLoad(this.getConfigurationFile);
            end

            retVal=defaultConfigParams;
        end

        function numInputPortsCB(this,h,~)


            children=get(h,'Children');
            block=this.Block.Handle;
            numPorts=get_param(block,'NumInputPorts');

            if str2double(numPorts)>3
                numPorts='More';
            end


            hVisual=this.Scope.Framework.Visual;
            if strcmpi(hVisual.pFrequencyVectorSource,'InputPort')&&...
                strcmpi(hVisual.pFrequencyInputRBWSource,'InputPort')
                children(3).Enable='off';
                children(4).Enable='off';
            elseif(strcmpi(hVisual.pFrequencyVectorSource,'InputPort')||...
                strcmpi(hVisual.pFrequencyInputRBWSource,'InputPort'))
                children(3).Enable='on';
                children(4).Enable='off';
            else
                children(3).Enable='on';
                children(4).Enable='on';
            end

            child=findobj(children,'Tag',['uimgr.spctogglemenu_',numPorts]);

            siblings=children(children~=child);
            set(child,'Checked','on');
            set(siblings,'Checked','off');
        end

        function numInputsCallback(this,h,~)



            tag=get(h,'Tag');
            [~,id]=strtok(tag,'_');
            id(1)=[];


            if strcmpi(id,'more')



                dp=DAStudio.DialogProvider;
                title=getString(message('Spcuilib:scopes:DialogTitleSourceUIOptions'));
                label=getString(message('Spcuilib:scopeblock:NumInputPorts'));
                numInputPorts=dp.inputdlg(label,title,get_param(this.Block.Handle,'NumInputPorts'));
                evalAndSetNumInputPorts(this,numInputPorts);
            else

                hVisual=this.Scope.Framework.Visual;


                numInputPortsVal=str2double(id);
                if strcmpi(hVisual.pFrequencyVectorSource,'InputPort')&&...
                    strcmpi(hVisual.pFrequencyInputRBWSource,'InputPort')&&...
                    numInputPortsVal<3
                    uiscopes.errorHandler(getString(message(...
                    'dspshared:SpectrumAnalyzer:invalidNumberOfInputPortsFreqAndRBWEnabled')))
                    return;
                elseif(strcmpi(hVisual.pFrequencyVectorSource,'InputPort')||...
                    strcmpi(hVisual.pFrequencyInputRBWSource,'InputPort'))&&...
                    numInputPortsVal<2
                    if strcmpi(hVisual.pFrequencyVectorSource,'InputPort')
                        uiscopes.errorHandler(getString(message(...
                        'dspshared:SpectrumAnalyzer:invalidNumberOfInputPortsFreqOrRBWEnabled','FrequencyVectorSource')));
                    else
                        uiscopes.errorHandler(getString(message(...
                        'dspshared:SpectrumAnalyzer:invalidNumberOfInputPortsFreqOrRBWEnabled','RBWSource')));
                    end
                    return;
                end
                Simulink.scopes.setBlockParam(this.Block,'NumInputPorts',id)
            end
        end

    end

    methods(Hidden)
        function setLegacyMode(this)

















            hFrameWork=this.Scope.Framework;
            if isempty(hFrameWork)
                return;
            end

            hVisual=hFrameWork.Visual;
            if isempty(hVisual)
                return;
            end


            s=scopeextensions.ScopeBlock.getScopeConfiguration('nop',this.Block.Handle);


            if s.LegacySetFlag

                hPlotter=hFrameWork.Visual.Plotter;

                if isempty(hPlotter)
                    return;
                end

                maxDims=hPlotter.MaxDimensions;
                numSamples=maxDims(1);
                if numSamples==0
                    return;
                end

                s.FrequencyResolutionMethod='WindowLength';
                if strcmp(s.SegLen,'useInputSize')&&numSamples>2

                    s.WindowLength=num2str(numSamples);
                end
                s.LegacySetFlag=false;


                if strcmp(s.FFTLengthSource,'Property')
                    fftlen=str2double(s.FFTLength);
                    winlen=str2double(s.WindowLength);
                    if fftlen<winlen
                        fftlen=2^ceil(log2(winlen));
                        s.FFTLength=num2str(fftlen);
                    end
                else


                    s.FFTLengthSource='Property';
                    s.FFTLength=s.WindowLength;
                end



                try
                    synchronizeWithSpectrumObject(hVisual);
                    [~,e2]=validateSpectrumSettings(hVisual);

                    if~isempty(e2)
                        s.FrequencySpan='Full';
                    end
                catch e %#ok
                end
            end
        end

        function b=shouldShowPlaybackToolbar(~)
            b=false;
        end

        function b=isToolbarCompact(~,toolbarName)


            b=~(strcmp(toolbarName,'measurements'));
        end

        function b=isMenuCompact(~,menuName)

            b=strcmp(menuName,'autoscale');
        end

        function[success,errMessage,licenseType]=checkLicense(this,checkoutFlag)






            success=false;
            licenseType='';
            errMessage=message('dspshared:SpectrumAnalyzer:DSTAndSimscapeLicenseFailed');


            isDSTInstalled=~isempty(this.DSTVersion)&&builtin('license','test','Signal_Blocks');
            isSimscapeInstalled=~isempty(this.SimscapeVersion)&&builtin('license','test','Simscape');
            isRFBlocksetInstalled=~isempty(this.RFBlocksetVersion)&&builtin('license','test','RF_Blockset');

            if isDSTInstalled


                licenseType='Signal_Blocks';
                success=true;
                errMessage=[];
                if checkoutFlag
                    [success,~]=builtin('license','checkout',licenseType);
                    if~success
                        errMessage=message('dspshared:SpectrumAnalyzer:DSTLicenseFailed');
                    end
                end
            elseif isSimscapeInstalled


                licenseType='Simscape';
                success=true;
                errMessage=[];
                if checkoutFlag
                    [success,~]=builtin('license','checkout',licenseType);
                    if~success
                        errMessage=message('dspshared:SpectrumAnalyzer:SimscapeLicenseFailed');
                    end
                end
            elseif isRFBlocksetInstalled


                licenseType='RFBlockset';
                success=true;
                errMessage=[];
                if checkoutFlag
                    [success,~]=builtin('license','checkout','RF_Blockset');
                    if~success
                        errMessage=message('dspshared:SpectrumAnalyzer:RFBlocksetLicenseFailed');
                    end
                end
            end
        end
    end

    methods(Static,Hidden)
        function this=loadobj(s)

            this=loadobj@Simulink.scopes.ScopeBlockSpecification(s);

            configSet=this.CurrentConfiguration;
            if isempty(configSet)
                return;
            end

            cfg=configSet.findConfig('Core','Source UI');
            if~isempty(cfg)&&~isempty(cfg.PropertySet)
                if isValidProperty(cfg.PropertySet,'ShowPlaybackCmdMode')
                    setValue(cfg.PropertySet,'ShowPlaybackCmdMode',false);
                end
            end



            cfg=configSet.findConfig('Visuals','Spectrum');
            if~isempty(cfg)&&~isempty(cfg.PropertySet)
                if isValidProperty(cfg.PropertySet,'IsValidSettingsDialogReadouts')
                    setValue(cfg.PropertySet,'IsValidSettingsDialogReadouts',false);
                end
            end

            configs=configSet.Children;
            allTypes={configs.Type};
            allNames={configs.Name};
            if strcmp(this.Version,'2013a')

                if isfield(s,'Position')&&isequal(s.Position,[755,450,410,300])
                    this.Position=[680,390,560,420];
                end

                cfg=configs(strcmp(allTypes,'Visuals')&strcmp(allNames,'Spectrum'));
                if~isempty(cfg)&&~isempty(cfg.PropertySet)
                    pSet=cfg.PropertySet;
                    if isValidProperty(pSet,'AxesProperties')
                        value=getValue(pSet,'AxesProperties');

                        newColor=0.686274509804*ones(1,3);
                        if isfield(value,'XColor')&&isequal(value.XColor,[0.4,0.4,0.4])
                            value.XColor=newColor;
                        end
                        if isfield(value,'YColor')&&isequal(value.YColor,[0.4,0.4,0.4])
                            value.YColor=newColor;
                        end
                        if isfield(value,'ZColor')&&isequal(value.ZColor,[0.4,0.4,0.4])
                            value.ZColor=newColor;
                        end
                        setValue(pSet,'AxesProperties',value);
                    end

                end
                cfg=configs(strcmp(allTypes,'Core')&strcmp(allNames,'General UI'));
                if~isempty(cfg)&&~isempty(cfg.PropertySet)
                    pSet=cfg.PropertySet;
                    if isValidProperty(pSet,'FigureColor')



                        c=[...
                        get(0,'DefaultUIControlBackgroundColor');...
                        repmat(0.941176,1,3);...
                        repmat(0.929411,1,3)];
                        v=repmat(getValue(pSet,'FigureColor'),3,1);
                        if any(all(abs(c-v)<1e-6,2))
                            setValue(pSet,'FigureColor',0.156862745098039*ones(1,3));
                        end
                    end
                end
            end
        end

        function b=useMCOSExtMgr(~)
            b=true;
        end

        function b=useUIMgr(~)
            b=false;
        end
    end
end


function toggleOpenAtMdlStart(this)

    this.OpenAtMdlStart=~this.OpenAtMdlStart;

    set(bdroot(this.Block.handle),'dirty','on');

end


function aboutSpectrumAnalyzer



    tbx=ver('simulink');
    msg=sprintf('%s\n%s',getString(message('dspshared:SpectrumAnalyzer:AboutSpectrumAnalyzerMessage')),...
    getString(message('dspshared:SpectrumAnalyzer:copyright',datestr(tbx.Date,'yyyy'))));
    title=getString(message('dspshared:SpectrumAnalyzer:AboutSpectrumAnalyzerTitle'));

    msgbox(msg,title,'modal');
end


