classdef C_CodeMetrics<handle














































    properties(Hidden=false,SetAccess=protected)
        FileInfo={};
        GlobalVarInfo={};
        GlobalConstInfo={};
        FcnInfo=[];
        targetisCPP=false;
        ClassMemberInfo={};
        PolySpaceForCodeMetrics=false;
        optSetting=[];
        UseNewForMdlRef=false;
        SysTrgFile=[];
    end
    properties(SetAccess=private)

        LatestStatus=[];
    end
    properties(Hidden=true,SetAccess=protected)
        FileList={};
        reportFileList={};

    end
    properties(Hidden=true,SetAccess=protected)
        CodeMetricsOption=[];
        RecursiveFcnIdx=[];
        KnownStat=[];
        FileIdxMap=[];
        FcnIdxMap=[];
        WorkingDir='';
        hasKnownStat=false;
        bDebug=false;
        bGenDataCopy=false;
        bIgnoreUnfoundFile=false;
        bDataCopyDetails=false;
        bGlobalConstantsEstimation=false;
    end
    properties(SetAccess=protected,Hidden=true)
        ExcludedFiles={};
    end
    properties(Hidden=true,Transient=true)
        FcnInfoMap={};
    end
    methods











        function ccm=C_CodeMetrics(varargin)
            if~license('test','RTW_Embedded_Coder')
                DAStudio.error('RTW:utility:NoECoderLicenseNoCodeMetrics');
            end

            filelist={};

            cmOption=[];

            knownData={};

            if nargin>6
                DAStudio.error('RTW:report:invalidNumOfArgs');
            end
            if nargin>0
                filelist=varargin{1};
            end
            if nargin>1
                cmOption=varargin{2};
            end
            if nargin>2
                knownData=varargin{3};
            end
            if nargin>3
                option=varargin{4};
                if isfield(option,'IsDebug')
                    ccm.bDebug=option.IsDebug;
                end
                if isfield(option,'GenDataCopy')
                    ccm.bGenDataCopy=option.GenDataCopy;
                end
                if isfield(option,'IgnoreUnfoundFile')
                    ccm.bIgnoreUnfoundFile=option.IgnoreUnfoundFile;
                end
                if isfield(option,'IsDataCopyDetails')
                    ccm.bDataCopyDetails=option.IsDataCopyDetails;
                end
                if isfield(option,'IsGlobalConstantsEstimation')
                    ccm.bGlobalConstantsEstimation=option.IsGlobalConstantsEstimation;
                end
            end
            if nargin>4&&isscalar(varargin{5})&&varargin{5}==1
                ccm.PolySpaceForCodeMetrics=true;
            else
                ccm.PolySpaceForCodeMetrics=false;
            end
            if nargin>5
                ccm.targetisCPP=varargin{6};
            end

            ccm.initialize();
            ccm.WorkingDir='';
            ccm.FileList={};
            ccm.KnownStat.FcnInfo=[];
            ccm.KnownStat.GlobalVarInfo=[];
            ccm.KnownStat.GlobalConstInfo=[];
            ccm.KnownStat.FileInfo=[];
            ccm.KnownStat.ClassMemberInfo=[];
            ccm.FileIdxMap=containers.Map;
            ccm.FcnIdxMap=containers.Map;
            ccm.CodeMetricsOption=[];

            ccm.setCodeMetricsOption(cmOption);
            ccm.setFile(filelist);
            if~iscell(knownData)
                knownData={knownData};
            end
            for i=1:length(knownData)
                ccm.addKnownCodeMetrics(knownData{i});
            end
            if~isempty(filelist)
                ccm.calculateCodeMetrics();
                ccm.createFcnInfoMap();
            end
        end








        function addKnownCodeMetrics(ccm,cmData)
            if~isa(cmData,'rtw.codemetrics.C_CodeMetrics')
                DAStudio.error('RTW:report:CodeMetricsInvalidObject');
            end
            if~isequal(ccm.CodeMetricsOption.Target,cmData.CodeMetricsOption.Target)
                DAStudio.error('RTW:report:C_CodeMetricsMisMatchedTarget');
            end
            ccm.KnownStat.FcnInfo=loc_unique([...
            ccm.KnownStat.FcnInfo,cmData.FcnInfo,cmData.KnownStat.FcnInfo],'Name');
            ccm.KnownStat.GlobalVarInfo=loc_unique([...
            ccm.KnownStat.GlobalVarInfo,...
            cmData.GlobalVarInfo,...
            cmData.KnownStat.GlobalVarInfo],'Name');
            if ccm.PolySpaceForCodeMetrics
                ccm.KnownStat.ClassMemberInfo=loc_unique([...
                ccm.KnownStat.ClassMemberInfo,...
                cmData.ClassMemberInfo,...
                cmData.KnownStat.ClassMemberInfo],'Name');
            end
            ccm.KnownStat.GlobalConstInfo=loc_unique([...
            ccm.KnownStat.GlobalConstInfo,...
            cmData.GlobalConstInfo,...
            cmData.KnownStat.GlobalConstInfo],'Name');
            ccm.KnownStat.FileInfo=loc_unique([...
            ccm.KnownStat.FileInfo,...
            cmData.FileInfo,...
            cmData.KnownStat.FileInfo],'Name');
            ccm.hasKnownStat=true;
        end





        function root_fcns=getCallGraphRoot(ccm)
            root_fcns={};
            if~isempty(ccm.FcnInfo)

                callee_idxs=unique([ccm.FcnInfo.CalleeIdx]);
                fcnlists={ccm.FcnInfo.Name};
                callees={ccm.FcnInfo(callee_idxs).Name};

                root_fcns=setdiff(fcnlists,callees);
                if ccm.hasKnownStat
                    root_fcns=setdiff(root_fcns,{ccm.KnownStat.FcnInfo.Name});
                end
            end
        end





        function emitHTML(ccm,arg)
            rptFileName='metrics.html';
            bInReportInfo=false;
            standalone=false;
            if nargin>2
                DAStudio.error('RTW:report:invalidNumOfArgs');
            elseif nargin==2
                if~isstruct(arg)
                    rptFileName=arg;
                else
                    if isfield(arg,'InReportInfo')
                        bInReportInfo=arg.InReportInfo;
                    end
                    if isfield(arg,'ReportFileName')
                        rptFileName=arg.ReportFileName;
                    end
                    if isfield(arg,'standalone')
                        standalone=arg.standalone;
                    end
                end
            end
            if isempty(rptFileName)||~ischar(rptFileName)
                DAStudio.error('RTW:report:C_CodeMetricsInvalidRptName');
            end
            rpt=rtw.report.CodeMetrics(ccm,bInReportInfo);
            if standalone
                rpt.forceGenHyperlinkToSource=false;
            end
            rpt.Data=ccm;
            rpt.ReportFileName=rptFileName;
            rpt.generate;
        end
    end

    methods(Access=protected)




        function initialize(ccm)
            ccm.FcnInfo=[];
            ccm.GlobalVarInfo=[];
            ccm.FileInfo=[];
            ccm.FileIdxMap=containers.Map;
            ccm.FcnIdxMap=containers.Map;
            ccm.LatestStatus.Status='';
            ccm.LatestStatus.Reason=[];
            ccm.RecursiveFcnIdx=[];
        end





        function setCodeMetricsOption(ccm,cmOption)
            ccm.optSetting=getOptSettingFromToolChain(ccm);

            if isempty(cmOption)
                if ccm.PolySpaceForCodeMetrics
                    cmOption=internal.cxxfe.FrontEndOptions;



                    if ccm.targetisCPP
                        targetLang='c++';
                    else
                        targetLang='c';
                    end
                    if~isempty(ccm.optSetting)
                        cmOption=internal.cxxfe.util.getFrontEndOptions('lang',targetLang,'dialect',ccm.optSetting);
                    end
                end
                cmOption.Preprocessor.IncludeDirs={};
                cmOption.Preprocessor.UnDefines={};
                if isempty(ccm.optSetting)
                    cmOption.Preprocessor.SystemIncludeDirs={fullfile(matlabroot,'sys','lcc','include')};
                    cmOption.Preprocessor.SystemIncludeDirs{end+1}=...
                    fullfile(matlabroot,'toolbox','rtw','rtw','+rtw','+codemetrics','@C_CodeMetrics','include');
                elseif contains(ccm.optSetting,'msvc')


                    cmOption.Preprocessor.SystemIncludeDirs{end+1}=fullfile(matlabroot,'sys','lcc','include');
                end


                cmOption.Preprocessor.SystemIncludeDirs{end+1}=...
                fullfile(matlabroot,'toolbox','rtw','rtw','+rtw','+codemetrics','@C_CodeMetrics','omp_include');
                cmOption.Preprocessor.SystemIncludeDirs{end+1}=...
                fullfile(matlabroot,'toolbox','rtw','rtw','+rtw','+codemetrics','@C_CodeMetrics','stub_include');

                cmOption.Target.Endianness='little';
                size_struct=ccm.getHardwareSize();
                cmOption.Target.CharNumBits=size_struct.charNumBits;
                cmOption.Target.ShortNumBits=size_struct.shortNumBits;
                cmOption.Target.IntNumBits=size_struct.intNumBits;
                cmOption.Target.LongNumBits=size_struct.longNumBits;
                cmOption.Target.PointerNumBits=size_struct.intNumBits;
                macrosForTarget=rtw.codemetrics.C_CodeMetrics.getMacrosForTarget(size_struct.charNumBits,...
                size_struct.shortNumBits,size_struct.intNumBits,...
                size_struct.longNumBits,size_struct.wordSize);



                if~isfield(cmOption.Preprocessor,'Defines')
                    cmOption.Preprocessor.Defines=macrosForTarget;
                else
                    cmOption.Preprocessor.Defines=[cmOption.Preprocessor.Defines;macrosForTarget'];
                end
            end
            if ccm.PolySpaceForCodeMetrics

                cmOption.DoIlLowering=false;
            else
                cmOption.Language.LanguageMode='c';
                cmOption.Language.SizeTypeKind=1;
                cmOption.DoVarInitializationConversion=false;
                cmOption.DoUniquifyName=false;
                cmOption.DoIlLowering=true;
            end


            cmOption.ExtraOptions={'--extract_code_metrics'};

            if isempty(ccm.optSetting)
                cmOption.Language.LanguageExtra={'--microsoft','--ignore_microsoft_predef_macros'};



                cmOption.Language.MinStructAlignment=1;
                cmOption.Language.MaxAlignment=1;
            end
            if cmOption.Target.PointerNumBits==cmOption.Target.LongNumBits
                cmOption.Language.PtrDiffTypeKind='long';
            else
                cmOption.Language.PtrDiffTypeKind='int';
            end


            lcc_defines={};
            if isempty(ccm.optSetting)



                lcc_defines={...
                '__LCC__';...
                'TMW_ENABLE_INT64';...
                '__cdecl=/**/';...
                '__int64=long long';...
                '_MW_DEFINE_FOR_CODE_METRICS_C99_COMPATIBILITY_';...
'__MW_CODE_METRICS__'...
                };
            end
            if ccm.PolySpaceForCodeMetrics
                if isempty(ccm.optSetting)
                    cmOption.Preprocessor.Defines=[cmOption.Preprocessor.Defines;lcc_defines];
                end
            else
                lcc_defines=lcc_defines';
                if isfield(cmOption,'Preprocessor')&&isfield(cmOption.Preprocessor,'Defines')
                    cmOption.Preprocessor.Defines=[cmOption.Preprocessor.Defines,lcc_defines];
                else
                    cmOption.Preprocessor.Defines=lcc_defines;
                end
            end
            if~isempty(ccm.optSetting)&&contains(ccm.optSetting,'msvc')
                if ccm.targetisCPP
                    cmOption.Language.LanguageExtra{end+1}='--no_nullptr';
                end

                cmOption.Preprocessor.Defines{end+1}='_POSIX_C_SOURCE=200112L';
                cmOption.Preprocessor.Defines{end+1}='_LIBCPP_SUPPORT_WIN32_MATH_WIN32_H=1';
            end
            cmOption.Preprocessor.Defines{end+1}='POLYSPACE_INSTRUMENT';
            ccm.CodeMetricsOption=cmOption;
        end






        function setWorkingDir(ccm,wd)
            if exist(wd,'dir')
                ccm.WorkingDir=wd;
            else
                DAStudio.error('RTW:utility:dirDoesNotExist',wd);
            end
        end
    end
    methods(Hidden=true)




        function createFcnInfoMap(ccm)
            ccm.FcnInfoMap=containers.Map;
            if~strcmp(ccm.LatestStatus.Status,'successful')
                return;
            end
            fcns={ccm.FcnInfo.Name};
            structs=ccm.FcnInfo;
            if ccm.hasKnownStat
                fcns=[{ccm.KnownStat.FcnInfo.Name},fcns];
                if isfield(ccm.KnownStat.FcnInfo,'MdlRef')
                    myFcnInfo=rmfield(ccm.KnownStat.FcnInfo,'MdlRef');
                else
                    myFcnInfo=ccm.KnownStat.FcnInfo;
                end
                if~isempty(myFcnInfo)
                    structs=[myFcnInfo,structs];
                end
                [fcns,tf]=unique(fcns);
                structs=structs(tf);
            end
            for i=1:length(fcns)
                ccm.FcnInfoMap(fcns{i})=structs(i);
            end
        end
    end

    methods(Hidden=true)
        function size_struct=getHardwareSize(~)
            hostInfo=rtwhostwordlengths;
            size_struct.charNumBits=hostInfo.CharNumBits;
            size_struct.shortNumBits=hostInfo.ShortNumBits;
            size_struct.intNumBits=hostInfo.IntNumBits;
            size_struct.longNumBits=hostInfo.LongNumBits;
            size_struct.wordSize=hostInfo.WordSize;
        end
        function out=getDataCopyDetailsFeature(~)
            out=slfeature('DataCopyDetails');
        end
        function out=getGlobalConstantsEstimationFeature(~)
            out=slfeature('GlobalConstantsEstimation');
        end
        function out=getToolchainDependentCodeMetricsFeature(~)
            out=slfeature('ToolchainDependentCodeMetrics');
        end
        function out=getReportStructFieldDetailsInCodeMetrics(~)
            out=slfeature('ReportStructFieldDetailsInCodeMetrics');
        end
    end

    methods(Hidden=true,Access=protected)




        function setFile(ccm,filelist)
            if~iscell(filelist)
                filelist={filelist};
            end
            filelist=unique(filelist);
            for i=1:length(filelist)

                name_parts=strsplit(filelist{i},'.');
                if~(strcmpi(name_parts{end},'hpp')||...
                    strcmpi(name_parts{end},'cpp')||...
                    strcmpi(name_parts{end},'h')||...
                    strcmpi(name_parts{end},'c'))
                    continue;
                end
                if~exist(filelist{i},'file')

                    if isprop(ccm,'BuildDir')&&exist(fullfile(ccm.BuildDir,'html',filelist{i}),'file')
                        filelist{i}=fullfile(ccm.BuildDir,'html',filelist{i});
                    else
                        if~ccm.bIgnoreUnfoundFile
                            DAStudio.error('RTW:utility:fileDoesNotExist',filelist{i});
                        end
                    end
                end
                filelist{i}=ccm.getFileFullName(filelist{i});
            end
            ccm.FileList=filelist;
            if isempty(ccm.reportFileList)
                ccm.reportFileList=filelist;
            end
        end





        function calculateCodeMetrics(ccm)
            ccm.initialize();

            if ccm.hasKnownStat&&strcmp(ccm.LatestStatus.Status,'failed')
                return;
            end

            if isempty(ccm.FileList)
                return;
            end

            if ccm.PolySpaceForCodeMetrics==false
                hasCppFile=false;
                files=ccm.FileList;
                for i=1:length(files)
                    [~,~,ext]=fileparts(files{i});
                    if strcmpi(ext,'.cpp')
                        hasCppFile=true;
                        break;
                    end
                end
                if hasCppFile
                    ccm.LatestStatus.Status='notSupportCPP';
                    ccm.LatestStatus.Reason='';
                    return;
                end
            end




            saved_pwd='';
            if~isempty(ccm.WorkingDir)&&~isequal(ccm.WorkingDir,pwd)
                saved_pwd=pwd;
                cd(ccm.WorkingDir);
            end
            msgs=ccm.call_C_CodeMetrics();
            if~isempty(saved_pwd)
                cd(saved_pwd);
            end

            if~isempty(msgs)&&ismember('error',{msgs.kind})
                ccm.LatestStatus.Status='failed';
                ccm.LatestStatus.Reason=msgs;

                if~ccm.bGenDataCopy
                    if isfield(ccm.FcnInfo,'DataCopy')
                        ccm.FcnInfo=rmfield(ccm.FcnInfo,'DataCopy');
                    end
                    if isfield(ccm.FcnInfo,'DataCopyTotal')
                        ccm.FcnInfo=rmfield(ccm.FcnInfo,'DataCopyTotal');
                    end
                end
                return;
            else
                ccm.LatestStatus.Status='successful';
                ccm.LatestStatus.Reason='';
            end

            children=cell(size(ccm.FcnInfo));
            weight=cell(size(ccm.FcnInfo));
            for i=1:length(ccm.FcnInfo)
                children{i}=ccm.FcnInfo(i).CalleeIdx;
                weight{i}=[ccm.FcnInfo(i).Callee.Weight];
            end

            functionName={ccm.FcnInfo.Name};


            tChildren=children;
            tWeight=weight;




            parentsIdx=loc_cellfind(tChildren);

            isRecurFcn=zeros(size(functionName));
            nFcn=length(functionName);
            while~isempty(parentsIdx)
                leafNodes=setdiff((1:nFcn)',parentsIdx);
                for i=1:length(parentsIdx)
                    p_idx=parentsIdx(i);
                    c_nodes=tChildren{p_idx};

                    tf=ismember(c_nodes,leafNodes);
                    if~any(tf)
                        continue;
                    end

                    c_nodes=c_nodes(tf);
                    c_weight=tWeight{p_idx}(tf);

                    [tChildren{p_idx},loc]=setdiff(tChildren{p_idx},c_nodes);
                    tWeight{p_idx}=tWeight{p_idx}(loc);

                    child_stack_max=0;
                    for j=1:length(c_nodes)

                        if isRecurFcn(c_nodes(j))==1
                            ccm.FcnInfo(p_idx).DataCopyTotal=-1;
                            ccm.FcnInfo(p_idx).StackTotal=-1;
                            isRecurFcn(p_idx)=1;

                            break;
                        else

                            ccm.FcnInfo(p_idx).DataCopyTotal=ccm.FcnInfo(p_idx).DataCopyTotal+...
                            ccm.FcnInfo(c_nodes(j)).DataCopyTotal*c_weight(j);
                            if child_stack_max<ccm.FcnInfo(c_nodes(j)).StackTotal
                                child_stack_max=ccm.FcnInfo(c_nodes(j)).StackTotal;
                            end
                        end
                    end




                    if ccm.FcnInfo(p_idx).Stack+child_stack_max>ccm.FcnInfo(p_idx).StackTotal
                        ccm.FcnInfo(p_idx).StackTotal=ccm.FcnInfo(p_idx).Stack+child_stack_max;
                    end
                end

                nparentsIdx=length(parentsIdx);

                parentsIdx=loc_cellfind(tChildren);

                parentsIdx=setdiff(parentsIdx,find(isRecurFcn));
                if length(parentsIdx)==nparentsIdx



                    isRecurFcn(parentsIdx)=1;
                    for k=1:length(parentsIdx)
                        ccm.FcnInfo(parentsIdx(k)).DataCopyTotal=-1;
                        ccm.FcnInfo(parentsIdx(k)).StackTotal=-1;
                    end
                    break;
                end
            end


            ccm.RecursiveFcnIdx=find(isRecurFcn);

            if~ccm.bGenDataCopy
                if isfield(ccm.FcnInfo,'DataCopy')
                    ccm.FcnInfo=rmfield(ccm.FcnInfo,'DataCopy');
                end
                if isfield(ccm.FcnInfo,'DataCopyTotal')
                    ccm.FcnInfo=rmfield(ccm.FcnInfo,'DataCopyTotal');
                end
            end
        end

    end

    methods(Access=private)




        function msgs=call_C_CodeMetrics(ccm)
            if~ccm.PolySpaceForCodeMetrics
                origPath=addpath(fullfile(matlabroot,'toolbox','shared','cgir_fe'));
                cu=onCleanup(@()path(origPath));
            end
            msgs=[];
            fileList=ccm.FileList;
            edg_option=ccm.CodeMetricsOption;
            globalVarInfo=struct('Name',{},'FileIdx',{},'Size',{},'File',{},'IsStatic',{},'IsBitField',{},'IsExported',{},'UseCount',{},'Members',{},'UseInFunctions',{});
            globalConstInfo=struct('Name',{},'FileIdx',{},'Size',{},'File',{},'IsStatic',{});
            fileInfo=struct('Name',{},'Idx',{},'IncludedIdx',{},'IsIncludedFile',{},...
            'IsSystemFile',{},'NumCommentLines',{},'NumTotalLines',{},...
            'NumCodeLines',{},'IncludedFile',{});

            fcnInfo=struct('Name',{},'UniqueKey',{},'Idx',{},'FileIdx',{},'Position',{},'NumCommentLines',{},...
            'NumTotalLines',{},'NumCodeLines',{},'Callee',{},'Caller',{},'DataCopy',{},...
            'Stack',{},'HasDefinition',{},'File',{},'IsStatic',{},'DataCopyDetails',{},...
            'Complexity',{});

            slfDataCopyDetails=ccm.getDataCopyDetailsFeature();

            slfGlobalConstantsEstimation=ccm.getGlobalConstantsEstimationFeature();

            ccmOption.IsDataCopyDetails=ccm.bDataCopyDetails&&slfDataCopyDetails;
            ccmOption.IsGlobalConstantsEstimation=ccm.bGlobalConstantsEstimation&&slfGlobalConstantsEstimation;
            ccmOption.IsDebug=ccm.bDebug;
            if~ccm.getReportStructFieldDetailsInCodeMetrics()
                ccm.CodeMetricsOption.ExtraOptions{end+1}='--no_ec_code_metrics_report_struct_field';
            end

            if ccm.PolySpaceForCodeMetrics
                classMemberInfo=struct('Name',{},'FileIdx',{},'Size',{},'File',{},'IsStatic',{},'IsBitField',{},'IsExported',{},'UseCount',{},'Members',{},'UseInFunctions',{});
                isMdlRef=1;
                try
                    build_dir=RTW.getBuildDir(ccm.ModelName).BuildDirectory;
                    if exist(fullfile(build_dir,'buildInfo.mat'),'file')
                        load(fullfile(build_dir,'buildInfo'));
                        isMdlRef=0;
                    else
                        load('buildInfo');
                        isMdlRef=1;
                    end
                catch
                end

                try
                    if strcmpi(get_param(ccm.ModelName,'UseOperatorNewForModelRefRegistration'),'on')
                        ccm.UseNewForMdlRef=true;
                    else
                        ccm.UseNewForMdlRef=false;
                    end
                catch
                end

                try
                    [~,ccm.SysTrgFile]=fileparts(get_param(ccm.ModelName,'SystemTargetFile'));
                catch
                end

                for i=1:length(fileList)
                    [~,~,ext]=fileparts(fileList{i});

                    if~strcmpi(ext,'.cpp')&&~strcmpi(ext,'.c')
                        continue;
                    end

                    if ccm.bIgnoreUnfoundFile
                        if~exist(fileList{i},'file')
                            continue;
                        end
                    end
                    [msg,info]=rtw.codemetrics.extractCodeMetrics(fileList{i},ccm);
                    if~isempty(msg)
                        msgs=[msgs,msg'];%#ok
                    end

                    if~isempty(info.fileInfo)
                        fileInfo=[fileInfo,info.fileInfo];%#ok
                    end
                    if~isempty(info.fcnInfo)
                        fcnInfo=[fcnInfo,info.fcnInfo];%#ok
                    end
                    if~isempty(info.globalVarInfo)
                        globalVarInfo=[globalVarInfo,info.globalVarInfo];%#ok
                    end
                    if ccmOption.IsGlobalConstantsEstimation&&~isempty(info.globalConstInfo)
                        globalConstInfo=[globalConstInfo,info.globalConstInfo];%#ok
                    end
                    if~isempty(info.classMemberInfo)
                        classMemberInfo=[classMemberInfo,info.classMemberInfo];%#ok
                    end
                end





                ignored_files=setdiff(fileList,{fileInfo.Name});
                for ii=1:length(ignored_files)
                    [~,~,ext]=fileparts(ignored_files{ii});
                    if~strcmpi(ext,'.cpp')&&~strcmpi(ext,'.c')&&~strcmpi(ext,'.h')&&~strcmpi(ext,'.hpp')
                        continue;
                    end
                    [msg,info]=rtw.codemetrics.extractCodeMetrics(ignored_files{ii},ccm);
                    if~isempty(info.fileInfo)&&(isempty(msg)||~ismember('error',{msg.kind}))
                        fileidx=NaN;
                        index=find(strcmpi({info.fileInfo.Name},ignored_files(ii)));
                        if~isempty(index)
                            info.fileInfo(index).IncludedFile={};
                            fileInfo=[fileInfo,info.fileInfo(index)];%#ok
                            fileidx=info.fileInfo(index).Idx;
                        end

                        for jj=1:length(info.fcnInfo)
                            if info.fcnInfo(jj).HasDefinition&&info.fcnInfo(jj).FileIdx==fileidx
                                info.fcnInfo(jj).File=ignored_files(ii);
                                fcnInfo=[fcnInfo,info.fcnInfo(jj)];%#ok
                            end
                        end
                    end
                end
            else
                for i=1:length(fileList)
                    [~,~,ext]=fileparts(fileList{i});


                    if~strcmpi(ext,'.c')
                        continue;
                    end

                    if ccm.bIgnoreUnfoundFile
                        if~exist(fileList{i},'file')
                            continue;
                        end
                    end
                    info={};
                    if slfeature('PolySpaceForCodeMetrics')==2
                        dirs=RTW.getBuildDir(ccm.ModelName);
                        build_dir=dirs.BuildDirectory;
                        if~exist(fullfile(build_dir,'buildInfo.mat'),'file')
                            build_dir=strcat(dirs.CodeGenFolder,'/',dirs.ModelRefRelativeBuildDir);
                        end
                        run(strcat(build_dir,'/useBackupCodeMetrics.m'));


                    else
                        [msg,info]=slcgir_codemetrics_mex(fileList{i},edg_option,ccmOption);
                        if~isempty(msg)
                            msgs=[msgs,msg'];%#ok
                        end
                    end


                    for j=1:length(info.FileInfo)
                        info.FileInfo(j).Name=strrep(strrep(info.FileInfo(j).Name,'/',filesep),'\',filesep);
                    end
                    fname={info.FileInfo.Name};
                    fidx=[info.FileInfo.Idx];
                    [~,tf]=sort(fidx);
                    fname=fname(tf);
                    for j=1:length(info.FileInfo)
                        info.FileInfo(j).IncludedFile=fname(info.FileInfo(j).IncludedIdx);
                    end




                    ignore_fidx=[];
                    ignore_fcn_name={};
                    index=[];
                    for j=1:length(info.FcnInfo)


                        if isempty(info.FcnInfo(j).NumCodeLines)
                            ignore_fidx(end+1)=info.FcnInfo(j).Idx;%#ok
                            ignore_fcn_name{end+1}=info.FcnInfo(j).Name;%#ok
                        else
                            index(end+1)=j;%#ok
                        end
                    end
                    info.FcnInfo=info.FcnInfo(index);
                    for j=1:length(info.FcnInfo)
                        info.FcnInfo(j).File=fname(info.FcnInfo(j).FileIdx);
                        if~isempty(ignore_fcn_name)
                            if~isempty(info.FcnInfo(j).Callee)
                                [~,tf]=setdiff({info.FcnInfo(j).Callee.Name},ignore_fcn_name);
                                tf=sort(tf);
                                info.FcnInfo(j).Callee=info.FcnInfo(j).Callee(tf);
                            end
                            if~isempty(info.FcnInfo(j).Caller)
                                [~,tf]=setdiff({info.FcnInfo(j).Caller.Name},ignore_fcn_name);
                                tf=sort(tf);
                                info.FcnInfo(j).Caller=info.FcnInfo(j).Caller(tf);
                            end
                        end
                    end

                    for j=1:length(info.GlobalVarInfo)
                        info.GlobalVarInfo(j).File=fname(info.GlobalVarInfo(j).FileIdx);
                    end
                    if ccmOption.IsGlobalConstantsEstimation
                        for j=1:length(info.GlobalConstInfo)
                            info.GlobalConstInfo(j).File=fname(info.GlobalConstInfo(j).FileIdx);
                        end
                    end
                    if slfeature('PolySpaceForCodeMetrics')==2
                        if~isempty(info.FileInfo)
                            fileInfo=info.FileInfo;
                        end
                        if~isempty(info.FcnInfo)
                            fcnInfo=info.FcnInfo;
                        end
                        if~isempty(info.GlobalVarInfo)
                            globalVarInfo=info.GlobalVarInfo;
                        end
                        if~isempty(info.GlobalConstInfo)
                            globalConstInfo=info.GlobalConstInfo;
                        end
                    else
                        if~isempty(info.FileInfo)
                            fileInfo=[fileInfo,info.FileInfo];%#ok
                        end
                        if~isempty(info.FcnInfo)
                            fcnInfo=[fcnInfo,info.FcnInfo];%#ok
                        end
                        if~isempty(info.GlobalVarInfo)
                            globalVarInfo=[globalVarInfo,info.GlobalVarInfo];%#ok
                        end
                        if~isempty(info.GlobalConstInfo)
                            globalConstInfo=[globalConstInfo,info.GlobalConstInfo];%#ok
                        end
                    end
                end




                ignored_files=setdiff(fileList,{fileInfo.Name});
                for i=1:length(ignored_files)
                    info={};
                    msg={};
                    if slfeature('PolySpaceForCodeMetrics')==2
                        dirs=RTW.getBuildDir(ccm.ModelName);
                        build_dir=dirs.BuildDirectory;
                        if~exist(fullfile(build_dir,'buildInfo.mat'),'file')
                            build_dir=strcat(dirs.CodeGenFolder,'/',dirs.ModelRefRelativeBuildDir);
                        end
                        run(strcat(build_dir,'/useBackupCodeMetrics.m'));

                    else
                        [msg,info]=slcgir_codemetrics_mex(ignored_files{i},edg_option,ccmOption);
                    end


                    if isempty(msg)||~ismember('error',{msg.kind})
                        fileidx=NaN;
                        for j=1:length(info.FileInfo)


                            info.FileInfo(j).Name=strrep(strrep(info.FileInfo(j).Name,'/',filesep),'\',filesep);

                            if strcmp(info.FileInfo(j).Name,ignored_files{i})
                                info.FileInfo(j).IncludedFile={};
                                fileInfo=[fileInfo,info.FileInfo(j)];%#ok
                                fileidx=info.FileInfo(j).Idx;
                                break;
                            end
                        end

                        for j=1:length(info.FcnInfo)
                            if info.FcnInfo(j).HasDefinition&&info.FcnInfo(j).FileIdx==fileidx
                                info.FcnInfo(j).File=ignored_files(i);
                                fcnInfo=[fcnInfo,info.FcnInfo(j)];%#ok
                            end
                        end
                    end
                end
            end


            if~ccmOption.IsDataCopyDetails
                fcnInfo=rmfield(fcnInfo,{'DataCopyDetails','Position'});
            end
            fileInfo=rmfield(fileInfo,{'IncludedIdx','IsIncludedFile','IsSystemFile','IncludedFile'});
            fcnInfo=rmfield(fcnInfo,'FileIdx');
            globalVarInfo=rmfield(globalVarInfo,'FileIdx');
            globalVarInfo=condition_globalvar_data(globalVarInfo);
            globalVarInfo=loc_unique(globalVarInfo,'Name');

            if ccm.PolySpaceForCodeMetrics
                classMemberInfo=rmfield(classMemberInfo,'FileIdx');
                classMemberInfo=condition_globalvar_data(classMemberInfo);
                classMemberInfo=loc_unique(classMemberInfo,'Name');
            end

            if ccmOption.IsGlobalConstantsEstimation
                globalConstInfo=rmfield(globalConstInfo,'FileIdx');
                loc_check_multi_def_var(globalConstInfo);
                globalConstInfo=loc_unique(globalConstInfo,'Name');
            end

            fileInfo=loc_unique(fileInfo,'Name');
            loc_check_multi_def_fcn(fcnInfo);

            definedFcn=fcnInfo(ismember([fcnInfo.HasDefinition],1));
            definedFcn={definedFcn.Name};
            tf=[];
            for i=1:length(fcnInfo)
                if fcnInfo(i).HasDefinition||~ismember(fcnInfo(i).Name,definedFcn)
                    tf(end+1)=i;%#ok
                end
            end



            fcnInfoMap=containers.Map;
            for i=1:length(fcnInfo)
                aName=fcnInfo(i).Name;
                if fcnInfoMap.isKey(aName)
                    if fcnInfo(i).HasDefinition
                        aFcnInfo=fcnInfo(i);
                        aFcnInfo.Caller=[aFcnInfo.Caller,fcnInfoMap(aName).Caller];
                        fcnInfoMap(aName)=aFcnInfo;
                    else
                        aFcnInfo=fcnInfoMap(aName);
                        aFcnInfo.Caller=[aFcnInfo.Caller,fcnInfo(i).Caller];
                        fcnInfoMap(aName)=aFcnInfo;
                    end
                else
                    fcnInfoMap(aName)=fcnInfo(i);
                end
            end
            tmp=fcnInfoMap.values;
            if~isempty(tmp)
                fcnInfo=[tmp{:}];
            end

            fcnInfo=loc_unique(fcnInfo,'Name');
            for i=1:length(fileInfo)
                fileInfo(i).Idx=i;
                ccm.FileIdxMap(fileInfo(i).Name)=i;
                d=dir(fileInfo(i).Name);
                if~isempty(d)
                    fileInfo(i).Datenum=d.datenum;
                else

                    fileInfo(i).Datenum=[];
                end
            end
            if ccm.hasKnownStat
                known_fcns={ccm.KnownStat.FcnInfo.Name};
            else
                known_fcns={};
            end


            tmp=cell(size(fcnInfo));
            [fcnInfo(:).DataCopyTotal]=deal(tmp(:));
            [fcnInfo(:).StackTotal]=deal(tmp(:));

            for i=1:length(fcnInfo)
                fcnInfo(i).DataCopyTotal=fcnInfo(i).DataCopy;
                fcnInfo(i).StackTotal=fcnInfo(i).Stack;
                fcnInfo(i).CalleeIdx=[];
                if ccm.hasKnownStat&&~fcnInfo(i).HasDefinition
                    [tf,loc]=ismember(fcnInfo(i).Name,known_fcns);
                    if tf
                        finfo=ccm.KnownStat.FcnInfo(loc);





                        fcnInfo(i).File=finfo.File;
                        fcnInfo(i).NumCommentLines=finfo.NumCommentLines;
                        fcnInfo(i).NumTotalLines=finfo.NumTotalLines;
                        fcnInfo(i).NumCodeLines=finfo.NumCodeLines;
                        fcnInfo(i).Callee=struct('Name',{},'Weight',{});
                        fcnInfo(i).CalleeIdx=[];
                        fcnInfo(i).Stack=finfo.Stack;
                        fcnInfo(i).StackTotal=finfo.StackTotal;
                        fcnInfo(i).HasDefinition=finfo.HasDefinition;
                        fcnInfo(i).Complexity=finfo.Complexity;
                        if ccm.bGenDataCopy
                            fcnInfo(i).DataCopy=finfo.DataCopy;
                            fcnInfo(i).DataCopyTotal=finfo.DataCopyTotal;
                        end
                        if ccmOption.IsDataCopyDetails
                            fcnInfo(i).DataCopyDetails=finfo.DataCopyDetails;
                            fcnInfo(i).Position=finfo.Position;
                        end

                    end
                end
                fcnInfo(i).Idx=i;
                ccm.FcnIdxMap(fcnInfo(i).Name)=i;
            end
            for i=1:length(fcnInfo)
                fcnInfo(i).CalleeIdx=zeros(size(fcnInfo(i).Callee));
                for j=1:length(fcnInfo(i).Callee)
                    fcnInfo(i).CalleeIdx(j)=ccm.FcnIdxMap(fcnInfo(i).Callee(j).Name);
                end
            end
            ccm.FileInfo=fileInfo;
            ccm.FcnInfo=fcnInfo;
            ccm.GlobalVarInfo=globalVarInfo;
            ccm.GlobalConstInfo=globalConstInfo;
            if ccm.PolySpaceForCodeMetrics
                ccm.ClassMemberInfo=classMemberInfo;
            end
        end
    end
    methods(Static)
        function macros=getMacrosForTarget(charNumBits,shortNumBits,intNumBits,longNumBits,wordSize)
            charNumBits=double(charNumBits);
            shortNumBits=double(shortNumBits);
            intNumBits=double(intNumBits);
            longNumBits=double(longNumBits);
            wordSize=double(wordSize);
            long_max=uint64(2^(longNumBits-1))-1;
            macros={'_LIMITS_H___',['CHAR_BIT=',int2str(charNumBits)],'MB_LEN_MAX=2',...
            ['SCHAR_MIN=(-',int2str(2^(charNumBits-1)),')'],...
            ['SCHAR_MAX=',int2str(2^(charNumBits-1)-1)],...
            ['UCHAR_MAX=',int2str(2^charNumBits-1)],...
            ['CHAR_MIN=(-',int2str(2^(charNumBits-1)),')'],...
            ['CHAR_MAX=',int2str(2^(charNumBits-1)-1)],...
            ['SHRT_MIN=(-',int2str(2^(shortNumBits-1)),')'],...
            ['SHRT_MAX=',int2str(2^(shortNumBits-1)-1)],...
            ['USHRT_MAX=',int2str(2^shortNumBits-1)],...
            ['INT_MIN=(-',int2str(2^(intNumBits-1)),')'],...
            ['INT_MAX=',int2str(2^(intNumBits-1)-1)],...
            ['UINT_MAX=',int2str(2^intNumBits-1)],...
            ['LONG_MAX=',int2str(long_max)],...
            ['LONG_MIN=(-',int2str(long_max+1),')'],...
            ['ULONG_MAX=',int2str(2*long_max+1)],...
            ['__WORDSIZE=',int2str(wordSize)]};
        end






        function ret=getIdentifierOrigName(s)
            s=fliplr(s);
            r=strtok(s,':');
            ret=fliplr(r);
        end








        function file_fullname=getFileFullName(file)
            file_fullname='';
            if exist(file,'file')
                [path,name,ext]=fileparts(file);
                if isempty(path)
                    path=pwd;
                else
                    path=cd(cd(path));
                end
                file_fullname=fullfile(path,[name,ext]);
            end
        end
    end
end


function idx=loc_cellfind(c)
    idx=[];
    for i=1:length(c)
        if~isempty(c{i})
            idx=[idx;i];%#ok
        end
    end
end


function[list,tf]=loc_unique(list,fieldName)
    cmd=['keys = {list.',fieldName,'};'];
    eval(cmd);
    [~,tf]=unique(keys);
    list=list(tf);
end
function var=update_useCount(defined_var,duplicate_var)
    defined_var.UseCount=defined_var.UseCount+duplicate_var.UseCount;
    for i=1:length(defined_var.Members)
        defined_var.Members(i)=update_useCount(defined_var.Members(i),duplicate_var.Members(i));
    end
    var=defined_var;
end


function[list]=condition_globalvar_data(list)
    newList=loc_unique(list,'Name');


    exprt_flag_0_idx=([list(:).IsExported]==0);
    duplicatedVars=list(exprt_flag_0_idx);
    uniqueVars=list(~exprt_flag_0_idx);

    loc_check_multi_def_var(uniqueVars);

    for eVar=duplicatedVars
        defined_var=uniqueVars(strcmp(eVar.Name,{uniqueVars(:).Name}));


        if(length(defined_var)~=1)
            continue;
        end

        duplicates=duplicatedVars(strcmp(eVar.Name,{duplicatedVars(:).Name}));
        for duplicate=duplicates
            defined_var.UseCount=defined_var.UseCount+duplicate.UseCount;
            defined_var.UseInFunctions=[defined_var.UseInFunctions,duplicate.UseInFunctions];
            defined_var.Members=member_accumulation(defined_var.Members,duplicate.Members);
        end

        newList(strcmp(eVar.Name,{newList(:).Name}))=defined_var;
    end



    list=newList([newList(:).IsExported]==1);
end

function defined_members=member_accumulation(defined_members,duplicate_members)
    if isempty(duplicate_members)
        return;
    end
    for m=1:length(defined_members)
        dup_m=find(strcmpi(defined_members(m).Name,{duplicate_members.Name}),1);
        if~isempty(dup_m)
            defined_members(m).UseCount=defined_members(m).UseCount+duplicate_members(dup_m).UseCount;
            defined_members(m).UseInFunctions=[defined_members(m).UseInFunctions,duplicate_members(dup_m).UseInFunctions];
            defined_members(m).Members=member_accumulation(defined_members(m).Members,duplicate_members(dup_m).Members);
        end
    end
end

function loc_check_multi_def_var(globalVarInfo)
    vars={globalVarInfo.Name};
    files=[globalVarInfo.File];
    flags=[];
    for i=1:length(files)
        file=files{i};
        [~,~,ext]=fileparts(file);
        if strcmpi(ext,'.c')||strcmpi(ext,'.cpp')
            flags=[flags,i];%#ok
        end
    end
    vars=vars(flags);
    files=files(flags);
    [vars,I]=sort(vars);
    files=files(I);
    err_msg=loc_check_multi_def_token(vars,files,'RTW:report:VarMultiDef');
    if~isempty(err_msg)
        DAStudio.error('RTW:report:MultiTokenDefinition',err_msg);
    end
end

function loc_check_multi_def_fcn(fcnInfo)

    f=fcnInfo(ismember([fcnInfo.HasDefinition],1));



    key=cell(size(f));
    for i=1:length(f)
        key{i}=[f(i).UniqueKey,'$',f(i).File{1}];
    end

    [~,loc]=unique(key);
    f=f(loc);
    fcns={f.UniqueKey};
    uniq_fcns=unique(fcns);
    if length(uniq_fcns)~=length(fcns)

        files=[f.File];
        [fcns,I]=sort(fcns);
        files=files(I);
        err_msg=loc_check_multi_def_token(fcns,files,'RTW:report:FcnMultiDef');
        if~isempty(err_msg)
            DAStudio.error('RTW:report:MultiTokenDefinition',err_msg);
        end
    end
end

function err_msg=loc_check_multi_def_token(tokens,files,token_id)
    s='';
    err_msg='';
    for i=1:length(tokens)-1
        token=tokens{i};
        file=files{i};
        token1=tokens{i+1};
        if strcmp(token,token1)
            s=[s,file,', '];%#ok
        else
            if~isempty(s)
                s=[s,file,', '];%#ok
                err_msg=[err_msg,DAStudio.message(token_id,token,s(1:end-2))];%#ok
            end
            s='';
        end
    end
    if~isempty(s)
        s=[s,files{end}];
        err_msg=[err_msg,DAStudio.message(token_id,tokens{end},s)];
    end
end

function optSetting=getOptSettingFromToolChain(ccm)
    optSetting=[];

    if~ccm.PolySpaceForCodeMetrics||...
        ~ccm.getToolchainDependentCodeMetricsFeature()
        return;
    end

    optSetting='none';



    if((isobject(ccm)&&isprop(ccm,'ModelName'))||(isfield(ccm,'ModelName')))...
        &&(bdIsLoaded(ccm.ModelName))
        toolchain=i_getToolchain(ccm.ModelName);
    else
        toolchain=i_getDefaultToolchain;
    end

    if contains(toolchain,'MinGW64')&&strfind(toolchain,'MinGW64')==1
        optSetting='mingw64';
    end
    if(contains(toolchain,'GNU gcc/g++')&&strfind(toolchain,'GNU gcc/g++')==1)||...
        (contains(toolchain,'Clang')&&(strfind(toolchain,'Clang')==1||strfind(toolchain,'Xcode')==1))
        optSetting='gnu8.0';
    end
    if contains(toolchain,'Microsoft Visual C++')&&strfind(toolchain,'Microsoft Visual C++')==1
        if contains(toolchain,'2019')
            optSetting='msvc16.0';
        elseif contains(toolchain,'2017')
            optSetting='msvc15.0';
        elseif contains(toolchain,'2015')
            optSetting='msvc14.0';
        elseif contains(toolchain,'2013')
            optSetting='msvc12.0';
        elseif contains(toolchain,'2012')
            optSetting='msvc11.0';
        elseif contains(toolchain,'2010')
            optSetting='msvc10.0';
        elseif contains(toolchain,'2008')
            optSetting='msvc9.0';
        else
            optSetting='msvc14.0';
        end
    end
end


function toolchain=i_getToolchain(model)



    lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;


    allowLcc=true;
    lModelCompInfo=coder.internal.ModelCompInfo.createModelCompInfo...
    (model,lDefaultCompInfo.DefaultMexCompInfo,allowLcc);



    if isempty(lModelCompInfo.ToolchainInfo)
        toolchain=i_getDefaultToolchain;
        return;
    end

    toolchain=lModelCompInfo.ToolchainInfo;
    toolchain=toolchain.Name;
end


function toolchain=i_getDefaultToolchain


    mexCompInfo=coder.make.internal.getMexCompilerInfo();
    if ispc&&isempty(mexCompInfo)
        mexCompilerKey='LCC-x';
    else
        mexCompilerKey=mexCompInfo.compStr;
    end


    toolchain=coder.make.internal.getToolchainNameFromRegistry...
    (mexCompilerKey);
end





