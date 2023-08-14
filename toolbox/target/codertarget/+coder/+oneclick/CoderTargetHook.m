classdef CoderTargetHook<coder.oneclick.TargetHook




    properties(Access='private')
        MdlRefs={}
        MdlRefOrigCS=[]
        CoderTargetCS=[]
        MdlRefCoderTargetCS=[]
        ModelsToClose={}
        OrigDirtyFlag='off'
        TargetInfo=[]
        ExternalModeInfo=[]
        SupportsTargetServices=false
        IsXCP=false
        KernelProfilerObj=[]
    end

    methods
        function h=CoderTargetHook(varargin)
            h@coder.oneclick.TargetHook(varargin{:});
            h.MdlRefOrigCS=containers.Map();
            h.MdlRefCoderTargetCS=containers.Map();
            if~isempty(h.ModelName)
                h.OrigDirtyFlag=get_param(h.ModelName,'dirty');


                [allMdls,~]=find_mdlrefs(h.ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                h.MdlRefs=allMdls(1:end-1);
                for ii=1:numel(h.MdlRefs)
                    if~bdIsLoaded(allMdls{ii})
                        load_system(allMdls{ii});
                        h.ModelsToClose=[h.ModelsToClose,allMdls(ii)];
                    end
                    h.MdlRefOrigCS(allMdls{ii})=getActiveConfigSet(allMdls{ii});






                    if isequal(get_param(allMdls{ii},'Dirty'),'on')
                        set_param(allMdls{ii},'Dirty','off')
                    end
                end
                lOrigCS=getActiveConfigSet(h.ModelName);
                targetInfo=codertarget.attributes.getTargetHardwareAttributes(lOrigCS);
                h.TargetInfo=targetInfo;
                if targetInfo.EnableOneClick
                    transportName=codertarget.data.getParameterValue(lOrigCS,'ExtMode.Configuration');
                    transportList=targetInfo.ExternalModeInfo.getIOInterfaceNames;
                    [~,idx,~]=intersect(transportList,transportName);
                    h.ExternalModeInfo=targetInfo.ExternalModeInfo(idx);
                end
            end
        end

        function delete(thisVar)
            if~isempty(thisVar.CoderTargetCS)
                if~isempty(thisVar.ExternalModeInfo.CloseFcn)
                    try
                        thisVar.locEvalNoOutput(thisVar.ExternalModeInfo.CloseFcn);
                    catch e
                        MSLDiagnostic('codertarget:build:ExternalModeCallbackError','CloseFcn',char([10,e.message])).reportAsWarning;
                    end
                end
            end
            if~isempty(thisVar.OrigDirtyFlag)&&...
                ~isempty(thisVar.ModelName)&&bdIsLoaded(thisVar.ModelName)
                set_param(thisVar.ModelName,'Dirty',thisVar.OrigDirtyFlag);
            end


            for ii=1:thisVar.MdlRefOrigCS.length
                if~bdIsLoaded(thisVar.MdlRefs{ii})
                    continue;
                end
                mdlRefCS=thisVar.MdlRefOrigCS(thisVar.MdlRefs{ii});
                resolvedmdlRefCS=mdlRefCS;
                if isa(resolvedmdlRefCS,'Simulink.ConfigSetRef')
                    resolvedmdlRefCS=resolvedmdlRefCS.getRefConfigSet();
                end
                resolvedmdlRefCS.unlock;
                if thisVar.MdlRefCoderTargetCS.isKey(thisVar.MdlRefs{ii})&&...
                    ~isequal(mdlRefCS,thisVar.MdlRefCoderTargetCS(thisVar.MdlRefs{ii}))
                    slInternal('restoreOrigConfigSetForBuild',...
                    get_param(thisVar.MdlRefs{ii},'Handle'),...
                    mdlRefCS,thisVar.MdlRefCoderTargetCS(thisVar.MdlRefs{ii}));
                    set_param(thisVar.MdlRefs{ii},'Dirty','off');
                end
            end

            slprivate('close_models',thisVar.ModelsToClose);

            if~isempty(thisVar.ModelName)&&thisVar.SupportsTargetServices
                codertarget.targetservices.SDIIntegration.manageInstance('clear',thisVar.ModelName);
            end
            if~isempty(thisVar.KernelProfilerObj)
                try
                    thisVar.KernelProfilerObj.stop();
                catch e
                    MSLDiagnostic('codertarget:build:ExternalModeCallbackError','Kernel Profiler Stop',char([10,e.message])).reportAsWarning;
                end
            end
        end

        function hardwareName=getHardwareName(h)
            assert(codertarget.target.isCoderTarget(h.ModelName),...
            'model is expected to be configured for coder target!');
            hardwareName=codertarget.data.getParameterValue(...
            getActiveConfigSet(h.ModelName),'TargetHardware');
        end

        function configureExternalModeSettings(thisVar)
            waitbarTitle=...
            DAStudio.message('Simulink:Extmode:OneClickModelConfiguringModelTitle');
            waitbarMsg=...
            DAStudio.message('Simulink:Extmode:OneClickModelConfiguringModelMsg',...
            thisVar.ModelName);
            waitBarH=waitbar(0,waitbarMsg,'Name',waitbarTitle,...
            'Visible','off');




            ax=findall(waitBarH,'Type','Axes');
            htext=get(ax,'Title');
            set(htext,'interpreter','none');


            closeWaitBar=onCleanup(@()close(waitBarH));
            set(waitBarH,'Visible','on');
            waitbar(0.3,waitBarH);



            csname='External Mode Configuration';
            thisVar.CoderTargetCS=getActiveConfigSet(thisVar.ModelName);
            if~ismember(getConfigSets(thisVar.ModelName),csname)
                thisVar.CoderTargetCS.Name=csname;
            end


            set_param(thisVar.CoderTargetCS,'OnTargetWaitForStart','on');



            waitbar(0.6,waitBarH);

            topmdlhw=thisVar.getHardwareName();
            for ii=1:numel(thisVar.MdlRefs)
                if~codertarget.target.supportsCoderTarget(thisVar.MdlRefOrigCS(thisVar.MdlRefs{ii}))
                    DAStudio.error('codertarget:build:ModelRefIncompatibleSTF',thisVar.ModelName,thisVar.MdlRefs{ii});
                else
                    if~codertarget.target.isCoderTarget(thisVar.MdlRefOrigCS(thisVar.MdlRefs{ii}))
                        DAStudio.error('codertarget:build:ModelRefExpectedCoderTarget',thisVar.ModelName,thisVar.MdlRefs{ii},topmdlhw);
                    end
                    refmdlhw=codertarget.data.getParameterValue(...
                    thisVar.MdlRefOrigCS(thisVar.MdlRefs{ii}),'TargetHardware');
                    if~isequal(topmdlhw,refmdlhw)
                        DAStudio.error('codertarget:build:ModelRefDataIncompatible');
                    end
                end
                mdlRefCS=thisVar.MdlRefCoderTargetCS(thisVar.MdlRefs{ii});
                mdlRefCS.Name=csname;
            end


            waitbar(0.7,waitBarH);


            if~isempty(thisVar.ExternalModeInfo.SetupFcn)
                thisVar.locEvalNoOutput(thisVar.ExternalModeInfo.SetupFcn);
            end


            waitbar(0.8,waitBarH);


            thisVar.updateProperties(thisVar.CoderTargetCS);

            for ii=1:numel(thisVar.MdlRefs)

                thisVar.updateProperties(thisVar.MdlRefCoderTargetCS(thisVar.MdlRefs{ii}));

                set_param(thisVar.MdlRefs{ii},'Dirty','off');
            end


            waitbar(1,waitBarH);
            clear closeWaitBar;
            pause(0.01);
        end

        function preExtModeConnectAction(thisVar)
            thisVar.locEvalNoOutput(thisVar.ExternalModeInfo.PreConnectFcn);
        end

        function enableExtMode(thisVar)

            thisVar.configureExternalModeSettings;


            set_param(thisVar.CoderTargetCS,'ExtMode','on');


            thisVar.IsXCP=coder.internal.xcp.isXCPTarget(thisVar.CoderTargetCS);


            if isequal(get_param(thisVar.ModelName,'ExtModeIntrfLevel'),'Level2 - Open')...
                &&~thisVar.IsXCP
                set_param(thisVar.CoderTargetCS,'ExtMode','off');
            end









            isSOC=codertarget.utils.isMdlConfiguredForSoC(thisVar.CoderTargetCS);
            if thisVar.IsXCP&&~isSOC
                codertarget.utils.enableXCPExtModeInterface(thisVar.CoderTargetCS);
            end

            thisVar.SupportsTargetServices=codertarget.targetservices.needsCommService(thisVar.CoderTargetCS);

            isProfile=codertarget.profile.internal.isProfilingEnabled(thisVar.CoderTargetCS);
            useKernel=codertarget.profile.internal.isKernelProfilingEnabled(thisVar.CoderTargetCS);

            if(isProfile&&useKernel)
                thisVar.KernelProfilerObj=...
                soc.profiler.KernelTaskProfiler(thisVar.ModelName);
            end
        end

        function downloadAndRunTargetExecutable(h)%#ok<MANU>


        end

        function visible=areExtModeOptionsVisible(h)%#ok<MANU>
            visible=false;
        end

        function newCS=getTemporaryCSForBuild(this,resolvedOrigCS)%#ok<INUSL>
            newCS=resolvedOrigCS.copy;
            isECUsed=isequal(get_param(newCS,'IsECInUse'),'on');
            isSLCUsed=isequal(get_param(newCS,'IsSLCInUse'),'on');

            slcText='Simulink Coder';
            ecText='Embedded Coder';
            mlText='MATLAB Coder';
            if isECUsed&&isSLCUsed
                if~builtin('license','checkout','MATLAB_Coder')
                    DAStudio.error('codertarget:build:CodersUnavailableError',...
                    mlText,mlText);
                end
                if~builtin('license','checkout','Real-Time_Workshop')
                    DAStudio.error('codertarget:build:CodersUnavailableError',...
                    slcText,slcText);
                end
                if~builtin('license','checkout','RTW_Embedded_Coder')
                    DAStudio.error('codertarget:build:CodersUnavailableError',...
                    ecText,ecText);
                end
            elseif isSLCUsed
                newCS=coder.oneclick.CoderTargetHook.setForSimulinkCoderTarget(newCS);
                if~builtin('license','checkout','MATLAB_Coder')
                    DAStudio.error('codertarget:build:CodersUnavailableError',...
                    mlText,mlText);
                end
                if~builtin('license','checkout','Real-Time_Workshop')
                    DAStudio.error('codertarget:build:CodersUnavailableError',...
                    slcText,slcText);
                end
            else
                newCS=coder.oneclick.CoderTargetHook.setForSimulinkTarget(newCS);
            end
        end



        function onConnectAction(thisVar)
            thisVar.locEvalNoOutput(thisVar.ExternalModeInfo.ConnectFcn);

            if isequal(get_param(thisVar.ModelName,'ExtModeIntrfLevel'),'Level2 - Open')...
                &&~thisVar.IsXCP





                restoreTransport=get_param(bdroot,'ExtModeTransport');
                set_param(bdroot,'ExtMode','on');

                set_param(bdroot,'ExtModeTransport',restoreTransport);
            end
            if thisVar.SupportsTargetServices
                codertarget.targetservices.SDIIntegration.manageInstance('clear',thisVar.CoderTargetCS);

                SDIIntegrationObj=codertarget.targetservices.SDIIntegration.manageInstance('get',thisVar.CoderTargetCS);
                SDIIntegrationObj.startSDI;
            end
            if~isempty(thisVar.KernelProfilerObj)
                try
                    thisVar.KernelProfilerObj.KernelProfilerObj.validate();
                    thisVar.KernelProfilerObj.start();
                catch e
                    MSLDiagnostic('codertarget:build:ExternalModeCallbackError','Kernel Profiler Start',char([10,e.message])).reportAsWarning;
                end
            end
        end



        function connected=extModeConnect(thisVar,varargin)
            onConnectAction(thisVar);
            connected=extModeConnect@coder.oneclick.TargetHook(thisVar,varargin{:});
        end

        function configureReferenceModelsIfNecessary(this)
            topModel=this.ModelName;
            for idx=1:length(this.MdlRefs)
                mdl=this.MdlRefs{idx};

                if~codertarget.target.isCoderTarget(mdl)
                    continue
                end





                if isequal(get_param(mdl,'Dirty'),'on')
                    DAStudio.error('Simulink:slbuild:unsavedMdlRefs',mdl,topModel);
                end

                origCS=getActiveConfigSet(mdl);
                resolvedOrigCS=origCS;
                if isa(resolvedOrigCS,'Simulink.ConfigSetRef')
                    tmpCS=resolvedOrigCS.getResolvedConfigSetCopy;
                    tmpCS=this.getTemporaryCSForBuild(tmpCS);
                else
                    tmpCS=this.getTemporaryCSForBuild(resolvedOrigCS);
                end
                this.MdlRefCoderTargetCS(mdl)=tmpCS;
                slInternal('substituteTmpConfigSetForBuild',...
                get_param(mdl,'Handle'),origCS,tmpCS);
                resolvedOrigCS.lock;

                set_param(mdl,'Dirty','off');
            end
        end
    end

    methods(Access='private')
        function locEvalNoOutput(thisVar,varargin)


            assert(ischar(varargin{:}))
            hObj=thisVar.CoderTargetCS;%#ok<NASGU>
            eval(varargin{:});
        end

        function updateProperties(thisVar,CS)
            transportName=thisVar.ExternalModeInfo.Transport.Name;
            [transportList,~,~]=extmode_transports(CS);


            if(strcmp(transportList,'none'))
                stf=get_param(CS,'SystemTargetFile');
                DAStudio.error('codertarget:build:ExternalModeNotSupported',stf);
            end


            [~,idx1,~]=intersect(transportList,transportName);

            set_param(CS,'ExtModeTransport',idx1-1);
            if~isequal(thisVar.ExternalModeInfo.Transport.Name,'commservice')
                switch(thisVar.ExternalModeInfo.Transport.Type)
                case 'serial'
                    set_param(CS,'ExtModeMexArgs',[codertarget.attributes.getExtModeData('Verbose',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('COMPort',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('Baudrate',thisVar.CoderTargetCS)]);
                case 'tcp/ip'
                    set_param(CS,'ExtModeMexArgs',[codertarget.attributes.getExtModeData('IPAddress',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('Verbose',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('Port',thisVar.CoderTargetCS)]);
                case 'can'
                    set_param(CS,'ExtModeMexArgs',[sprintf('''%s''',codertarget.attributes.getExtModeData('CANVendor',thisVar.CoderTargetCS)),' '...
                    ,sprintf('''%s''',codertarget.attributes.getExtModeData('CANDevice',thisVar.CoderTargetCS)),' '...
                    ,codertarget.attributes.getExtModeData('CANChannel',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('Verbose',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('BusSpeed',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('IsCANIDExtended',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('CANIDCommand',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('IsCANIDExtended',thisVar.CoderTargetCS),' '...
                    ,codertarget.attributes.getExtModeData('CANIDResponse',thisVar.CoderTargetCS)]);
                case 'custom'
                    set_param(CS,'ExtModeMexArgs',codertarget.attributes.getExtModeData('MEXArgs',thisVar.CoderTargetCS));
                end
            else
                set_param(CS,'ExtModeMexArgs',['''',thisVar.ModelName,'''',' ',codertarget.attributes.getExtModeData('Verbose',CS)]);
            end


            modelParamsToChange=thisVar.ExternalModeInfo.ModelParameter;
            coderTargetParamsToChange=thisVar.ExternalModeInfo.CoderTargetParameter;
            coderTargetData=codertarget.data.getData(CS);
            for jj=1:numel(modelParamsToChange)

                if~isempty(modelParamsToChange(jj).callback)
                    try
                        newValue=codertarget.utils.replaceTokens(CS,modelParamsToChange(jj).callback,thisVar.TargetInfo.Tokens);
                        newValue=coder.oneclick.CoderTargetHook.locEvalOneOutput(newValue,CS);
                    catch e
                        DAStudio.error('codertarget:build:ExternalModePropertyCallbackError',modelParamsToChange(jj).name,char([10,e.message]));
                    end
                else
                    newValue=modelParamsToChange(jj).value;
                    newValue=codertarget.utils.replaceTokens(CS,newValue,thisVar.TargetInfo.Tokens);
                end

                if(CS.isValidParam(modelParamsToChange(jj).name))
                    set_param(CS,modelParamsToChange(jj).name,newValue);
                else
                    MSLDiagnostic('codertarget:build:ExternalModePropertyNotAvailable',modelParamsToChange(jj).name).reportAsWarning;
                end
            end


            for jj=1:numel(coderTargetParamsToChange)
                if~isempty(coderTargetParamsToChange(jj).callback)
                    try
                        newValue=coder.oneclick.CoderTargetHook.locEvalOneOutput(coderTargetParamsToChange(jj).callback,CS);
                    catch e
                        DAStudio.error('codertarget:build:ExternalModePropertyCallbackError',coderTargetParamsToChange(jj).name,char([10,e.message]));
                    end
                else
                    newValue=coderTargetParamsToChange(jj).value;
                end
                fieldName=regexp(coderTargetParamsToChange(jj).name,'(\w+)\.(.*)','tokens');
                assert(isfield(coderTargetData,fieldName{1}{1}),DAStudio.message('codertarget:build:ExternalModePropertyNotAvailable',coderTargetParamsToChange(jj).name));
                assert(isfield(coderTargetData.(fieldName{1}{1}),fieldName{1}{2}),DAStudio.message('codertarget:build:ExternalModePropertyNotAvailable',coderTargetParamsToChange(jj).name));
                coderTargetData.(fieldName{1}{1}).(fieldName{1}{2})=codertarget.utils.replaceTokens(CS,newValue,thisVar.TargetInfo.Tokens);
                codertarget.data.setData(CS,coderTargetData);
            end







            isSLCUsed=isequal(get_param(CS,'IsSLCInUse'),'on');
            if~isSLCUsed
                set_param(CS,'MangleLength','10');
            end











            codertarget.data.setParameterValue(CS,'ExtMode.Running','on');
        end
    end

    methods(Access='private',Static)
        function out=locEvalOneOutput(varargin)


            assert(ischar(varargin{1}));
            out=feval(varargin{1},varargin{2:end});
        end

        function hCS=setForSimulinkTarget(hCS)

            targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
            if targetInfo.getNeedsMainFcn
                csParameterSettings=...
                {
                'ERTSrcFileBannerTemplate','codertarget_code_template.cgt';
                'ERTHdrFileBannerTemplate','codertarget_code_template.cgt';
                'ERTDataSrcFileTemplate','codertarget_code_template.cgt';
                'ERTDataHdrFileTemplate','codertarget_code_template.cgt';
                'GenerateSampleERTMain','off';
                'TargetOS','BareBoardExample';
                'ProdEqTarget','on';
                'RTWVerbose','off';
                'CombineOutputUpdateFcns','on';
                'MatFileLogging','off';
                'GenerateASAP2','off';
                'CreateSILPILBlock','None';
                'EnableUserReplacementTypes','off';
                'IncludeFileDelimiter','Auto';
                'EnableDataOwnership','off';
                'ERTFilePackagingFormat','Modular';
                'GenerateReport','off';
                'IgnoreCustomStorageClasses','on';
                'TLCDebug','off';
                'TLCCoverage','off';
                'TLCAssert','off';
                'PortableWordSizes','off';
                };
            else

                csParameterSettings=...
                {
                'ERTSrcFileBannerTemplate','codertarget_code_template.cgt';
                'ERTHdrFileBannerTemplate','codertarget_code_template.cgt';
                'ERTDataSrcFileTemplate','codertarget_code_template.cgt';
                'ERTDataHdrFileTemplate','codertarget_code_template.cgt';
                'GenerateSampleERTMain','off';
                'TargetOS','BareBoardExample';
                'ProdEqTarget','off';
                'RTWVerbose','off';
                'CombineOutputUpdateFcns','off';
                'MatFileLogging','off';
                'GenerateASAP2','off';
                'CreateSILPILBlock','None';
                'EnableUserReplacementTypes','off';
                'IncludeFileDelimiter','Auto';
                'EnableDataOwnership','off';
                'ERTFilePackagingFormat','Modular';
                'GenerateReport','off';
                'IgnoreCustomStorageClasses','on';
                'TLCDebug','off';
                'TLCCoverage','off';
                'TLCAssert','off';
                'PortableWordSizes','off';
                };
            end
            for i=1:length(csParameterSettings)
                if~isequal(get_param(hCS,csParameterSettings{i,1}),csParameterSettings{i,2})
                    set_param(hCS,csParameterSettings{i,1},csParameterSettings{i,2});
                end
            end
        end

        function hCS=setForSimulinkCoderTarget(hCS)
            set_param(hCS,'ERTSrcFileBannerTemplate','codertarget_code_template.cgt');
            set_param(hCS,'ERTHdrFileBannerTemplate','codertarget_code_template.cgt');
            set_param(hCS,'ERTDataSrcFileTemplate','codertarget_code_template.cgt');
            set_param(hCS,'ERTDataHdrFileTemplate','codertarget_code_template.cgt');
            set_param(hCS,'IgnoreCustomStorageClasses','on');
            set_param(hCS,'PortableWordSizes','off');
        end
    end
end

