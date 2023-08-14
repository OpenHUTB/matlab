



classdef(Sealed)PLCCGMgr<handle
    properties(Constant)

        PLC_PLUGIN_CG_CALLBACK_EMPTY='plc_cg_callback_empty'
    end

    properties(Hidden,Constant,Access=private)
        Uninitialized=0;
        Initialized=1;
    end

    properties(Hidden,Access=private)
        fMATLABCodegen;
        fIDEList;
        fState=PLCCoder.PLCCGMgr.Uninitialized;
        fSubsysH;
        fModelH;
        fSubsysName;
        fMdlName;
        fMdlOption;
        fTargetIDE;
        fS7SinglePrecision;
        fExtractModelH;
        fExtractModelName;
        fVarDescMap;
        fMaxNameLengthGeneric=36;
        fSigSourceInfo;
        fTBVectors;
        fTBCycleCounts;
        fProcessTB;
        fIsTopMatlabFcnBlock;
        fHasError;
        fError;
        fGetParamInfo;
        fTunableParamList;
        fGenerateLadderLogic;
        fSubsysPath;
        fPLCInstrumentMgr;
        fPLCInstrumentGlobalName;
        fOutputDir;
        fReportGUIMsg;
        fErrorCount;
        fErrorMessages;
        fLadderDoc;
        fUseDataDictionary;
        fPLCDataMgr;
        fStringTypeCustomOption;
        fStringTypeCustomName;
        fAutoTypeConversionMap;
        fAutoTypeConversionReportThrown;

        fExternBlockPaths;
        fExternFunctionBlockPaths;

        fExternBlockFcns;
        fTypeDescMap;
        fBusTypeList;
    end

    methods(Static)
        function instance=getInstance
            mlock;
            persistent gInstance;
            if isempty(gInstance)||~isvalid(gInstance)
                gInstance=PLCCoder.PLCCGMgr;
            end
            instance=gInstance;
        end

        function flag=getFeatureUseCGConfig
            flag=plcmex('getUseCGConfig');
        end

        function old_val=setFeatureUseCGConfig(val)
            old_val=PLCCoder.PLCCGMgr.getFeatureUseCGConfig;
            if(val)
                plcmex('setUseCGConfig',1);
            else
                PLCCoder.PLCCGMgr.setFeatureTestCGConfig(0);
                plcmex('setUseCGConfig',0);
            end
        end

        function flag=getFeatureTestCGConfig
            flag=plcmex('getTestCGConfig');
        end

        function old_val=setFeatureTestCGConfig(val)
            old_val=PLCCoder.PLCCGMgr.getFeatureTestCGConfig;
            if(val)
                PLCCoder.PLCCGMgr.setFeatureUseCGConfig(1);
                plcmex('setTestCGConfig',1);
            else
                plcmex('setTestCGConfig',0);
            end
        end

        function resetPLCCG
            plcmex('resetPLCCGMgr');
            PLCCoder.PLCCGMgr.getInstance.resetCustomIDEList;
        end

        function dump
            fprintf(1,'-----PLCCGMgr Feature\n');
            fprintf(1,'\tFeature UseCGConfig: %d\n',PLCCoder.PLCCGMgr.getFeatureUseCGConfig);
            fprintf(1,'\tFeature TestCGConfig: %d\n',PLCCoder.PLCCGMgr.getFeatureTestCGConfig);
        end

        function flag=isBuiltInTarget(name)
            flag=strcmp(name,'codesys23')||strcmp(name,'codesys33')||strcmp(name,'codesys35')...
            ||strcmp(name,'brautomation30')||strcmp(name,'brautomation40')...
            ||strcmp(name,'twincat211')||strcmp(name,'twincat3')...
            ||strcmp(name,'multiprog50')||strcmp(name,'pcworx60')...
            ||strcmp(name,'rslogix5000')||strcmp(name,'rslogix5000_routine')...
            ||strcmp(name,'studio5000')||strcmp(name,'studio5000_routine')...
            ||strcmp(name,'step7')...
            ||strcmp(name,'tiaportal')||strcmp(name,'tiaportal_double');
        end

        function flag=isCustomTarget(name)
            flag=~PLCCoder.PLCCGMgr.isBuiltInTarget(name);
        end

        function flag=isSLSignalTarget(name)
            flag=~(strcmp(name,'brautomation30')||strcmp(name,'brautomation40'));
        end

        function ret=getSubsystemName()
            ret=getfullname(PLCCoder.PLCCGMgr.getInstance.fSubsysH);
        end
    end

    methods
        function startCG(obj,subsysH,generateLadderLogic)
            obj.fMATLABCodegen=false;
            obj.fHasError=false;
            obj.fError='';
            obj.fState=PLCCoder.PLCCGMgr.Initialized;
            obj.fSubsysH=subsysH;
            obj.fModelH=bdroot(obj.fSubsysH);
            obj.fSubsysName=getfullname(obj.fSubsysH);
            obj.fMdlName=get_param(obj.fModelH,'Name');
            obj.fMdlOption=plcprivate('plc_options',obj.fSubsysH);
            obj.fTargetIDE=obj.fMdlOption.TargetIDE;
            obj.fS7SinglePrecision=strcmp(obj.fTargetIDE,'step7')||strcmp(obj.fTargetIDE,'tiaportal');
            obj.fVarDescMap=containers.Map();
            obj.fAutoTypeConversionMap=containers.Map();
            obj.fAutoTypeConversionReportThrown=false;
            obj.setMaxNameLengthGeneric(obj.fMdlOption.RTWMaxIdLength);
            obj.checkSigSourceInfo;
            obj.fTBVectors={};
            obj.fTBCycleCounts=[];
            obj.fProcessTB=true;
            obj.fIsTopMatlabFcnBlock=false;
            obj.checkTopMatlabFcnBlock;
            obj.fGetParamInfo=true;
            obj.fGenerateLadderLogic=generateLadderLogic;
            obj.fSubsysPath=getfullname(subsysH);
            obj.fPLCInstrumentMgr=PLCCoder.PLCInstrumentMgr(obj);
            if strcmp(obj.fMdlOption.ReuseMLFcnVariable,'on')
                PLCCoder.PLCUtils.varReuseOn;
            else
                PLCCoder.PLCUtils.varReuseOff;
            end
            obj.resetErrorCount;
            obj.fUseDataDictionary=false;
            obj.fPLCDataMgr=[];
            if~isempty(get_param(obj.fModelH,'DataDictionary'))
                obj.fUseDataDictionary=true;
                obj.fPLCDataMgr=PLCCoder.PLCDataMgr(obj);
            end
            obj.setStringTypeCustomOption;



            import plccoder.modeladvisor.helpers.getExternallyDefinedBlockPaths
            obj.fExternBlockPaths=getExternallyDefinedBlockPaths(obj.fModelH);
            obj.fExternFunctionBlockPaths=plcprivate('plc_get_external_fb',obj.fModelH);

            obj.fExternBlockFcns={};


            obj.buildTypeDescMap;
        end

        function startCG_Matlab(obj,cfg)
            obj.fMATLABCodegen=true;
            obj.fHasError=false;
            obj.fError='';
            obj.fState=PLCCoder.PLCCGMgr.Initialized;
            obj.fSubsysH=-1.0;
            obj.fModelH=-1.0;
            obj.fSubsysName='';
            obj.fMdlName='';
            if cfg.GenerateTestbench
                obj.fMdlOption.GenerateTestbench='on';
                obj.fMdlOption.GenerateTestbenchDiagCode='off';
            else
                obj.fMdlOption=[];
            end

            obj.fTargetIDE=cfg.PLCTargetIDE;
            obj.fS7SinglePrecision=strcmp(obj.fTargetIDE,'step7')||strcmp(obj.fTargetIDE,'tiaportal');
            obj.fVarDescMap=containers.Map();
            obj.fAutoTypeConversionMap=containers.Map();
            obj.fAutoTypeConversionReportThrown=false;
            obj.setMaxNameLengthGeneric(24);
            if cfg.GenerateTestbench
                obj.fMdlOption.GenerateTestbench='on';
            else
                obj.fMdlOption.GenerateTestbench='off';
            end
            obj.fTBVectors={};

            obj.fTBCycleCounts=[];
            obj.fProcessTB=false;
            obj.fIsTopMatlabFcnBlock=false;
            obj.fGetParamInfo=false;
            obj.fGenerateLadderLogic=false;
            obj.fSubsysPath='';
            obj.fPLCInstrumentMgr=[];
            PLCCoder.PLCUtils.varReuseOff;
            obj.resetErrorCount;
            obj.fUseDataDictionary=false;
            obj.fPLCDataMgr=[];
            obj.setStringTypeCustomOption;
            obj.fOutputDir='.';
            obj.fExternBlockFcns={};



        end

        function ret=codingMATLAB(obj)
            ret=obj.fMATLABCodegen;
        end

        function cfg=getCGConfig(obj)
            assert(obj.fState==PLCCoder.PLCCGMgr.Initialized);
            cfg=PLCCoder.PLCCGConfig.getCGConfig(obj.fTargetIDE);
        end

        function addExternBlockFcn(obj,fcnName)


            if isempty(obj.fExternBlockFcns)
                obj.fExternBlockFcns={fcnName};
            else
                obj.fExternBlockFcns=[obj.fExternBlockFcns,fcnName];
            end
        end

        function out=getExternBlockFcns(obj)



            out=obj.fExternBlockFcns;
        end

        function out=getExternBlockPaths(obj)



            out=obj.fExternBlockPaths;
        end

        function out=getExternFunctionBlockPaths(obj)
            out=obj.fExternFunctionBlockPaths;
        end

        function info=getCGIDEInfo(obj)
            assert(obj.fState==PLCCoder.PLCCGMgr.Initialized);
            assert(PLCCoder.PLCCGMgr.isCustomTarget(obj.fTargetIDE)||obj.isRockwellTarget);
            if(strcmp(obj.fTargetIDE,'generic')||strcmp(obj.fTargetIDE,'plcopen'))
                info=[];
            else
                info=obj.getCustomIDEInfo(obj.fTargetIDE);
            end
        end

        function ret=isTextTarget(obj)
            assert(obj.fState==PLCCoder.PLCCGMgr.Initialized);
            target=obj.fTargetIDE;
            if PLCCoder.PLCCGMgr.isCustomTarget(target)
                if strcmp(target,'generic')
                    ret=true;
                    return;
                end
                if strcmp(target,'plcopen')
                    ret=false;
                    return;
                end
                ide_info=obj.getCGIDEInfo;
                assert(~isempty(ide_info));
                assert(isfield(ide_info,'format'));
                if(strcmp(ide_info.format,'generic'))
                    ret=true;
                else
                    assert(strcmp(ide_info.format,'xml'));
                    ret=false;
                end
                return;
            end
            ret=strcmp(target,'codesys23')...
            ||strcmp(target,'twincat211')...
            ||strcmp(target,'step7')...
            ||strcmp(target,'tiaportal')||strcmp(target,'tiaportal_double');
        end

        function version=getPluginVersion(obj)
            assert(obj.fState==PLCCoder.PLCCGMgr.Initialized);
            assert(PLCCoder.PLCCGMgr.isCustomTarget(obj.fTargetIDE));
            if(strcmp(obj.fTargetIDE,'generic')||strcmp(obj.fTargetIDE,'plcopen'))
                version=0;
            else
                info=obj.getCustomIDEInfo(obj.fTargetIDE);
                version=info.pluginVersion;
            end
        end

        function version=getCompatibleBuildVersion(obj)
            assert(obj.fState==PLCCoder.PLCCGMgr.Initialized);
            assert(PLCCoder.PLCCGMgr.isCustomTarget(obj.fTargetIDE));
            if(strcmp(obj.fTargetIDE,'generic')||strcmp(obj.fTargetIDE,'plcopen'))
                version=0;
            else
                info=obj.getCustomIDEInfo(obj.fTargetIDE);
                version=info.compatibleBuildVersion;
            end
        end

        function target=getTargetIDE(obj)
            target=obj.fTargetIDE;
        end

        function targetStr=getTargetIDEString(obj)
            target=obj.fTargetIDE;
            targetStr=plcprivate('plc_targetide_strings','code2string',target);
        end

        function desc=getSubsystemDesc(obj)
            desc=get_param(obj.fSubsysH,'Description');
        end

        function printStatus(obj)
            fprintf(1,'-----PLCCGMgr status:\n');
            fprintf(1,'\tfState: %d\n',obj.fState);
            fprintf(1,'\tfSubsysH: %f\n',obj.fSubsysH);
            fprintf(1,'\tfModelH: %f\n',obj.fModelH);
            fprintf(1,'\tfSubsysName: %s\n',obj.fSubsysName);
            fprintf(1,'\tfMdlName: %s\n',obj.fMdlName);
            fprintf(1,'\tfTargetIDE: %s\n',obj.fTargetIDE);
        end

        function ide_map=getCustomIDEMap(obj)
            ide_map={};
            for i=1:length(obj.fIDEList)
                ide_info=obj.fIDEList(i);
                ide_name=ide_info.name;
                if(strcmp(ide_info.format,'generic'))
                    ide_emitter='plc_emit_code_generic';
                else
                    assert(strcmp(ide_info.format,'xml'));
                    ide_emitter='plc_emit_code_plcopen';
                end
                if(~strcmp(ide_name,'generic')&&...
                    ~strcmp(ide_name,'plcopen'))
                    item={ide_name,ide_info.description,ide_emitter,false};
                    ide_map=vertcat(ide_map,item);%#ok<AGROW>
                end
            end
        end

        function ide_path_list=getCustomIDEPathList(obj)
            ide_path_list={};
            for i=1:length(obj.fIDEList)
                ide_info=obj.fIDEList(i);
                ide_name=ide_info.name;
                ide_path=ide_info.path;
                if(~strcmp(ide_name,'generic')&&...
                    ~strcmp(ide_name,'plcopen'))
                    item={ide_name,ide_path};
                    ide_path_list=vertcat(ide_path_list,item);%#ok<AGROW>
                end
            end
        end

        function found=isCustomPluginInstalled(obj,name)
            if(strcmp(name,'generic')||strcmp(name,'plcopen'))
                found=true;
                return;
            end
            found=false;
            for i=1:length(obj.fIDEList)
                ide_info=obj.fIDEList(i);
                ide_name=ide_info.name;
                if(strcmp(ide_name,name))
                    found=true;
                    break;
                end
            end
        end

        function info=getCustomIDEInfo(obj,name)
            found=false;
            for i=1:length(obj.fIDEList)
                ide_info=obj.fIDEList(i);
                ide_name=ide_info.name;
                if(strcmp(ide_name,name))
                    info=ide_info;
                    found=true;
                    break;
                end
            end
            assert(found);
        end

        function cfg=getCustomConfig(obj,name)
            ide_info=obj.getCustomIDEInfo(name);
            cfg=ide_info.cfg;
        end

        function resetCustomIDEList(obj)

            custom_fun_name='plc_custom_ide';
            custom_file_paths=which('-all',custom_fun_name);
            paths={};


            for i=length(custom_file_paths):-1:1
                paths{end+1}=fileparts(custom_file_paths{i});%#ok<AGROW>
            end

            funcs={};
            for i=length(custom_file_paths):-1:1
                funcs{end+1}=builtin('_GetFunctionHandleForFullpath',custom_file_paths{i});%#ok<AGROW>
            end



            obj.fIDEList=[];
            for i=1:length(funcs)
                try
                    ideInfo=feval(funcs{i});
                    for j=1:length(ideInfo)
                        addInfoToCustomIDEList(obj,ideInfo(j),i,paths);
                    end
                catch ME
                    fprintf('The following error occurred while evaluating  "%s" for initial registration with Simulink PLC Coder plugin infrastructure.\n',paths{i});
                    disp(ME.message);
                end
            end




            if ispref('SimulinkPLCCoder','plctargetidepaths')
                try
                    obj.addPLCIDEPathPref();
                catch ME
                    disp(ME);
                end
            end
        end

        function addPLCIDEPathPref(obj)
            for i=1:length(obj.fIDEList)
                ideInfo=obj.fIDEList(i);
                plcIDEPathPref=getpref('SimulinkPLCCoder','plctargetidepaths');
                plcIDEPathPref.(ideInfo.name)=ideInfo.path;
                setpref('SimulinkPLCCoder','plctargetidepaths',plcIDEPathPref);
            end
        end

        function addInfoToCustomIDEList(obj,ideInfo,ideInfoIndex,paths)
            oldIDEInfoIndex=[];
            for i=1:length(obj.fIDEList)
                if strcmp(obj.fIDEList(i).name,ideInfo.name)
                    oldIDEInfoIndex=i;
                    break;
                end
            end
            if isempty(oldIDEInfoIndex)
                obj.fIDEList=[obj.fIDEList,ideInfo];
                return;
            else
                oldIDEInfo=obj.fIDEList(oldIDEInfoIndex);
                if oldIDEInfo.pluginVersion<ideInfo.pluginVersion

                    oldPath=paths{oldIDEInfoIndex};
                    newPath=paths{ideInfoIndex};
                    fprintf('Older version of the Simulink PLC Coder plugin "%s" shadows the newer version at "%s"\n',oldPath,newPath);
                end
                obj.fIDEList(oldIDEInfoIndex)=ideInfo;
            end
        end

        function ts_list=getTsList(obj)
            mdl_obj=get_param(obj.fExtractModelH,'Object');
            ts_list=mdl_obj.getSampleTimeValues();
            if~isempty(ts_list)&&ts_list(1)==0




                ts_list(1)=[];
            end
        end

        function setExtractModel(obj,mdlh)
            obj.fExtractModelH=mdlh;
            obj.fExtractModelName=get_param(obj.fExtractModelH,'Name');
        end

        function modelH=getExtractModel(obj)
            modelH=obj.fExtractModelH;
        end

        function modelName=getModelName(obj)
            modelName=obj.fMdlName;
        end

        function modelName=getExtractModelName(obj)
            modelName=obj.fExtractModelName;
        end

        function ret=hasVarDesc(obj,var)
            ret=obj.fVarDescMap.isKey(var);
        end

        function desc=getVarDesc(obj,var)
            assert(obj.hasVarDesc(var),'Error: undefined var name');
            desc=obj.fVarDescMap(var);
        end

        function setVarDesc(obj,var,desc)
            if(obj.hasVarDesc(var))
                assert(strcmp(obj.getVarDesc(var),desc),'Error: redefined var name');
            else
                obj.fVarDescMap(var)=desc;
            end
        end

        function ret=hasVarDescList(obj)
            ret=~isempty(obj.fVarDescMap);
        end

        function tf=autoTypeConversionReportThrown(obj)
            tf=obj.fAutoTypeConversionReportThrown;
        end

        function setAutoTypeConversionReportThrown(obj,tf)
            obj.fAutoTypeConversionReportThrown=tf;
        end

        function ret=hasConvertedType(obj,typeName)
            ret=obj.fAutoTypeConversionMap.isKey(typeName);
        end

        function desc=getConvertedType(obj,typeName)
            assert(obj.hasConvertedType(typeName),'Error: undefined type name');
            desc=obj.fAutoTypeConversionMap(typeName);
        end

        function setConvertedType(obj,typeName,convertToType)
            if(obj.hasConvertedType(typeName))
                assert(strcmp(obj.fAutoTypeConversionMap(typeName),convertToType),'Error: redefined type name');
            else
                obj.fAutoTypeConversionMap(typeName)=convertToType;
            end
        end

        function desc=getAllConvertedTypes(obj)
            if obj.hasTypeConversions
                desc=cell(1,obj.fAutoTypeConversionMap.length);
                fromTypes=obj.fAutoTypeConversionMap.keys;
                for idx=1:obj.fAutoTypeConversionMap.length
                    typeName=fromTypes{idx};
                    convertType=obj.getConvertedType(typeName);
                    desc{idx}=[typeName,'->',convertType];
                end
                desc=strjoin(desc,',');
            else
                desc='';
            end
        end

        function ret=hasTypeConversions(obj)
            ret=~isempty(obj.fAutoTypeConversionMap);
        end

        function ret=supportEnumValueOption(obj)
            ret=false;
            target=obj.fTargetIDE;
            if PLCCoder.PLCCGMgr.isCustomTarget(target)||...
                strcmp(target,'codesys23')||...
                strcmp(target,'codesys33')||...
                strcmp(target,'codesys35')
                ret=true;
            end
        end

        function ret=isRandFcnSupported(obj)
            ret=false;
            target=obj.fTargetIDE;
            if PLCCoder.PLCCGMgr.isCustomTarget(target)||...
                strcmp(target,'brautomation30')||...
                strcmp(target,'brautomation40')||...
                strcmp(target,'codesys23')||...
                strcmp(target,'codesys33')||...
                strcmp(target,'codesys35')||...
                strcmp(target,'twincat211')||...
                strcmp(target,'twincat3')
                ret=true;
            end
        end

        function ret=isStudio5000Target(obj)
            ret=strcmp(obj.fTargetIDE,'studio5000')||strcmp(obj.fTargetIDE,'studio5000_routine');
        end

        function ret=isRockwellTarget(obj)
            ret=strcmp(obj.fTargetIDE,'studio5000')||strcmp(obj.fTargetIDE,'studio5000_routine')...
            ||strcmp(obj.fTargetIDE,'rslogix5000')||strcmp(obj.fTargetIDE,'rslogix5000_routine');
        end

        function ret=isRoutineTarget(obj)
            ret=strcmp(obj.fTargetIDE,'rslogix5000_routine')||strcmp(obj.fTargetIDE,'studio5000_routine');
        end

        function ret=isSelectronTarget(obj)
            ret=strcmp(obj.fTargetIDE,'selectron');
        end

        function tf=isOmronTarget(obj)
            tf=strcmp(obj.fTargetIDE,'omron');
        end

        function tf=isStep7Target(obj)
            tf=strcmp(obj.fTargetIDE,'step7');
        end

        function tf=isTiaPortalTarget(obj)
            tf=strcmp(obj.fTargetIDE,'tiaportal')||strcmp(obj.fTargetIDE,'tiaportal_double');
        end

        function ret=isPLCLogging(obj)
            ret=false;
            if~plcfeature('PLCLogging')
                return;
            end
            if obj.getGenerateLadderLogic
                return;
            end
            if(~strcmp(obj.fMdlOption.GenerateLoggingCode,'on'))
                return;
            end
            target=obj.fTargetIDE;
            if strcmp(target,'codesys23')||...
                strcmp(target,'codesys35')||...
                strcmp(target,'rslogix5000')||...
                strcmp(target,'studio5000')||...
                strcmp(target,'twincat211')||...
                strcmp(target,'twincat3')||...
                PLCCoder.PLCCGMgr.isCustomTarget(obj.fTargetIDE)
                ret=true;
            end
        end

        function ret=runSFAnimation(obj)%#ok<MANU>
            ret=false;
            if~plcfeature('PLCSFAnimation')
                return;
            end

            ret=true;
        end

        function ret=getEnumValueOption(obj)
            cfg=obj.getCGConfig;
            if~isempty(cfg)&&isfield(cfg,'fEmitEnumTypeIntegerValue')
                ret=cfg.fEmitEnumTypeIntegerValue;
                return;
            end

            ret=false;
            enum_pref=plccoderpref('plcemitenumvalue');
            if enum_pref&&obj.supportEnumValueOption
                ret=true;
            end
        end

        function name_length=getMaxNameLengthGeneric(obj)
            name_length=obj.fMaxNameLengthGeneric;
        end

        function setMaxNameLengthGeneric(obj,name_length)
            obj.fMaxNameLengthGeneric=name_length;
        end

        function ret=getArrayInitValueBrackets(obj)
            ret=false;
            cfg=obj.getCGConfig;
            if~isempty(cfg)&&isfield(cfg,'fArrayInitialValueBrackets')
                ret=cfg.fArrayInitialValueBrackets;
            end
        end

        function ret=getS7SinglePrecision(obj)
            ret=obj.fS7SinglePrecision;
        end

        function ret=supportIECStdTimer(obj)
            ret=false;
            target=obj.fTargetIDE;
            if PLCCoder.PLCCGMgr.isCustomTarget(target)||...
                strcmp(target,'brautomation30')||...
                strcmp(target,'brautomation40')||...
                strcmp(target,'codesys23')||...
                strcmp(target,'codesys33')||...
                strcmp(target,'codesys35')||...
                strcmp(target,'twincat211')||...
                strcmp(target,'twincat3')||...
                strcmp(target,'multiprog50')||...
                strcmp(target,'pcworx60')||...
                strcmp(target,'step7')||...
                strcmp(target,'tiaportal')||...
                strcmp(target,'tiaportal_double')
                ret=true;
            end
        end

        function ret=supportMultiTB(obj)%#ok<MANU>
            ret=true;
        end

        function ret=hasTB(obj)
            ret=strcmp(obj.fMdlOption.GenerateTestbench,'on');
        end

        function ret=hasMultiTB(obj)
            assert(obj.hasTB,'Error: Testbench not selected');
            ret=plcfeature('PLCMultiTB')&&obj.supportMultiTB&&~isempty(obj.fSigSourceInfo);
        end

        function ret=getNumTB(obj)
            assert(obj.hasMultiTB,'Error: Testbench not selected');
            ret=obj.fSigSourceInfo.getNumSigGroup;
        end

        function ret=getSigSourceInfo(obj)
            assert(obj.hasMultiTB,'Error: Testbench not selected');
            ret=obj.fSigSourceInfo;
        end

        function ret=getTBVectors(obj)
            if obj.fProcessTB
                obj.processTBVectors;
                obj.fProcessTB=false;
            end
            ret=obj.fTBVectors;
        end

        function appendTBVectors(obj,tb_vectors)
            obj.fTBVectors{end+1}=tb_vectors;
        end

        function appendTBCycleCount(obj,tb_cyclecount)
            obj.fTBCycleCounts(end+1)=tb_cyclecount;
        end

        function processTBVectors(obj)

            for i=1:length(obj.fTBVectors)
                obj.fTBCycleCounts(i)=obj.fTBVectors{i}.numTimeSteps;
            end
            assert(~isempty(obj.fTBVectors));
            plcprivate('plc_test_cycle_count','set',obj.fTBVectors{end}.numTimeSteps);
        end

        function clearTBVectors(obj)
            obj.fTBVectors={};
        end

        function ret=getTBCycleCount(obj,idx)
            ret=obj.fTBCycleCounts(idx);
        end

        function ret=isMultiTBSigbuilderTimeRange(obj)
            ret=strcmp(obj.fMdlOption.MultiTBSigbuilderTimeRange,'on');
        end

        function ret=getPreserveAliasType(obj)
            ret=strcmp(obj.fMdlOption.PreserveAliasType,'on');
        end

        function ret=isTopMatlabFcnBlock(obj)
            ret=obj.fIsTopMatlabFcnBlock;
        end

        function reportError(obj,err_msg)
            assert(~obj.fHasError);
            obj.fHasError=true;
            obj.fError=err_msg;
        end

        function ret=hasError(obj)
            ret=obj.fHasError;
        end

        function ret=getError(obj)
            ret=obj.fError;
        end

        function ret=PLCInstrument(obj)%#ok<MANU>
            if(plcfeature('PLCInstrument'))
                ret=true;
            else
                ret=false;
            end
        end

        function ret=isGenerateReusableCode(obj)
            ret=strcmp(obj.fMdlOption.GenerateReusableCode,'on');
        end

        function ret=isInlineParam(obj)
            param_opt=get_param(obj.fExtractModelH,'RTWInlineParameters');
            ret=strcmp(param_opt,'on');
        end

        function ret=getTunableParamList(obj)
            ret=obj.fTunableParamList;
        end

        function ret=getTunableParamNames(obj)
            if(obj.fGetParamInfo)
                obj.fGetParamInfo=false;
                obj.fTunableParamList=plcprivate('plc_get_tunable_params',obj.fMdlName,obj.fTargetIDE);
            end
            ret=cellfun(@(param)(param.name),obj.fTunableParamList,'UniformOutput',false);
        end

        function ret=getGenerateLadderLogic(obj)
            ret=obj.fGenerateLadderLogic;
        end

        function ret=getSubsysPath(obj)
            ret=obj.fSubsysPath;
        end

        function ret=mapBlockPath(obj,blockH,varargin)
            if isnumeric(blockH)
                blk_path=getfullname(blockH);
            else
                blk_path=blockH;
            end

            if nargin>=3
                checkExists=varargin{1};
            else
                checkExists=true;
            end
            orig_blk_path=regexprep(blk_path,obj.fExtractModelName,obj.fMdlName,'once');
            if checkExists&&getSimulinkBlockHandle(orig_blk_path)==-1
                orig_blk_path=regexprep(blk_path,obj.fExtractModelName,obj.fSubsysPath,'once');
            end
            ret=orig_blk_path;
        end

        function ret=mapSubstemBlockPath(obj,blockH,varargin)


            if isnumeric(blockH)
                blk_path=getfullname(blockH);
            else
                blk_path=blockH;
            end

            orig_blk_path=regexprep(blk_path,obj.fExtractModelName,obj.fSubsysPath,'once');
            ret=orig_blk_path;
        end

        function ret=mapBlockHandle(obj,blockH)
            orig_blk_path=obj.mapBlockPath(blockH);
            ret=get_param(orig_blk_path,'handle');
        end

        function ret=isTopSubsystemBlock(obj,blockH)
            ret=blockH==obj.fExtractModelH;
        end

        function ret=checkStateflowChartExecuteAtInit(obj)
            ret=false;
            rt=sfroot;
            m=rt.find('-isa','Stateflow.Machine','Name',obj.fMdlName);
            ch=[];
            if~isempty(m)
                ch=m.find('-isa','Stateflow.Chart');
            end

            for i=1:numel(ch)
                if ch(i).ExecuteAtInitialization
                    ret=true;
                    return;
                end
            end
        end

        function ret=supportInitCallOpt(obj)
            ret=false;
            if obj.checkStateflowChartExecuteAtInit
                return;
            end
            target=obj.fTargetIDE;
            if PLCCoder.PLCCGMgr.isCustomTarget(target)||...
                strcmp(target,'brautomation30')||...
                strcmp(target,'brautomation40')||...
                strcmp(target,'codesys23')||...
                strcmp(target,'codesys33')||...
                strcmp(target,'codesys35')||...
                strcmp(target,'twincat211')||...
                strcmp(target,'twincat3')||...
                strcmp(target,'multiprog50')||...
                strcmp(target,'pcworx60')||...
                strcmp(target,'step7')||...
                strcmp(target,'tiaportal')||...
                strcmp(target,'tiaportal_double')
                ret=true;
            end
        end

        function ret=supportInOutVar(obj)
            ret=true;
            target=obj.fTargetIDE;
            if strcmp(target,'rslogix5000_routine')||...
                strcmp(target,'studio5000_routine')
                ret=false;
            end
        end

        function ret=supportAggregateTypeInOutVar(obj)
            ret=obj.supportInOutVar;
            target=obj.fTargetIDE;
            if strcmp(target,'multiprog50')||...
                strcmp(target,'pcworx60')
                ret=false;
            end
        end

        function ret=getModelID(obj,mdl_name)
            ret=obj.fPLCInstrumentMgr.getModelID(mdl_name);
        end

        function ret=getInstrumentData(obj)
            ret=obj.fPLCInstrumentMgr.getInstrumentData;
        end

        function ret=getPLCInstrumentGlobalName(obj)
            ret=obj.fPLCInstrumentGlobalName;
        end

        function setPLCInstrumentGlobalName(obj,name)
            obj.fPLCInstrumentGlobalName=name;
        end

        function ret=useInstanceName(obj)
            ret=false;
            if(~obj.isRoutineTarget&&plcfeature('PLCUseInstanceName'))
                ret=strcmp(obj.fMdlOption.FBUseSubsystemInstanceName,'on');
            end
        end

        function ret=isEarlyBinding(obj)%#ok<MANU>
            ret=true;
        end

        function ret=errorUnsupportedFixpointMultiword(obj)%#ok<MANU>
            ret=false;
            if(plcfeature('PLCUnsupportedFixpointMultiwordError'))
                ret=true;
            end
        end

        function ret=isPLCCallBackfoldingEnabled(obj)
            ret=true;
            if obj.isRockwellTarget
                ret=false;
            end
        end

        function ret=getExternalSymbolList(obj)
            txt=strtrim(obj.fMdlOption.ExternalDefinedNames);
            ret=strsplit(txt,'(\s|,|;)+','DelimiterType','RegularExpression');
            ret(strcmp(ret,''))=[];
        end

        function ret=isEmitAsPureFunctionEnabled(obj)
            ret=strcmp(obj.fMdlOption.EmitAsPureFunctions,'on');
        end

        function ret=isPureFunctionWithNoInputsEnabled(obj)
            ret=strcmp(obj.fMdlOption.PureFunctionNoInputs,'on');
        end

        function ret=isCommentOptionEnabled(obj)
            ret=strcmp(obj.fMdlOption.RTWGenerateComments,'on');
        end

        function ret=isBlockDescOptionEnabled(obj)
            ret=strcmp(obj.fMdlOption.PLCEnableBlockDescription,'on');
        end

        function ret=hasTypeDesc(obj)
            ret=~isempty(obj.fTypeDescMap)&&~obj.fTypeDescMap.isempty;
        end

        function ret=getTypeListForTypeDesc(obj)
            assert(obj.hasTypeDesc);
            ret=obj.fTypeDescMap.keys;
        end

        function ret=getDescListForTypeDesc(obj)
            assert(obj.hasTypeDesc);
            ret=obj.fTypeDescMap.values;
        end

        function ret=buildBusElementDescMap(obj)
            ret=true;
            if isempty(obj.fBusTypeList)
                ret=false;
                return;
            end

            for i=1:length(obj.fBusTypeList)
                bus_info=obj.fBusTypeList{i};
                bus_name=bus_info.name;
                bus_type=bus_info.typ;
                for j=1:length(bus_type.Elements)
                    bus_elem=bus_type.Elements(j);
                    if isempty(bus_elem.Description)
                        continue;
                    end
                    plcmex('addBusElemDesc',bus_name,bus_elem.Name,bus_elem.Description);
                end
            end
        end

        function setOutputDir(obj,OutputDir)
            obj.fOutputDir=OutputDir;
        end

        function out=getOutputDir(obj)
            out=obj.fOutputDir;
        end

        function ret=isInlineNamedConstant(obj)
            ret=strcmp(obj.fMdlOption.InlineNamedConstant,'on');
        end

        function ret=isRemoveTopFBSSMethodType(obj)
            ret=strcmp(obj.fMdlOption.RemoveTopFBSSMethodType,'on');
            if obj.generateLadderTB
                ret=true;
            end
        end

        function ret=isOverrideDefaultNameLength(obj)
            ret=strcmp(obj.fMdlOption.OverrideDefaultNameLength,'on');
        end

        function ret=EnableAggressiveInlining(obj)
            ret=strcmp(obj.fMdlOption.EnableAggressiveInlining,'on');
        end

        function ret=isGenerateEnumSymbolicName(obj)
            ret=strcmp(obj.fMdlOption.GenerateEnumSymbolicName,'on');
            if obj.checkUnsupportedConfigsetEnumTarget
                ret=false;
            end
        end

        function ret=isRemoveSSStep(obj)
            ret=strcmp(obj.fMdlOption.RemoveSSStep,'on');
        end

        function ret=isGenerateSeperateDataTypeWorksheet(obj)
            ret=strcmp(obj.fMdlOption.EmitDatatypeWorkSheet,'on');
        end

        function setReportGUIMsg(obj,ReportGUIMsg)
            obj.fReportGUIMsg=ReportGUIMsg;
        end

        function reportGUIMsg=getReportGUIMsg(obj)
            reportGUIMsg=obj.fReportGUIMsg;
        end

        function resetErrorCount(obj)
            obj.fErrorCount=0;
            obj.resetErrorMessages;
        end

        function errorCount=getErrorCount(obj)
            errorCount=obj.fErrorCount;
        end

        function incrementErrorCount(obj)
            obj.fErrorCount=obj.fErrorCount+1;
        end

        function resetErrorMessages(obj)
            obj.fErrorMessages={};
        end

        function insertErrorMessages(obj,errorMsg)
            if~isempty(errorMsg)
                obj.fErrorMessages{end+1}=errorMsg;
            end
        end

        function allMsgs=getErrorMessages(obj)
            allMsgs=strjoin(obj.fErrorMessages,newline);
        end

        function ret=isResizeLoopIndexTarget(obj)
            ret=false;
            if obj.getGenerateLadderLogic
                return;
            end
            target=obj.fTargetIDE;
            if strcmp(target,'multiprog50')||strcmp(target,'pcworx60')
                ret=true;
            end
        end

        function controller=checkLogging(obj,controller)
            if~obj.isPLCLogging
                return;
            end
            controller.loginfo.model=obj.fMdlName;
            controller.loginfo.subsystem_id=Simulink.ID.getSID(obj.fSubsysH);
            PLCCoder.codegen.PLCEmitterBase.EmitLogData(controller);
        end

        function ret=generateLadderTB(obj)
            ret=false;
            try
                ret=strcmp(get_param(obj.fModelH,'PLC_GenerateLadderTB'),'on');
            catch
            end
        end

        function ret=getLadderPOUName(obj)
            pou=get_param(obj.fModelH,'PLC_LadderFilePOU');
            assert(~isempty(pou))
            ret=pou;
        end

        function ret=getLadderPOUPath(obj)
            pou=get_param(obj.fModelH,'PLC_LadderFilePath');
            ret=pou;
        end

        function ret=getLadderAOIList(obj)
            import plccore.common.*;
            ret={};
            try
                aoi_list=strsplit(get_param(obj.fModelH,PLCLadderMgr.AOIListParam),',');
                ret=aoi_list;
            catch
            end
        end

        function ret=getLadderUDTList(obj)
            import plccore.common.*;
            ret={};
            try
                udt_list=strsplit(get_param(obj.fModelH,PLCLadderMgr.UDTListParam),',');
                ret=udt_list;
            catch
            end
        end

        function ret=isSingleLadderAOI(obj)
            ret=isempty(obj.getLadderAOIList);
        end

        function ret=getLadderDoc(obj)
            ret=obj.fLadderDoc;
        end

        function setLadderDoc(obj,doc)
            obj.fLadderDoc=doc;
        end

        function ret=generateTBDiagCode(obj)
            ret=strcmp(obj.fMdlOption.GenerateTestbenchDiagCode,'on');
        end

        function ret=isSuppressAutoGenType(obj)
            ret=strcmp(obj.fMdlOption.SuppressAutoGenType,'on');
        end

        function tf=isUSecTaskRateSupportedForTarget(obj)
            if ismember(obj.fTargetIDE,{'codesys35'})
                tf=false;
            else
                tf=true;
            end
        end

        function types=getUnsupportedTypesforTarget(obj)
            types={};
            if ismember(obj.fTargetIDE,{'studio5000','studio5000_routine',...
                'rslogix5000','rslogix5000_routine',...
                'step7','tiaportal','tiaportal_double'})
                switch(obj.fTargetIDE)
                case{'studio5000','studio5000_routine',...
                    'rslogix5000','rslogix5000_routine'}
                    types={'double','uint8','uint16','uint32'};
                case{'step7','tiaportal'}
                    types={'double','uint8','uint16','uint32','int8'};
                end
            else
                if PLCCoder.PLCCGMgr.isCustomTarget(obj.fTargetIDE)
                    cfg=obj.getCGConfig;
                    if~isempty(cfg)
                        if isfield(cfg,'fConvertDoubleToSingleEmitter')&&...
                            cfg.fConvertDoubleToSingleEmitter
                            types=[types,'double'];
                        end
                        if isfield(cfg,'fConvertDoubleToSingle')...
                            &&cfg.fConvertDoubleToSingle
                            types=[types,'double'];
                        end

                        if isfield(cfg,'fConvertUnsignedIntToSignedInt')...
                            &&cfg.fConvertUnsignedIntToSignedInt
                            types=[types,'uint8','uint16','uint32'];
                        end

                        if isfield(cfg,'fInt16AsBaseInt')&&...
                            cfg.fInt16AsBaseInt
                            types=[types,'int8'];
                        end
                        if isfield(cfg,'fInt32AsBaseInt')&&...
                            cfg.fInt32AsBaseInt
                            types=[types,'int8','int16'];
                        end

                    end
                end
            end
        end

        function ret=hasTargetUnsignedInteger(obj)
            ret=true;
            unsupported_type_list=obj.getUnsupportedTypesforTarget;
            if any(strncmp(unsupported_type_list,'uint',4))
                ret=false;
            end
        end

        function ret=useDataDictionary(obj)
            ret=obj.fUseDataDictionary;
        end

        function ret=getDataMgr(obj)
            ret=obj.fPLCDataMgr;
        end

        function ret=isGenerateEnumCastFunction(obj)
            ret=strcmp(obj.fMdlOption.GenerateEnumCastFunction,'on');
            if obj.checkUnsupportedConfigsetEnumTarget
                ret=false;
            end
        end

        function ret=isInlineEnumCastFunction(obj)
            ret=strcmp(obj.fMdlOption.InlineEnumCastFunction,'on');
        end

        function ret=hasTargetEnum(obj)
            target=obj.fTargetIDE;
            if PLCCoder.PLCCGMgr.isCustomTarget(target)
                cfg=obj.getCGConfig;
                if~isempty(cfg)&&isfield(cfg,'fConvertEnumToInteger')
                    if cfg.fConvertEnumToInteger
                        ret=false;
                        return;
                    end
                end
                ret=true;
                return;
            end
            switch target
            case{'codesys23','codesys33','codesys35',...
                'brautomation30','brautomation40',...
                'twincat211','twincat3',...
                }
                ret=true;
            otherwise
                ret=false;
            end
        end

        function ret=targetIndependentTemporal(obj)
            ret=strcmp(obj.fMdlOption.AbsTimeTemporalLogic,'counter');
        end

        function ret=preventExternalVarInitialization(obj)
            ret=strcmp(obj.fMdlOption.PreventExternalVarInitialization,'on');
        end

        function setStringTypeCustomOption(obj)
            switch obj.fTargetIDE
            case 'plcopen'
                obj.fStringTypeCustomOption=true;
                obj.fStringTypeCustomName='string';
            case 'indraworks'
                obj.fStringTypeCustomOption=true;
                obj.fStringTypeCustomName='string';
            otherwise
                obj.fStringTypeCustomOption=false;
                obj.fStringTypeCustomName='';
            end
        end

        function ret=getStringTypeCustomOption(obj)
            ret=obj.fStringTypeCustomOption;
        end

        function ret=getStringTypeCustomName(obj)
            ret=obj.fStringTypeCustomName;
        end

        function keyword_list=runCustomKeyword(obj,keyword_list)
            if exist('plc_custom_keyword','file')==2
                keyword_list=plc_custom_keyword(keyword_list);
                obj.checkCustomKeyword(keyword_list);
            end
        end

        function ret=foldFBCallOutputVar(obj)
            ret=strcmp(obj.fMdlOption.FoldFBCallOutputVar,'on');
        end
    end

    methods(Access=private)
        function obj=PLCCGMgr
            plcmex('resetPLCCGMgr');
            obj.resetCustomIDEList;
            obj.setReportGUIMsg(false);
            obj.resetErrorCount;
        end

        function checkTopMatlabFcnBlock(obj)
            if sfprivate('is_eml_chart_block',obj.fSubsysH)||sfprivate('is_truth_table_chart_block',obj.fSubsysH)
                try
                    mdlName=obj.fMdlName;
                    chartId=sfprivate('block2chart',obj.fSubsysH);
                    if~isempty(sf('InplacePortPairs',chartId))
                        obj.fIsTopMatlabFcnBlock=true;
                    end
                catch Mex
                    newExc=MException('PLCCoder:FailedToCompile',...
                    'Failed to compile ''%s''',mdlName);
                    newExc=newExc.addCause(Mex);
                    throw(newExc);
                end
            end
        end

        function ret=checkUnsupportedConfigsetEnumTarget(obj)


            ret=false;
            switch obj.fTargetIDE
            case{'pcworx60',...
                'rslogix5000','rslogix5000_routine',...
                'studio5000','studio5000_routine',...
                'step7','tiaportal','tiaportal_double'}
                ret=true;
            end
        end

        function checkCustomKeyword(obj,keyword_list)%#ok<INUSL>
            if~iscell(keyword_list)
                error(message('plccoder:plccg_ext:CustomKeywordListTypeError'));
            end

            for i=1:numel(keyword_list)
                if~ischar(keyword_list{i})
                    error(message('plccoder:plccg_ext:CustomKeywordListTypeError'));
                end
            end
        end

        function ret=getSigSourceBlockList(obj,blk_type,fh_num_sig_group)
            blk_list=plc_find_system(obj.fModelH,'searchdepth',1,'BlockType','SubSystem','MaskType',blk_type);
            sigsrc_list=[];
            for i=1:length(blk_list)
                blk=blk_list(i);
                if(fh_num_sig_group(blk)>1)
                    sigsrc_list(end+1)=blk;%#ok<AGROW>
                end
            end

            ret=sigsrc_list;
        end

        function checkSigSourceBlock(obj)
            sigbuilder_list=obj.getSigSourceBlockList('Sigbuilder block',@(x)PLCCoder.PLCSigBuilderInfo.getBlockNumSigGroup(x));
            sigeditor_list=obj.getSigSourceBlockList('SignalEditor',@(x)PLCCoder.PLCSigEditorInfo.getBlockNumSigGroup(x));
            if isempty(sigbuilder_list)&&isempty(sigeditor_list)
                obj.fSigSourceInfo=[];
                return;
            end

            if~isempty(sigbuilder_list)&&~isempty(sigeditor_list)
                error(message('plccoder:plccg_ext:SignalBuilderAndSignalEditorBlock'));
            end

            if~isempty(sigbuilder_list)
                if length(sigbuilder_list)~=1
                    error(message('plccoder:plccg_ext:MultiSignalBuilderBlock'));
                else
                    obj.fSigSourceInfo=PLCCoder.PLCSigBuilderInfo(obj.fModelH,sigbuilder_list(1));
                    return;
                end
            end

            if length(sigeditor_list)~=1
                error(message('plccoder:plccg_ext:MultiSignalEditorBlock'));
            else
                obj.fSigSourceInfo=PLCCoder.PLCSigEditorInfo(obj.fModelH,sigeditor_list(1));
            end
        end

        function checkSigSourceInfo(obj)
            if obj.hasTB&&obj.supportMultiTB
                obj.checkSigSourceBlock;
            else
                obj.fSigSourceInfo=[];
            end
        end

        function ret=genBusTypeInfo(obj,bus_name,bus_type)%#ok<INUSD> 
            ret=struct;
            ret.name=bus_name;
            ret.typ=bus_type;
        end

        function checkBaseWSTypes(obj,typ_map)
            item_list=evalin('base','whos');
            for i=1:length(item_list)
                item=item_list(i);
                if strcmp(item.class,'Simulink.Bus')
                    bus_typ=evalin('base',item.name);
                    if isscalar(bus_typ)
                        obj.fBusTypeList{end+1}=obj.genBusTypeInfo(item.name,bus_typ);
                        if~isempty(bus_typ.Description)
                            typ_map(item.name)=bus_typ.Description;
                        end
                    end
                end
            end
        end

        function checkDataDictionaryTypes(obj,typ_map)
            if~obj.useDataDictionary
                return;
            end

            dd_name=get_param(obj.fModelH,'DataDictionary');
            dd=Simulink.data.dictionary.open(dd_name);
            section=dd.getSection('Design Data');
            item_list=section.find;
            for i=1:length(item_list)
                item=item_list(i);
                val=item.getValue;
                if isscalar(val)&&isa(val,'Simulink.Bus')
                    obj.fBusTypeList{end+1}=obj.genBusTypeInfo(item.Name,val);
                    if~isempty(val.Description)
                        typ_map(item.Name)=val.Description;
                    end
                end
            end
        end

        function buildTypeDescMap(obj)
            obj.fTypeDescMap=[];
            obj.fBusTypeList={};

            if~obj.isCommentOptionEnabled
                return;
            end

            typ_map=containers.Map('KeyType','char','ValueType','char');
            obj.checkBaseWSTypes(typ_map);
            obj.checkDataDictionaryTypes(typ_map);

            if~typ_map.isempty
                obj.fTypeDescMap=typ_map;
            end
        end
    end
end





