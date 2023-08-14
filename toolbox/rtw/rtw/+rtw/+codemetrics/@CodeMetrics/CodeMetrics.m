classdef CodeMetrics<rtw.codemetrics.C_CodeMetrics&Simulink.codemetrics.SlCodeMetrics















































    properties(SetAccess=private,Hidden=true)
        sortedFileInfo=[];
        mdlRefInfo=[];
        nonintegratedChildModels={};
        protectedChildModels={};
        refFcnList={};
    end

    properties(SetAccess=private,Hidden=true,Transient=true)
        rtwBuildInfo={};
        html_id=0;
        StartDir='';
    end
    methods







        function rtwcm=CodeMetrics(varargin)
            if nargin~=1&&nargin~=2
                DAStudio.error('RTW:report:invalidNumOfArgs');
            end
            in_buildDir=varargin{1};
            inputBuildDir='';
            inputStartDir='';

            myOption=struct('IsDebug',false,'GenDataCopy',false,...
            'IsDataCopyDetails',false,'SourceSubsystem','',...
            'IgnoreUnfoundFile',false,'FlattenedDirectory',false,...
            'IsGlobalConstantsEstimation',false,...
            'BuildDir','',...
            'StartDir','');
            if nargin==2
                option=varargin{2};
                fields=fieldnames(option);
                delta=~ismember(fields,fieldnames(myOption));
                if any(delta)
                    DAStudio.error('RTW:report:CodeMetricsInvalidOption');
                end
                if isfield(option,'IsDebug')
                    myOption.IsDebug=option.IsDebug;
                end
                if isfield(option,'GenDataCopy')
                    myOption.GenDataCopy=option.GenDataCopy;
                end
                if isfield(option,'SourceSubsystem')
                    myOption.SourceSubsystem=option.SourceSubsystem;
                end
                if isfield(option,'IgnoreUnfoundFile')
                    myOption.IgnoreUnfoundFile=option.IgnoreUnfoundFile;
                end
                if isfield(option,'IsDataCopyDetails')
                    myOption.IsDataCopyDetails=option.IsDataCopyDetails;
                end
                if isfield(option,'IsGlobalConstantsEstimation')
                    myOption.IsGlobalConstantsEstimation=option.IsGlobalConstantsEstimation;
                end
                if isfield(option,'FlattenedDirectory')
                    myOption.FlattenedDirectory=option.FlattenedDirectory;
                end
                if isfield(option,'BuildDir')
                    inputBuildDir=option.BuildDir;
                end
                if isfield(option,'StartDir')
                    inputStartDir=option.StartDir;
                end

            end
            if ischar(in_buildDir)
                buildDir=in_buildDir;
                if~exist(buildDir,'dir')
                    buildDir=inputBuildDir;
                end
                if~exist(buildDir,'dir')
                    DAStudio.error('RTW:utility:dirDoesNotExist',buildDir);
                end
                libFolder=coder.internal.rte.SDPTypes.getFunctionPlatformFolders(...
                buildDir).libFolder;
                if exist(fullfile(libFolder,'buildInfo.mat'),'file')

                    load(fullfile(libFolder,'buildInfo.mat'),'buildInfo');
                elseif exist(fullfile(buildDir,'buildInfo.mat'),'file')
                    load(fullfile(buildDir,'buildInfo.mat'),'buildInfo');
                else
                    DAStudio.error('RTW:buildProcess:buildDirInvalid',buildDir);
                end
            elseif isa(in_buildDir,'RTW.BuildInfo')
                buildInfo=in_buildDir;
                buildDir=buildInfo.getLocalBuildDir();
                if~exist(buildDir,'dir')
                    buildDir=inputBuildDir;
                end
                if isempty(buildDir)
                    DAStudio.error('RTW:report:CodeMetricsInvalidConstructInput');
                end
            else
                DAStudio.error('RTW:report:CodeMetricsInvalidConstructInput');
            end

            if~exist(buildInfo.Settings.LocalAnchorDir,'dir')
                buildInfo.Settings.LocalAnchorDir=inputStartDir;
            end



            tmpModelName=buildInfo.ModelName;
            rtwcm=rtwcm@Simulink.codemetrics.SlCodeMetrics(tmpModelName,buildDir,myOption.SourceSubsystem);

            rtwcm=rtwcm@rtw.codemetrics.C_CodeMetrics({},[],{},[],slfeature('PolySpaceForCodeMetrics'));





            if~isempty(rtwcm.sourceSubsystem)
                sys=rtwcm.sourceSubsystem;
            else
                sys=rtwcm.ModelName;
            end
            reportInfo=rtw.report.getReportInfo(sys,rtwcm.BuildDir);
            if strcmp('C++',reportInfo.TargetLang)
                rtwcm.targetisCPP=true;
                rtwcm.setCodeMetricsOption([]);
            end

            rtwcm.StartDir=inputStartDir;
            rtwcm.bDebug=myOption.IsDebug;
            rtwcm.bGenDataCopy=myOption.GenDataCopy;
            rtwcm.bIgnoreUnfoundFile=myOption.IgnoreUnfoundFile;
            rtwcm.bDataCopyDetails=myOption.IsDataCopyDetails;
            rtwcm.bGlobalConstantsEstimation=myOption.IsGlobalConstantsEstimation;
            rtwcm.rtwBuildInfo={};
            rtwcm.sortedFileInfo=[];
            rtwcm.mdlRefInfo=containers.Map;
            rtwcm.nonintegratedChildModels={};
            rtwcm.protectedChildModels={};
            rtwcm.setBuildInfo(buildInfo);
            rtwcm.createCodeMetricsOptionFromModel;
            if myOption.FlattenedDirectory
                rtwcm.setFileListFlatDirectory();
            else
                rtwcm.setFileList();
            end
            rtwcm.setMdlRefStat(myOption.SourceSubsystem);

            rtwcm.calculateCodeMetrics();
            rtwcm.createFcnInfoMap();
        end
    end

    methods(Hidden=true)





        function fileInfo=getReportFileInfo(rtwcm)
            allfiles={rtwcm.FileInfo.Name};
            rptSrcFiles=rtwcm.reportFileList;
            [~,tf]=intersect(allfiles,rptSrcFiles);
            fileInfo=rtwcm.FileInfo(tf);
        end
        function csObj=getConfigsetObj(obj)
            csObj=obj.configsetObj;
        end




        function str=getBasicTypeString(rtwcm)
            options=rtwcm.CodeMetricsOption.Target;
            types={'char','short','int','long','float','double','pointer'};
            nbit=[options.CharNumBits,options.ShortNumBits,options.IntNumBits,...
            options.LongNumBits,options.FloatNumBits,options.DoubleNumBits,...
            options.PointerNumBits];
            str='';
            for i=1:length(types)
                str=[str,'<b>',types{i},'</b> ',num2str(nbit(i)),', '];%#ok
            end
            str=[str(1:end-2),' bits'];
        end
    end

    methods(Access=protected)




        function createCodeMetricsOptionFromModel(rtwcm)
            cs=rtwcm.configsetObj;
            if strcmp(cs.get_param('ProdEqTarget'),'on')
                target='Prod';
            else
                target='Target';
            end
            cmOption=rtwcm.CodeMetricsOption;
            ProdEndianess=cs.get_param('ProdEndianess');
            if strcmp(ProdEndianess,'BigEndian')
                cmOption.Target.Endianness='big';
            else
                cmOption.Target.Endianness='little';
            end
            charNumBits=cs.get_param([target,'BitPerChar']);
            cmOption.Target.CharNumBits=charNumBits;
            shortNumBits=cs.get_param([target,'BitPerShort']);
            cmOption.Target.ShortNumBits=shortNumBits;
            intNumBits=cs.get_param([target,'BitPerInt']);
            cmOption.Target.IntNumBits=intNumBits;
            longNumBits=cs.get_param([target,'BitPerLong']);
            cmOption.Target.LongNumBits=longNumBits;
            cmOption.Target.FloatNumBits=cs.get_param([target,'BitPerFloat']);
            cmOption.Target.DoubleNumBits=cs.get_param([target,'BitPerDouble']);
            cmOption.Target.PointerNumBits=cs.get_param([target,'BitPerPointer']);
            wordSize=cs.get_param([target,'WordSize']);

            cmOption.Preprocessor.Defines=rtw.codemetrics.C_CodeMetrics.getMacrosForTarget(...
            charNumBits,shortNumBits,intNumBits,longNumBits,wordSize);


            if rtwcm.PolySpaceForCodeMetrics
                rtwcm_rtwBuildInfo_getDefines_D=reshape(strrep(rtwcm.rtwBuildInfo.getDefines,'-D',''),length(strrep(rtwcm.rtwBuildInfo.getDefines,'-D','')),1);
                if~isempty(rtwcm.optSetting)&&contains(rtwcm.optSetting,'msvc')
                    cmOption.Preprocessor.Defines{end+1}=' _POSIX_C_SOURCE=200112L';
                    cmOption.Preprocessor.Defines{end+1}=' _LIBCPP_SUPPORT_WIN32_MATH_WIN32_H=1';


                    cmOption.Preprocessor.Defines{end+1}='__LCC__';
                end
                cmOption.Preprocessor.Defines=[cmOption.Preprocessor.Defines;rtwcm_rtwBuildInfo_getDefines_D];

                if~rtwcm.targetisCPP&&strcmp(cs.get_param('TargetLangStandard'),'C99 (ISO)')
                    cmOption.Language.LanguageExtra{end+1}='--c99';
                elseif rtwcm.targetisCPP&&strcmp(cs.get_param('TargetLangStandard'),'C++11 (ISO)')
                    cmOption.Language.LanguageExtra{end+1}='--c++11';
                end

            else
                cmOption.Preprocessor.Defines=[cmOption.Preprocessor.Defines,strrep(rtwcm.rtwBuildInfo.getDefines,'-D','')];
            end
            incDir=getIncludePaths(rtwcm.rtwBuildInfo,true);
            for i=1:length(incDir)
                aPath=incDir{i};
                if~isempty(aPath)&&aPath(1)=='.'

                    aPath=rtwcm.getFileFullName(fullfile(rtwcm.BuildDir,aPath));
                    if~isempty(aPath)
                        incDir{i}=aPath;
                    end
                end
            end
            if exist(rtwcm.rtwBuildInfo.Settings.LocalAnchorDir,'dir')
                incDir=strrep(incDir,'$(MASTER_ANCHOR_DIR)',rtwcm.rtwBuildInfo.Settings.LocalAnchorDir);
            end
            cmOption.Preprocessor.IncludeDirs=incDir;

            [key,val]=rtwcm.rtwBuildInfo.findBuildArg('GENERATE_ERT_S_FUNCTION');
            if~isempty(key)&&strcmp(val,'1')
                cmOption.Preprocessor.Defines{end+1}='MATLAB_MEX_FILE';
            end


            rtwcm.setCodeMetricsOption(cmOption);
        end





        function setFileList(rtwcm)
            buildInfoHdrFile=rtwcm.rtwBuildInfo.getIncludeFiles(true,true);
            if~isempty(rtwcm.sourceSubsystem)
                sys=rtwcm.sourceSubsystem;
            else
                sys=rtwcm.ModelName;
            end




            reportInfo=rtw.report.getReportInfo(sys,rtwcm.BuildDir);
            rtwcm.sortedFileInfo=reportInfo.getSortedFileInfoList;
            fileInfo=reportInfo.getFileInfo;

            rtwcm.sortedFileInfo.HtmlFileName=...
            coder.internal.coderReport(...
            'getDestHTMLFileName',rtwcm.sortedFileInfo.HtmlFileName,...
            rtwcm.BuildDir);
            fileList={};
            for i=1:length(fileInfo)

                if strcmp(fileInfo(i).Tag,'In-the-Loop:Host')...
                    ||strcmp(fileInfo(i).Tag,'In-the-Loop:HostTimer')...
                    ||strcmp(fileInfo(i).Tag,'Instrumentation:Stubs')
                    rtwcm.ExcludedFiles{end+1}=fileInfo(i).FileName;
                    continue;
                end

                if strcmp(fileInfo(i).Group,'main')
                    rtwcm.ExcludedFiles{end+1}=fileInfo(i).FileName;
                else
                    fileList=[fileList,fullfile(fileInfo(i).Path,fileInfo(i).FileName)];%#ok
                end
            end
            rtwcm.reportFileList=fileList;




            ignore_idx=[];
            for i=1:length(buildInfoHdrFile)
                [~,~,ext]=fileparts(buildInfoHdrFile{i});
                if strcmpi(ext,'.c')
                    ignore_idx(end+1)=i;%#ok
                end
            end
            ignore_file=buildInfoHdrFile(ignore_idx);
            fileList=setdiff(fileList,ignore_file);
            rtwcm.setFile(fileList);
        end




        function setFileListFlatDirectory(rtwcm)
            buildInfoHdrFile=rtwcm.rtwBuildInfo.getIncludeFiles(false,false);
            tempList=rtwcm.rtwBuildInfo.getSourceFiles(false,false);
            fileList=tempList(cellfun('isempty',strfind(tempList,'_main.c')));
            rtwcm.reportFileList=fileList;




            ignore_idx=[];
            for i=1:length(buildInfoHdrFile)
                [~,~,ext]=fileparts(buildInfoHdrFile{i});
                if strcmpi(ext,'.c')
                    ignore_idx(end+1)=i;%#ok
                end
            end
            ignore_file=buildInfoHdrFile(ignore_idx);
            fileList=setdiff(fileList,ignore_file);
            fileList=strcat([rtwcm.BuildDir,filesep],fileList);
            rtwcm.setFile(fileList);
            rtwcm.rtwBuildInfo.addSourcePaths(rtwcm.BuildDir);
            rtwcm.rtwBuildInfo.addIncludePaths(rtwcm.BuildDir);
        end





        function setBuildInfo(rtwcm,buildInfo)
            rtwcm.rtwBuildInfo=buildInfo;
        end
    end


    methods(Access=private)
        function title=getFunctionTitle(rtwcm,fcn,fcnName)

            title=getFunctionTitle@rtw.codemetrics.C_CodeMetrics(rtwcm,fcn,fcnName,[],slfeature('PolySpaceForCodeMetrics'));
            if ismember(fcn,rtwcm.refFcnList)
                title=[fcn,rtwcm.msgs.mdlref_fcn_msg,title];
            end
        end
        function out=getHTMLFileName(rtwcm,fullFileName)
            out=ccm.sortedFileInfo.HtmlFileName(ismember(rtwcm.sortedFileInfo.FileName,fullFileName));
            if~isempty(out)&&iscell(out)
                out=out{1};
            end
        end
        function out=getHTMLReportFileName(rtwcm)
            out=rtwcm.sortedFileInfo.HTMLFileName;
        end
        function out=getReportFileName(rtwcm)
            out=rtwcm.sortedFileInfo.FileName;
        end
        function out=getOnloadJSFcn(~)
            out=coder.internal.coderReport('getOnloadJS','rtwIdCodeMetrics');
        end
        function bGenHyperlink=getGenHyperlinkFlag(ccm)
            bGenHyperlink=ccm.bGenHyperlink;
        end
        function title=getTitle(rtwcm)
            title=[rtwcm.msgs.reportTitle,rtwcm.getDisplayModelName];
        end




        function introduction=getHTMLIntroduction(rtwcm)
            rptFileName=fullfile(rtwcm.ReportDir,rtwcm.ReportFileName);
            intro_msg=sprintf(rtwcm.msgs.intro_msg,rtwcm.getBasicTypeString);
            imgBytes='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADhElEQVQ4T2WTe0yTBxTFz/fRIn2AqS1LC4gplIcFYYkTxjTpiMQRJo50KhYmexkkIWwsTMtIFCWMAZuFoc7nXNiWbLhibdMtA4oL7hFskI7KoxOGLbRCulEeK5Ty9WsXMRDn7p8355zc3PwOgaenuI8pkW7MO7RtY9GuaJbEF4DfMO62tA+4WieVSbqn5cSTi6jGUdnp3YK6otSwDEYQSbioAB4JeEwCbq8vcM00a6i/7aqaUib2rfnWA5LPjR/WFkRejOEFsz8d9UE37oGXpkHSfoTSfsjj2XhbyoZpyuPKuzzy+sSp7fpHIasBz9SNZPSWxHSFhQZzXjYsYnZuGY3Pc5AVtQEEAvjJ6oGy8y9s3hSCm/lCmBxLrqzSK5mLunIzgVMBsiV71lCWzsuUdbhx1+rG4CE+ojlBqNRPgiQInM6JhGOeQkLjKOTPhaPtoBAV6kG96npNHiFssGSOlscZ9HaKVKj/xr4YEtr9IpzpcuB9zTSw4kfbUTEO7hBgZ/09/Gal0XMsHtGbyBXpca2MeK3dfukreWSxXDcDjdmNcCYFRSwTavM8Hs74IYsNwY2jEix5KGw/2Q/nAgOlOSKcK4hGuqqvgWi+47pVtoOXmXbJjrt2D+CngYVlgKKRFcdCe2k8Vrw0Xm0w4baNApgbkJMchu+PJaLgG4uGqP3F2VG1M3zPC83j6P1zEQjCqpnj88JckwIBJwh7ThpxZ8IH8EMBD41XUrm4WSHFgdYhNfFSq/XDH4u2VB1pteFzgxPgkAAVQDjLj5GPnsXX3ZMov/YAEPEAkgRcS6iWR6A6X4yEyh9OENwTvyfdq9hqnHZ62Rm1w0Aw4/EVHi8U29iw2BdhmiEAbsjqQ9nLbgydSYdjhZ7bVViXvcpBic5x5UJuxBHltzY0ahwAi4FYAQMDtakwjs1jd/0wAkwmMLOAprckKM8TI/fjzi/1LVdLHpN4vD/iuzfjevYnciXV1634RGeHj6Jw/g0xzA8WcFYzAb6AhWpFDMr2idHSM2F5t7KpEL3N/esoc9/pSP6sUNp2OC1KOjblQdvPDzF43wWCCCBtKx/5skiI+CFQ3bIOKeu+eM/XXdO1jvJaMdjF7aLsFOEHZXtTFC9u4QrW9jSArvvz003qX7Wd2u4LMKoG/lem/9Q0V5WUtJknSxCyRQE/yOGpf5x/jNmMsM31Y+ys90ntv6Qkblq/pPiXAAAAAElFTkSuQmCC';
            aImg=Advisor.Element;
            aImg.setTag('img');
            aImg.setAttribute('src',imgBytes);
            aImg.setAttribute('title',rtwcm.msgs.codegen_adv_help_msg);
            aImg.setAttribute('style','border:none;cursor:pointer;max-width:100%;');
            aImg.setAttribute('alt','help.png');

            aLink=Advisor.Element;
            aLink.setContent(aImg.emitHTML);
            aLink.setTag('a');
            aLink.setAttribute('name','MATLAB_link');
            aLink.setAttribute('style','text-decoration: none');
            aLink.setAttribute('href','matlab:helpview([docroot ''/toolbox/ecoder/helptargets.map''], ''code_gen_advisor'')');
            code_gen_adv_msg=sprintf(rtwcm.msgs.openCodeGenAdvHelp_msg,...
            aLink.emitHTML);
            intro_elem=Advisor.Element;
            intro_elem.setTag('p');
            intro_elem.setContent([intro_msg,rtwcm.msgs.disclaimer_msg,code_gen_adv_msg]);
            introduction=intro_elem.emitHTML();
            if~isempty(rtwcm.nonintegratedChildModels)
                introduction=[introduction,'<p><b>',rtwcm.msgs.missChildModel_msg,'</b></p>'];
            end

        end





        function fcnTable=getHTMLFcnInfo(rtwcm)
            bRptLOC=true;


            savedFcnInfoMap=rtwcm.FcnInfoMap;
            stack_table=rtwcm.getHTMLMemoryMetrics('Stack Size',bRptLOC);
            fcnInfo_table=rtwcm.getHTMLFcnInfoTableView();
            rtwcm.FcnInfoMap=savedFcnInfoMap;

            tblFormat='fcnInfo_table';
            treeFormat='fcnInfo_calltree';
            tbl_view=Advisor.Table(2,1);
            link=Advisor.Element;
            link.setContent(rtwcm.msgs.call_tree_msg);
            link.setTag('a');
            link.setAttribute('href',['javascript:if (top) if (top.rtwSwitchView) top.rtwSwitchView(window.document,''',tblFormat,''', ''',treeFormat,''')']);
            link.setAttribute('title',rtwcm.msgs.switch2tree);
            tbl_view.setEntry(1,1,[rtwcm.msgs.view_msg,link.emitHTML,' | ',rtwcm.msgs.table_msg]);
            tbl_view.setEntry(2,1,fcnInfo_table.emitHTML);
            tbl_view.setBorder(0);
            tbl_view.setAttribute('width','100%');
            tbl_view.setAttribute('cellpadding','0');
            tbl_view.setAttribute('cellspacing','0');
            tbl_view.setAttribute('name',tblFormat);
            tbl_view.setAttribute('id',tblFormat);
            tbl_view.setAttribute('style','display: none');

            link=Advisor.Element;
            link.setContent(rtwcm.msgs.table_msg);
            link.setTag('a');
            link.setAttribute('href',['javascript:if (top) if (top.rtwSwitchView) top.rtwSwitchView(window.document,''',treeFormat,''', ''',tblFormat,''')']);
            link.setAttribute('title',rtwcm.msgs.switch2table);
            tree_view=Advisor.Table(2,1);
            tree_view.setEntry(1,1,[rtwcm.msgs.view_msg,rtwcm.msgs.call_tree_msg,' | ',link.emitHTML]);
            tree_view.setEntry(2,1,stack_table.emitHTML);
            tree_view.setBorder(0);
            tree_view.setAttribute('width','100%');
            tree_view.setAttribute('cellpadding','0');
            tree_view.setAttribute('cellspacing','0');
            tree_view.setAttribute('name',treeFormat);
            tree_view.setAttribute('id',treeFormat);
            if isempty(rtwcm.RecursiveFcnIdx)
                fcnTable=Advisor.Table(2,1);
            else
                fcnTable=Advisor.Table(3,1);
                fcnTable.setEntry(3,1,rtwcm.msgs.recursion_footnote);
            end
            fcnTable.setEntry(1,1,tree_view.emitHTML);
            fcnTable.setEntry(2,1,tbl_view.emitHTML);
            fcnTable.setBorder(0);
            fcnTable.setAttribute('width','100%');
            fcnTable.setAttribute('cellpadding','0');
            fcnTable.setAttribute('cellspacing','0');
        end





        function table=getHTMLFcnInfoTableView(rtwcm)
            fcns={rtwcm.FcnInfo.Name};
            n=length(fcns);
            col1=cell(n,1);
            col2=cell(n,1);
            col3=cell(n,1);
            col4=cell(n,1);
            col5=cell(n,1);
            col6=cell(n,1);
            col7=cell(n,1);
            option.HasHeaderRow=false;
            option.HasBorder=false;
            for i=1:length(fcns)
                fcnInfo=rtwcm.FcnInfo(i);
                if~isempty(fcnInfo.Caller)
                    ttbl=Advisor.Table(length(fcnInfo.Caller),1);
                    ttbl.setBorder(0);
                    ttbl.setAttribute('width','100%');
                    ttbl.setAttribute('cellpadding','1');
                    ttbl.setAttribute('cellspacing','0');
                    for j=1:length(fcnInfo.Caller)
                        fcn=fcnInfo.Caller(j).Name;
                        fcnlink=rtwcm.getFcnNameWithHyperlink(fcn);
                        child=fcnInfo.Name;
                        nCalled=fcnInfo.Caller(j).Weight;
                        textFcn=addNumOfCalls(fcnlink,child,fcn,nCalled);
                        ttbl.setEntry(j,1,textFcn);
                    end
                    col2{i}=ttbl.emitHTML;
                else
                    col2{i}='';
                end
                if fcnInfo.HasDefinition
                    col1{i}=rtwcm.getFcnNameWithHyperlink(fcnInfo.Name);
                    col5{i}=int2str(fcnInfo.NumCodeLines);
                    col6{i}=int2str(fcnInfo.NumTotalLines);
                    col7{i}=int2str(fcnInfo.Complexity);
                    col3{i}=int2str(fcnInfo.StackTotal);
                    if ismember(fcnInfo.Idx,rtwcm.RecursiveFcnIdx)
                        col3{i}=sprintf(rtwcm.msgs.recursion_tooltip,[col3{i},'*']);
                    end
                    col4{i}=int2str(fcnInfo.Stack);
                else
                    col1{i}=fcnInfo.Name;
                    col3{i}=rtwcm.msgs.missing_def;
                    col4{i}='-';
                    col5{i}='-';
                    col6{i}='-';
                    col7{i}='-';
                end
            end
            [~,I]=sort(fcns);
            col1=col1(I);
            col2=col2(I);
            col3=col3(I);
            col4=col4(I);
            col5=col5(I);
            col6=col6(I);
            col7=col7(I);
            col3=strrep(col3,'-1',['<i>',rtwcm.msgs.recursion_msg,'</i>']);
            option.HasHeaderRow=true;
            option.HasBorder=true;
            table=rtw.report.Report.create_html_table(...
            {[{rtwcm.msgs.fcn_name_header1};col1],[{rtwcm.msgs.fcn_calledby_header};col2],...
            [{rtwcm.msgs.tStack_header};col3],...
            [{rtwcm.msgs.stack_header};col4],...
            [rtwcm.msgs.loc_header;col5],...
            [rtwcm.msgs.lines_header;col6],...
            [rtwcm.msgs.complexity_header;col7]},...
            option,[2,2,1,1,1,1,1],{'left','left','right','right','right','right','right'});
        end





        function table=getHTMLMemoryMetrics(rtwcm,metrics,bRptLOC)
            root_fcn=rtwcm.getCallGraphRoot();
            fcns={rtwcm.FcnInfo.Name};
            [~,loc]=intersect(fcns,root_fcn);

            switch metrics
            case 'Data Copy'
                dataCopyTotal=[rtwcm.FcnInfo.DataCopyTotal];
                dataCopyTotal=dataCopyTotal(loc);
                [~,I]=sort(dataCopyTotal,'descend');
                root_fcn=root_fcn(I);
                col2={rtwcm.msgs.tdcopy_header};
                col3={rtwcm.msgs.dcopy_header};
            case 'Stack Size'
                stackTotal=[rtwcm.FcnInfo.StackTotal];
                stackTotal=stackTotal(loc);
                [~,I]=sort(stackTotal,'descend');
                root_fcn=root_fcn(I);
                col2={rtwcm.msgs.tStack_header};
                col3={rtwcm.msgs.stack_header};
            end
            recursiveFcnList=fcns(rtwcm.RecursiveFcnIdx);
            if~isempty(recursiveFcnList)
                root_fcn=[root_fcn,setdiff(recursiveFcnList,root_fcn)];
            end
            tables=Advisor.Table(1+length(root_fcn),1);
            tables.setBorder(0);
            tables.setAttribute('width','100%');
            tables.setAttribute('cellpadding','0');
            tables.setAttribute('cellspacing','0');
            option.HasHeaderRow=true;
            option.HasBorder=false;
            col1={rtwcm.msgs.fcn_name_header};
            col4={rtwcm.msgs.loc_header};
            col5={rtwcm.msgs.lines_header};
            col6={rtwcm.msgs.complexity_header};
            if bRptLOC
                entryTable=rtw.report.Report.create_html_table(...
                {col1,col2,col3,col4,col5,col6},option,...
                [3,1,1,1,1,1],{'left','right','right','right','right','right'});
            else
                entryTable=rtw.report.Report.create_html_table(...
                {col1,col2,col3},...
                option,[3,1,1],{'left','right','right'});
            end
            tables.setEntry(1,1,entryTable.emitHTML);
            row=0;
            for i=1:length(root_fcn)
                fcn=root_fcn{i};
                groupId='';
                fcnVisited={};
                if i==1
                    nodePosition='first';
                else
                    nodePosition='';
                end
                [subTable,row]=getSubFcnTable(rtwcm,fcn,'',0,0,metrics,groupId,row,fcnVisited,false,nodePosition,bRptLOC);
                tables.setEntry(i+1,1,subTable.emitHTML);
            end
            option.HasHeaderRow=false;
            option.HasBorder=true;
            option.BeginWithWhiteBG=true;

            table=rtw.report.Report.create_html_table({{''}},option,1,'left');
            table.setAttribute('cellspacing','0');
            table.setAttribute('cellpadding','0');
            table.setEntry(1,1,tables.emitHTML);
        end






        function txt=getFcnNameWithHyperlink(rtwcm,fcn)
            txt=fcn;
            if rtwcm.FcnInfoMap.isKey(fcn)
                aElement=Advisor.Element;
                aElement.setTag('span');
                title='';

                if rtwcm.FcnInfoMap(fcn).IsStatic
                    fcnName=rtw.codemetrics.C_CodeMetrics.getIdentifierOrigName(rtwcm.FcnInfoMap(fcn).Name);
                    [~,file,ext]=fileparts(rtwcm.FcnInfoMap(fcn).File{1});
                    title=sprintf(rtwcm.msgs.staticFcn_tooltip,fcnName,[file,ext]);
                else
                    fcnName=fcn;
                end
                if rtwcm.bGenHyperlink
                    fullFileName=rtwcm.FcnInfoMap(fcn).File;
                    htmlfilename=rtwcm.sortedFileInfo.HtmlFileName(ismember(rtwcm.sortedFileInfo.FileName,fullFileName));
                    if iscell(htmlfilename)&&~isempty(htmlfilename)
                        htmlfilename=htmlfilename{1};

                        aElement.setTag('a');


                        if Simulink.report.ReportInfo.featureReportV2
                            aElement.setAttribute('href','javascript: void(0)');
                            aElement.setAttribute('onclick',coder.report.internal.getPostParentWindowMessageCall('jumpToCode',fcnName));
                        else
                            aElement.setAttribute('href',[htmlfilename,'#fcn_',fcnName]);
                        end
                    end
                    if ismember(fcn,rtwcm.refFcnList)
                        title=[fcn,rtwcm.msgs.mdlref_fcn_msg,title];
                    end
                end
                aElement.setContent(fcnName);
                if~isempty(title)
                    aElement.setAttribute('title',title);
                end
                txt=aElement.emitHTML;
            end
        end





        function[table,row,fcnVisited,myTotal]=getSubFcnTable(rtwcm,fcn,~,...
            ~,lvl,metrics,groupId,row,fcnVisited,ignoreChild,...
            nodePosition,bRptLOC)
            if~rtwcm.FcnInfoMap.isKey(fcn)
                return;
            end
            if isempty(fcnVisited)
                isRootFcn=true;
                bVisited=false;
            else
                isRootFcn=false;
                bVisited=ismember(fcn,fcnVisited);
            end
            fcnlink=rtwcm.getFcnNameWithHyperlink(fcn);
            textFcn=fcnlink;

            switch metrics
            case 'Data Copy'
                self=rtwcm.FcnInfoMap(fcn).DataCopy;
            case 'Stack Size'
                self=rtwcm.FcnInfoMap(fcn).Stack;
            end
            sloc=rtwcm.FcnInfoMap(fcn).NumCodeLines;
            tsloc=rtwcm.FcnInfoMap(fcn).NumTotalLines;
            complexity=rtwcm.FcnInfoMap(fcn).Complexity;
            id=rtwcm.getUniqueID();
            if isempty(rtwcm.FcnInfoMap(fcn).Callee)||ignoreChild
                children={};
                weight=[];
            else
                callee=rtwcm.FcnInfoMap(fcn).Callee;

                children={callee.Name};
                weight=[callee.Weight];




            end

            if~isempty(children)

                accum_metrs=zeros(size(children));
                for i=1:length(children)
                    switch metrics
                    case 'Data Copy'
                        num=rtwcm.FcnInfoMap(children{i}).DataCopyTotal;
                    case 'Stack Size'
                        num=rtwcm.FcnInfoMap(children{i}).StackTotal;
                    end
                    accum_metrs(i)=num;
                end

                [~,tf]=sort(accum_metrs,'descend');
                children=children(tf);
                weight=weight(tf);

                option.UseSymbol=true;
                option.ShowByDefault=true;
                option.tooltip=rtwcm.msgs.shrink_button_tooltip;
                button=rtw.report.Report.getRTWTableShrinkButton(id,option);
            else
                prefix='&#160;&#160;';
                button=['&#160;<span style="font-family:monospace">',prefix,'</span>&#160;'];
            end
            indent='';
            indent(1:lvl*6)=' ';
            indent=strrep(indent,' ','&#160;');
            indent=[indent,button];
            if isRootFcn
                col1=['<b>',textFcn,'</b>'];
            else
                col1=textFcn;
            end
            col1={['<span style="white-space:nowrap">',indent,'&#160;',col1,'</span>']};
            option.HasHeaderRow=false;
            option.HasBorder=false;
            if mod(row,2)
                option.BeginWithWhiteBG=false;
            else
                option.BeginWithWhiteBG=true;
            end
            row=row+1;
            table=Advisor.Table(1+length(children),1);
            if lvl>0
                table.setAttribute('style','display: none; border-style: none');
            else
                table.setAttribute('style','border-style: none');
            end
            fcnVisited=[fcnVisited,fcn];
            table.setBorder(0);
            table.setAttribute('width','100%');
            table.setAttribute('cellpadding','0');
            table.setAttribute('cellspacing','0');
            table.setAttribute('name',groupId);
            table.setAttribute('id',groupId);
            myTotal=self;
            nSum=0;
            nMax=0;
            for i=1:length(children)
                nCalled=weight(i);
                bIgnore=ismember(children{i},fcnVisited);
                [subTable,row,~,cTotal]=getSubFcnTable(rtwcm,children{i},fcn,...
                nCalled,lvl+1,metrics,id,row,fcnVisited,...
                bIgnore,nodePosition,bRptLOC);
                if~bIgnore
                    nSum=nSum+nCalled*cTotal;
                    if cTotal>nMax
                        nMax=cTotal;
                    end
                end
                table.setEntry(i+1,1,subTable.emitHTML);
            end
            switch metrics
            case 'Data Copy'
                myTotal=myTotal+nSum;
            case 'Stack Size'
                myTotal=myTotal+nMax;
            end


            if rtwcm.FcnInfoMap(fcn).HasDefinition
                col3=loc_int2str(self);
                col4=loc_int2str(sloc);
                col5=loc_int2str(tsloc);
                col6=loc_int2str(complexity);
                if bVisited


                    myTotal=0;
                    col2={['<i>',rtwcm.msgs.recursion_msg,'</i>']};
                else
                    col2=loc_int2str(myTotal);
                    if ismember(rtwcm.FcnInfoMap(fcn).Idx,rtwcm.RecursiveFcnIdx)
                        col2{1}=sprintf(rtwcm.msgs.recursion_tooltip,[col2{1},'*']);
                    end
                end


                fcnInfo=rtwcm.FcnInfoMap(fcn);
                switch metrics
                case 'Data Copy'
                    fcnInfo.DataCopyTotal=myTotal;
                case 'Stack Size'
                    fcnInfo.StackTotal=myTotal;
                end
                rtwcm.FcnInfoMap(fcn)=fcnInfo;
            else
                col2={rtwcm.msgs.missing_def};
                col3={'-'};
                col4={'-'};
                col5={'-'};
                col6={'-'};
            end
            if bRptLOC
                entryTable=rtw.report.Report.create_html_table(...
                {col1,col2,col3,col4,col5,col6},option,[3,1,1,1,1,1],...
                {'left','right','right','right','right','right'});
            else
                entryTable=rtw.report.Report.create_html_table({col1,col2,col3},option,[3,1,1],{'left','right','right'});
            end
            table.setEntry(1,1,entryTable.emitHTML);
        end






        function fileTable=getHTMLFileInfo(rtwcm)
            tables=cell(2,1);
            tableHeadings=cell(2,1);
            option.UseSymbol=true;
            option.ShowByDefault=false;
            option.tooltip=rtwcm.msgs.shrink_button_tooltip;
            id_summary='fileInfo_summary_table';


            str_mdlref='';
            str_exclmain='';
            if rtwcm.hasKnownStat>0
                str_mdlref=rtwcm.msgs.mdlref_file_msg;
            end
            excludedFiles=rtwcm.ExcludedFiles;
            if~isempty(excludedFiles)
                excludedFileStr=excludedFiles{1};
                for fileIdx=2:length(excludedFiles)
                    excludedFileStr=[excludedFileStr,', ',excludedFiles{fileIdx}];%#ok<AGROW>
                end
                str_exclmain=[rtwcm.msgs.exclude_msg,excludedFileStr];
            end
            if isempty(str_mdlref)&&isempty(str_exclmain)
                summary_txt=rtwcm.msgs.summary_msg;
            elseif~isempty(str_mdlref)&&~isempty(str_exclmain)
                summary_txt=[rtwcm.msgs.summary_msg,' (',str_mdlref,', ',str_exclmain,')'];
            else
                summary_txt=[rtwcm.msgs.summary_msg,' (',str_mdlref,str_exclmain,')'];
            end

            tableHeadings{1}=Advisor.Paragraph([rtw.report.Report.getRTWTableShrinkButton(id_summary,option),' ',summary_txt]);

            id_details='fileInfo_detail_table';

            rptFileInfo=rtwcm.getReportFileInfo();
            allfiles={rptFileInfo.Name};

            tableHeadings{2}=Advisor.Paragraph([rtw.report.Report.getRTWTableShrinkButton(id_details,option),' ',rtwcm.msgs.file_detail_msg]);
            [fullFileName,tf]=intersect(rtwcm.sortedFileInfo.FileName,allfiles);
            htmlfiles=rtwcm.sortedFileInfo.HtmlFileName(tf);
            file_no_html=setdiff(allfiles,fullFileName);
            if rtwcm.hasKnownStat
                mdlRefFileList={rtwcm.KnownStat.FileInfo.Name};
            else
                mdlRefFileList={};
            end
            files=[fullFileName,file_no_html];

            mdlRefFiles=setdiff(mdlRefFileList,files);
            files=[files,mdlRefFiles];

            htmlfiles=[htmlfiles,cell(1,length(mdlRefFiles)+length(file_no_html))];

            fileCol=cell(size(files));
            numTotalLOC=zeros(size(files));
            numSLOC=zeros(size(files));
            mdlref_name=cell(size(files));
            dates=cell(size(files));

            nCFiles=0;
            nHFiles=0;
            nSLOC=0;
            nTotalLOC=0;
            mdlFileList={rptFileInfo.Name};
            for k=1:length(files)
                fileName=files{k};
                [aPath,aName,aExt]=fileparts(fileName);
                if k<=length(fullFileName)+length(file_no_html)

                    if strcmp(aPath,rtwcm.BuildDir)
                        mdlref_name{k}=' ';
                    else
                        mdlref_name{k}=['<i>',rtwcm.msgs.share_msg,'</i>'];
                    end
                    [tf,loc]=ismember(fileName,mdlFileList);
                    assert(tf==true)
                    aFileInfo=rptFileInfo(loc);
                else

                    [tf,loc]=ismember(fileName,mdlRefFileList);
                    assert(tf==true);
                    aFileInfo=rtwcm.KnownStat.FileInfo(loc);
                    refMdlName=aFileInfo.MdlRef;
                    aElement=Advisor.Element;
                    aElement.setContent(refMdlName);
                    aElement.setTag('a');
                    aElement.setAttribute('target','_top');
                    href_value=coder.internal.coderReport('getDestHTMLFileName',...
                    fullfile(rtwcm.mdlRefInfo(refMdlName),[refMdlName,'_codegen_rpt.html']),...
                    rtwcm.BuildDir);
                    aElement.setAttribute('href',href_value{1});
                    mdlref_name{k}=aElement.emitHTML;
                end
                numTotalLOC(k)=aFileInfo.NumTotalLines;
                numSLOC(k)=aFileInfo.NumCodeLines;
                dates{k}=datestr(aFileInfo.Datenum,'mm/dd/yyyy HH:MM PM');
                if rtwcm.bGenHyperlink&&~isempty(htmlfiles{k})
                    fileNameEntry=Advisor.Element;
                    fileNameEntry.setTag('a');
                    fileNameEntry.setAttribute('href',htmlfiles{k});
                    fileNameEntry.setContent([aName,aExt])
                    fileCol{k}=fileNameEntry.emitHTML;
                else
                    fileCol{k}=[aName,aExt];
                end

                if strcmpi(aExt,'.c')
                    nCFiles=nCFiles+1;
                elseif strcmpi(aExt,'.h')||strcmpi(aExt,'.hpp')
                    nHFiles=nHFiles+1;
                else
                    continue;
                end
                nSLOC=nSLOC+aFileInfo.NumCodeLines;
                nTotalLOC=nTotalLOC+aFileInfo.NumTotalLines;
            end


            [numSLOC,tf]=sort(numSLOC,'descend');
            fileCol=fileCol(tf);
            numTotalLOC=numTotalLOC(tf);
            slocs=loc_int2str(numSLOC)';
            sizes=loc_int2str(numTotalLOC)';
            dates=dates(tf);
            mdlref_name=mdlref_name(tf);
            col1={rtwcm.msgs.c_file_header,...
            rtwcm.msgs.h_file_header,...
            rtwcm.msgs.loc,...
            rtwcm.msgs.lines_header...
            };
            col2={':',':',':',':'};
            col3=[loc_int2str(nCFiles),...
            loc_int2str(nHFiles),...
            loc_int2str(nSLOC),...
            loc_int2str(nTotalLOC)...
            ];
            option.HasHeaderRow=false;
            option.HasBorder=false;
            table=rtw.report.Report.create_html_table({col1,col2,col3,cell(size(col2))},option,[1,1,1,20],{'left','left','right','right'});
            table.setStyle('Default');
            table.setAttribute('width','50%');
            table.setAttribute('cellpadding','0');
            table.setAttribute('name',id_summary);
            table.setAttribute('id',id_summary);
            tables{1}=table;

            col1=[rtwcm.msgs.file_name_header,fileCol];
            col2=[rtwcm.msgs.loc_header,slocs];
            col3=[rtwcm.msgs.lines_header,sizes];
            col4=[rtwcm.msgs.mdlref_header,mdlref_name];
            col5=[rtwcm.msgs.modified_date_header,dates];
            option.HasHeaderRow=true;
            option.HasBorder=true;
            if rtwcm.hasKnownStat>0
                table=rtw.report.Report.create_html_table({col1,col2,col3,col4,col5},option,[2,1,1,1,1],{'left','right','right','right','right'});
            else
                table=rtw.report.Report.create_html_table({col1,col2,col3,col5},option,[3,2,2,2],{'left','right','right','right'});
            end
            table.setAttribute('name',id_details);
            table.setAttribute('id',id_details);
            tables{2}=table;
            fileTable=Advisor.Table(2,1);
            fileTable.setBorder(0);
            fileTable.setAttribute('width','100%');
            for i=1:length(tables)
                fileTable.setEntry(i,1,[tableHeadings{i}.emitHTML,tables{i}.emitHTML]);
            end
        end





        function class_table=getHTMLClassMember(rtwcm)
        end

        function globalvar_table=getHTMLGlobalVariable(rtwcm)
            vars={rtwcm.GlobalVarInfo.Name};
            sizes=[rtwcm.GlobalVarInfo.Size];
            files={rtwcm.GlobalVarInfo.File};
            if rtwcm.hasKnownStat
                mdlRefVarList={rtwcm.KnownStat.GlobalVarInfo.Name};
                mdlRefVarSizes=[rtwcm.KnownStat.GlobalVarInfo.Size];
                mdlRefFiles={rtwcm.KnownStat.GlobalVarInfo.File};
            else
                mdlRefVarList={};
                mdlRefVarSizes=[];
                mdlRefFiles=[];
            end
            [mdlRefVars,tf]=setdiff(mdlRefVarList,vars);
            varCol=[vars,mdlRefVars];
            sizes=[sizes,mdlRefVarSizes(tf)];
            files=[files,mdlRefFiles(tf)];
            mdlref_name=cell(length(varCol),1);
            for i=1:length(vars)
                title='';
                if rtwcm.GlobalVarInfo(i).IsStatic
                    var=rtw.codemetrics.C_CodeMetrics.getIdentifierOrigName(rtwcm.GlobalVarInfo(i).Name);
                    [~,file,ext]=fileparts(rtwcm.GlobalVarInfo(i).File{1});
                    title=sprintf(rtwcm.msgs.staticGlobalVar_tooltip,var,[file,ext]);
                else
                    var=vars{i};
                end
                aElement=Advisor.Element;
                aElement.setTag('span');
                aElement.setContent(var);
                if~isempty(title)
                    aElement.setAttribute('title',title);
                end
                fullFileName=files{i};
                htmlfilename=rtwcm.sortedFileInfo.HtmlFileName(ismember(rtwcm.sortedFileInfo.FileName,fullFileName));
                if rtwcm.bGenHyperlink&&iscell(htmlfilename)&&~isempty(htmlfilename)
                    htmlfilename=htmlfilename{1};
                    aElement.setTag('a');



                    if Simulink.report.ReportInfo.featureReportV2
                        aElement.setAttribute('href','javascript: void(0)');
                        aElement.setAttribute('onclick',coder.report.internal.getPostParentWindowMessageCall('jumpToCode',var));
                    else
                        aElement.setAttribute('href',[htmlfilename,'#var_',var]);
                    end
                end
                varCol{i}=aElement.emitHTML;
                mdlref_name{i}=' ';
            end
            for i=1:length(mdlRefVars)
                [~,loc]=ismember(mdlRefVars{i},mdlRefVarList);
                varInfo=rtwcm.KnownStat.GlobalVarInfo(loc);
                refMdlName=varInfo.MdlRef;
                title='';
                if varInfo.IsStatic
                    var=rtw.codemetrics.C_CodeMetrics.getIdentifierOrigName(varInfo.Name);
                    [~,file,ext]=fileparts(varInfo.File{1});
                    title=sprintf(rtwcm.msgs.staticGlobalVar_tooltip,var,[file,ext]);
                else
                    var=varInfo.Name;
                end
                aElement=Advisor.Element;
                aElement.setTag('span');
                aElement.setContent(var);
                if~isempty(title)
                    aElement.setAttribute('title',title);
                end
                varCol{i+length(vars)}=aElement.emitHTML;
                if rtwcm.bGenHyperlink&&exist(rtwcm.mdlRefInfo(refMdlName),'dir')
                    aElement=Advisor.Element;
                    aElement.setContent(refMdlName);
                    aElement.setTag('a');
                    aElement.setAttribute('target','_top');
                    href_value=coder.internal.coderReport('getDestHTMLFileName',...
                    fullfile(rtwcm.mdlRefInfo(refMdlName),[refMdlName,'_codegen_rpt.html']),...
                    rtwcm.BuildDir);
                    aElement.setAttribute('href',href_value{1});
                    mdlref_name{i+length(vars)}=aElement.emitHTML;
                else
                    mdlref_name{i+length(vars)}=refMdlName;
                end
            end
            [sizes,I]=sort(sizes,'descend');
            varCol=varCol(I);
            mdlref_name=mdlref_name(I);
            option.HasHeaderRow=true;
            option.HasBorder=true;
            col1=[rtwcm.msgs.global_var_header;varCol';'<b>Total</b>'];
            col2=[rtwcm.msgs.var_size_header;loc_int2str(sizes);strcat('<b>',loc_int2str(sum(sizes)),'</b>')];
            if isempty(mdlRefVars)
                col3=cell(size(col1));
            else
                col3=[rtwcm.msgs.mdlref_header;mdlref_name;' '];
            end
            globalvar_table=rtw.report.Report.create_html_table({col1,col2,col3},...
            option,[2,1,4],{'left','right','right'});
            id_var='globalvarInfo_table';
            globalvar_table.setAttribute('name',id_var);
            globalvar_table.setAttribute('id',id_var);
        end




        function table=getHTMLCallGraph(rtwcm,path)
            roots=rtwcm.getCallGraphRoot();
            currpwd=pwd;
            cd(path);
            try
                if ismember('main',roots)
                    figure_files=rtwcm.exportCallGraph2PNG('main');
                else
                    figure_files=rtwcm.exportCallGraph2PNG();
                end
            catch e
                cd(currpwd);
                disp(e.message);
            end
            cd(currpwd);
            if isempty(figure_files)
                table=Advisor.Table(1,1);
            else
                table=Advisor.Table(length(figure_files),1);
            end
            table.setBorder(0);
            table.setAttribute('width','100%');
            table.setAttribute('style','border-style: none');
            for i=1:length(figure_files)
                aElem=Advisor.Element;
                aElem.setTag('img');
                aElem.setAttribute('src',figure_files{i});
                table.setEntry(i,1,aElem);
            end
        end





        function table=getHTMLBasicType(rtwcm)
            options=rtwcm.CodeMetricsOption.Target;
            types={'char','short','int','long','float','double','pointer'};
            nbit=[options.CharNumBits,options.ShortNumBits,options.IntNumBits,...
            options.LongNumBits,options.FloatNumBits,options.DoubleNumBits,...
            options.PointerNumBits];
            elem=Advisor.Element;
            elem.setTag('b');
            cols=cell(length(types),1);
            aligns=cell(length(types),1);
            for i=1:length(types)
                elem.setContent(types{i});
                cols{i}={[elem.emitHTML,': ',num2str(nbit(i))]};
                aligns{i}='right';
            end
            option.HasHeaderRow=false;
            option.HasBorder=true;
            table=rtw.report.Report.create_html_table(...
            cols',option,ones(length(cols),1),aligns);
        end
    end

    methods(Access=private)





        function setMdlRefStat(rtwcm,sourceSubsystem)
            reportInfo=rtw.report.getReportInfo(sourceSubsystem,rtwcm.BuildDir);
            protectedModelList=reportInfo.TopProtectedModelReferences;
            mdlRefs=setdiff(reportInfo.ModelReferences,protectedModelList);
            for i=1:length(mdlRefs)
                mref=mdlRefs{i};
                buildDirs=reportInfo.ModelReferencesBuildDir(mref);



                mAnchorDir=coder.internal.infoMATFileMgr('getParallelAnchorDir',...
                reportInfo.ModelReferenceTargetType);
                if(~isempty(mAnchorDir)&&...
                    ~strcmp(reportInfo.ModelReferenceTargetType,'NONE'))



                    mref_buildDir=fullfile(mAnchorDir,buildDirs.ModelRefRelativeBuildDir);
                else


                    startDir=rtwcm.rtwBuildInfo.getSourcePaths(true,'StartDir');
                    startDir=startDir{1};
                    if~isempty(startDir)
                        mref_buildDir=fullfile(startDir,buildDirs.ModelRefRelativeBuildDir);
                    else
                        mref_buildDir=fullfile(buildDirs.CodeGenFolder,buildDirs.ModelRefRelativeBuildDir);
                    end
                end

                if exist(mref_buildDir,'dir')

                    if~slfeature('DecoupleCodeMetrics')
                        mref_datafile=fullfile(mref_buildDir,'html','codeMetrics.mat');
                    else
                        mref_datafile=fullfile(mref_buildDir,'tmwinternal','codeMetrics.mat');
                    end
                    if exist(mref_datafile,'file')
                        load(mref_datafile);

                        if codeMetrics.bGenDataCopy~=rtwcm.bGenDataCopy
                            bReGenMetrics=true;
                            delete(mref_datafile);
                        else
                            bReGenMetrics=false;
                        end
                    else
                        bReGenMetrics=true;
                    end
                    if bReGenMetrics
                        myOption=struct('IsDebug',rtwcm.bDebug,...
                        'GenDataCopy',rtwcm.bGenDataCopy,...
                        'IgnoreUnfoundFile',rtwcm.bIgnoreUnfoundFile,...
                        'IsDataCopyDetails',rtwcm.bDataCopyDetails,...
                        'IsGlobalConstantsEstimation',rtwcm.bGlobalConstantsEstimation,...
                        'StartDir',rtwcm.StartDir);
                        codeMetrics=rtw.codemetrics.CodeMetrics(mref_buildDir,myOption);
                        if~slfeature('DecoupleCodeMetrics')
                            refRptFolder=fullfile(mref_buildDir,'html');
                        else
                            refRptFolder=fullfile(mref_buildDir,'tmwinternal');
                        end
                        if~exist(refRptFolder,'dir')
                            rtwprivate('rtw_create_directory_path',refRptFolder);
                        end
                        save(fullfile(refRptFolder,'codeMetrics.mat'),'codeMetrics');
                    end
                    if strcmp(codeMetrics.LatestStatus.Status,'successful')

                        codeMetrics.FileInfo=codeMetrics.getReportFileInfo();

                        if~isempty(codeMetrics.FileInfo)
                            fileInfo=codeMetrics.FileInfo;
                            [fileInfo.MdlRef]=deal(codeMetrics.ModelName);
                            codeMetrics.FileInfo=fileInfo;
                        else
                            codeMetrics.FileInfo=struct('Name',{},'Idx',{},...
                            'NumCommentLines',{},'NumTotalLines',{},...
                            'NumCodeLines',{},'Datenum',{},'MdlRef',{});
                        end
                        if~isempty(codeMetrics.FcnInfo)
                            fcnInfo=codeMetrics.FcnInfo;
                            [fcnInfo.MdlRef]=deal(codeMetrics.ModelName);
                            codeMetrics.FcnInfo=fcnInfo;
                        else
                            codeMetrics.FcnInfo=struct('Name',{},'UniqueKey',{},'Idx',{},'NumCommentLines',{},...
                            'NumTotalLines',{},'NumCodeLines',{},'Callee',{},'Caller',{},'DataCopy',{},...
                            'Stack',{},'HasDefinition',{},'File',{},'DataCopyTotal',{},...
                            'StackTotal',{},'CalleeIdx',{},'IsStatic',{},'MdlRef',{},'Complexity',{});
                            if~rtwcm.bGenDataCopy
                                codeMetrics.FcnInfo=rmfield(codeMetrics.FcnInfo,{'DataCopy','DataCopyTotal'});
                            end
                        end
                        if~isempty(codeMetrics.GlobalVarInfo)
                            globalVarInfo=codeMetrics.GlobalVarInfo;
                            [globalVarInfo.MdlRef]=deal(codeMetrics.ModelName);
                            codeMetrics.GlobalVarInfo=globalVarInfo;
                        else
                            codeMetrics.GlobalVarInfo=struct('Name',{},...
                            'Size',{},'File',{},'IsStatic',{},'IsBitField',{},'IsExported',{},'UseCount',{},'Members',{},'UseInFunctions',{},'MdlRef',{});
                        end

                        if rtwcm.PolySpaceForCodeMetrics
                            if~isempty(codeMetrics.ClassMemberInfo)
                                classMemberInfo=codeMetrics.ClassMemberInfo;
                                [classMemberInfo.MdlRef]=deal(codeMetrics.ModelName);
                                codeMetrics.ClassMemberInfo=classMemberInfo;
                            else
                                codeMetrics.ClassMemberInfo=struct('Name',{},...
                                'Size',{},'File',{},'IsStatic',{},'IsBitField',{},'IsExported',{},'UseCount',{},'Members',{},'UseInFunctions',{},'MdlRef',{});
                            end
                        end
                        rtwcm.addKnownCodeMetrics(codeMetrics);
                        rtwcm.mdlRefInfo(codeMetrics.ModelName)=fullfile(mref_buildDir,'html');
                    else
                        rtwcm.nonintegratedChildModels{end+1}=mref_buildDir;
                    end
                end
            end
            for pmIter=1:length(protectedModelList)
                rtwcm.protectedChildModels{end+1}=protectedModelList{pmIter};
            end

            if rtwcm.hasKnownStat
                rtwcm.refFcnList={rtwcm.KnownStat.FcnInfo.Name};
            else
                rtwcm.refFcnList={};
            end
        end





        function id=getUniqueID(rtwcm)
            id=[rtwcm.ModelName,'_',num2str(rtwcm.html_id)];
            rtwcm.html_id=rtwcm.html_id+1;
        end
    end
end









