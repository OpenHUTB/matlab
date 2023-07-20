



classdef ReportInfo<Simulink.report.ReportInfo
    properties(Hidden=true)
HDLTraceabilityDriver

        HDLCoder;

        PIR;
        TcgInventory;

        resourceReport;

        optimizationReport;

        hdlgenerateWebview;

        ipcoreReport;

        traceability;

        traceabilityProcessing;

        CriticalPathEstimation;

        StaticLatencyPathAnalysis;

        HtmlDir;

        slprjDir;

        codeGenDirRoot;

        relCodeGenDir;
        ReportTitle;
        htmlLinkManager;
        headJs;
        libJs;

        printHyperlinksInLog;

        ObfuscateGeneratedHDLCode;
    end
    methods(Hidden)
        function lics=getLicenseRequirements(~)

            lics={'Matlab_Coder','Simulink_HDL_Coder'};
        end
    end
    methods
        function model2code(obj,block)
            obj.checkoutLicense();
            model=obj.ModelName;
            SLStudio.Utils.RemoveHighlighting(get_param(model,'handle'));
            traceInfo=slhdlcoder.TraceInfo.instance(model);
            if~isa(traceInfo,'slhdlcoder.TraceInfo')
                traceInfo=slhdlcoder.TraceInfo(model);
            end

            if isempty(traceInfo.BuildDir)
                traceInfo.setBuildDir('');
            end

            if isempty(traceInfo.getRegistry)
                traceInfo.loadTraceInfo;
            end
            traceInfo.highlight(block);
        end
    end
    methods
        function registerOptimizationReportPages(obj)
            if obj.optimizationReport
                obj.addPage(hdlcoder.report.RecommendSerialization(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                obj.addPage(hdlcoder.report.RecommendDelayBalance(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                obj.addPage(hdlcoder.report.RecommendAdaptivePipeline(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                obj.addPage(hdlcoder.report.RecommendPipeline(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                obj.addPage(hdlcoder.report.RecommendFlatteningHierarchy(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                if~strcmp(hdlgetparameter('subsystemreuse'),'off')
                    obj.addPage(hdlcoder.report.RecommendHDLNetworkReuse(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                end
            end
        end

        function registerPages(obj)
            if~isempty(obj.Pages)&&isa(obj.Pages{1},'hdlcoder.report.Summary')
                return
            end
            pages=obj.Pages;
            obj.Pages={};

            obj.addPage(hdlcoder.report.Summary(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));

            obj.addPage(hdlcoder.report.Clock(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));


            obj.addPage(hdlcoder.report.ResourceDutInfo(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));

            if obj.resourceReport
                obj.addPage(hdlcoder.report.ResourceBill(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                if(targetcodegen.targetCodeGenerationUtils.isNFPMode())
                    obj.addPage(hdlcoder.report.ResourceNFPBill(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                end
                targetCodeGenMode=targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode();
                if(targetCodeGenMode)
                    obj.addPage(hdlcoder.report.ResourceTargetUsage(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
                end
            end
            if obj.optimizationReport
                obj.addPage(hdlcoder.report.RecommendTargetCodeGeneration(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
            end
            if obj.ipcoreReport
                obj.addPage(hdlcoder.report.IPCoreReport(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
            end
            if obj.traceability
                obj.addPage(hdlcoder.report.Traceability(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
            end
            if obj.CriticalPathEstimation
                obj.addPage(hdlcoder.report.CriticalPathEstimation(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
            end
            if obj.StaticLatencyPathAnalysis
                obj.addPage(hdlcoder.report.StaticLatencyPathAnalysis(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
            end
            if obj.ObfuscateGeneratedHDLCode
                obj.addPage(hdlcoder.report.Obfuscation(obj.ModelName,obj.HDLTraceabilityDriver,obj.PIR,obj.TcgInventory));
            end
            obj.Pages=[obj.Pages(:);pages(:)];
        end

        function out=getReportDir(obj)
            out=obj.HtmlDir;
        end

        function obj=ReportInfo(modelName)
            obj=obj@Simulink.report.ReportInfo(modelName);
        end

        function reset(obj,HDLCoder,p,tcgInventory)
            obj.HDLTraceabilityDriver=HDLCoder.getTraceabilityDriver(obj.ModelName);
            obj.HDLCoder=HDLCoder;
            obj.PIR=p;
            obj.TcgInventory=tcgInventory;
            obj.resourceReport=HDLCoder.getParameter('resourceReport');
            obj.optimizationReport=HDLCoder.getParameter('optimizationReport');
            obj.hdlgenerateWebview=HDLCoder.getParameter('hdlgeneratewebview');
            obj.ipcoreReport=HDLCoder.getParameter('ipcoreReport');
            obj.traceability=HDLCoder.getParameter('traceability');
            obj.traceabilityProcessing=HDLCoder.getParameter('traceabilityprocessing');
            obj.CriticalPathEstimation=HDLCoder.getParameter('CriticalPathEstimation');
            obj.StaticLatencyPathAnalysis=HDLCoder.getParameter('StaticLatencyPathAnalysis');
            obj.ObfuscateGeneratedHDLCode=HDLCoder.getParameter('ObfuscateGeneratedHDLCode');
        end

        function init(obj,HDLCoder,p)
            obj.TargetLang='HDL';
            obj.reset(HDLCoder,p,[]);
            if HDLCoder.mdlIdx==numel(HDLCoder.AllModels)&&...
                ~strcmp(HDLCoder.ModelName,HDLCoder.getStartNodeName)



                dutname_matches=find_system(HDLCoder.getStartNodeName,'flat');
                obj.SourceSubsystem=dutname_matches{1};
            end


            tmpCodeGenDir=HDLCoder.hdlGetCodegendir;
            if isFullPath(tmpCodeGenDir)
                [obj.codeGenDirRoot,obj.relCodeGenDir]=fileparts(tmpCodeGenDir);
                obj.setBuildDir(tmpCodeGenDir);
            else
                obj.codeGenDirRoot=pwd;
                obj.relCodeGenDir=tmpCodeGenDir;
                obj.setBuildDir(fullfile(obj.codeGenDirRoot,obj.relCodeGenDir));
            end
            obj.HtmlDir=fullfile(obj.getBuildDir,'html');
            obj.ReportTitle=['Code Generation Report for ',obj.ModelName];
            if obj.traceability||obj.hdlgenerateWebview||obj.traceabilityProcessing
                obj.Config.GenerateTraceInfo='on';
                obj.Config.IncludeHyperlinkInReport='on';
            else
                obj.Config.GenerateTraceInfo='off';
                obj.Config.IncludeHyperlinkInReport='off';
            end
            if obj.hdlgenerateWebview
                obj.Config.GenerateWebview='on';
            else
                obj.Config.GenerateWebview='off';
            end
            obj.headJs='';
            obj.libJs='';
            hiliteCallback='';
            if obj.hasWebview
                obj.libJs={'rtwreport_utils.js'};
            end
            obj.printHyperlinksInLog=true;
            if HDLCoder.getParameter('BuildToProtectModel')
                obj.printHyperlinksInLog=false;
            end

            obj.htmlLinkManager=Simulink.report.HTMLLinkManager;
            obj.htmlLinkManager.hasWebview=obj.hasWebview;
            obj.htmlLinkManager.IncludeHyperlinkInReport=true;
            obj.htmlLinkManager.JavaScriptHilite=hiliteCallback;
            obj.htmlLinkManager.BuildDir=obj.getBuildDir();
            if obj.traceability...
                ||obj.traceabilityProcessing...
                ||obj.resourceReport...
                ||obj.optimizationReport...
                ||obj.hdlgenerateWebview...
                ||obj.ipcoreReport...
                ||obj.CriticalPathEstimation...
                ||obj.StaticLatencyPathAnalysis...
                ||obj.ObfuscateGeneratedHDLCode
                obj.createReportDir;
                obj.checkoutLicense();
            end
        end

        function out=getHelpMethod(~)
            out='helpview([docroot ''/toolbox/hdlcoder/ug/hdlcoder_ug.map''], ''hdl_codegen_report'')';
        end

        function convertCode2HTML(obj)
            currDir=pwd;
            cd(obj.HtmlDir);
            try
                if obj.traceability||obj.hdlgenerateWebview||obj.traceabilityProcessing

                    if obj.HDLCoder.mdlIdx<numel(obj.HDLCoder.AllModels)
                        mdlName=obj.ModelName;
                    elseif obj.HDLCoder.DUTMdlRefHandle>0
                        mdlName=obj.HDLCoder.OrigModelName;
                    else
                        mdlName=obj.HDLCoder.ModelName;
                    end
                    hdlFileNames=obj.FileInfo;
                    obj.HDLTraceabilityDriver.generateTraceability(mdlName,...
                    obj.SourceSubsystem,obj.getBuildDir,hdlFileNames);
                end
            catch me

                cd(currDir);
                rethrow(me);
            end
            cd(currDir);
        end
        function setFileInfo(obj)

            scriptGen=hdlshared.EDAScriptsBase(...
            obj.HDLCoder.PirInstance.getEntityNames,...
            obj.HDLCoder.PirInstance.getEntityPaths,...
            obj.HDLCoder.TestBenchFilesList);
            hdlFileNames=scriptGen.entityFileNames;
            gp=pir;
            if gp.getTargetCodeGenSuccess&&~isempty(obj.TcgInventory)
                targetFileNames=obj.TcgInventory.getTargetFileNames;
                hdlFileNames=setdiff(hdlFileNames,targetFileNames);
            end

            for i=1:length(hdlFileNames)
                hdlFileNames{i}=[obj.getBuildDir,filesep,hdlFileNames{i}];
            end
            obj.FileInfo=hdlFileNames;
        end
        function createReportDir(obj)

            dirs=RTW.getBuildDir(obj.ModelName);
            obj.slprjDir=fullfile(dirs.CodeGenFolder,'slprj','hdl',obj.ModelName,'tmwinternal');
            if exist(obj.slprjDir,'dir')==0
                mkdir(obj.slprjDir);
            end


            if exist(obj.HtmlDir,'dir')
                rmdir(obj.HtmlDir,'s');
            end

            mkdir(obj.HtmlDir);
        end

        function emitContents(obj)

            contents_file=fullfile(obj.HtmlDir,[obj.ModelName,'_contents.html']);
            obj.HDLTraceabilityDriver.generateContents(contents_file,DAStudio.message('hdlcoder:report:contents'),obj.ModelName);
        end

        function emitPage(obj,p)
            p.setLinkManager(obj.htmlLinkManager);
            onLoadCallback='try {if (top) {if (top.rtwPageOnLoad) top.rtwPageOnLoad(''%s''); else local_onload();}} catch(err) {};';
            p.setJavaScript(obj.libJs,obj.headJs,sprintf(onLoadCallback,p.getId));
            p.ReportFolder=obj.getReportDir;
            if isempty(p.ReportFileName)
                p.ReportFileName=[obj.ModelName,'_',p.getDefaultReportFileName];
            end
            p.generate;
        end

        function emitOptimizationReportPages(obj)
            try
                obj.registerOptimizationReportPages();
                for k=1:length(obj.Pages)
                    obj.emitPage(obj.Pages{k});
                end
            catch me
                hdldisp(getReport(me),0);
                hdldisp(message('hdlcoder:engine:OptimizationReportError'));
            end
            obj.Pages={};
        end

        function emitPages(obj)

            for k=1:length(obj.Pages)
                obj.emitPage(obj.Pages{k});
            end

            emitTraceInfo(obj);
        end


        function processTraceInfo(obj,HDLCoder,p,tcgInventory)
            obj.reset(HDLCoder,p,tcgInventory);
            obj.setFileInfo;
            obj.convertCode2HTML();
            obj.emitContents;
            obj.emitTraceInfo;
        end


        function emitTraceInfo(obj)


            if obj.traceability||obj.hdlgenerateWebview||obj.traceabilityProcessing

                trace_contents_file=fullfile(obj.HtmlDir,'contents_file.tmp');


                fid=fopen(trace_contents_file,'r');
                if fid==-1
                    error(message('hdlcoder:engine:cannotopenfile',trace_contents_file));
                end

                traceContent=fread(fid,'*char')';
                fclose(fid);
                contents_file=fullfile(obj.HtmlDir,[obj.ModelName,'_contents.html']);
                replaceSpecificKeyword(contents_file,'<!--REPLACE_WITH_GENERATED_FILES-->',traceContent);


                deleteTraceReport(obj.ModelName,obj.HtmlDir);
            end

            h=registerTraceInfo(obj);
            if obj.traceability||obj.hdlgenerateWebview||obj.traceabilityProcessing

                trace_file=makeTraceFileWritable(obj.HtmlDir,obj.ModelName);
                if isa(h,'slhdlcoder.TraceInfo')
                    if obj.traceability||obj.traceabilityProcessing
                        un='on';
                        sl='on';
                        sf='on';
                        eml='on';
                        hlink='on';
                        h.emitHTML(trace_file,'-un',un,'-sl',sl,'-sf',sf,'-eml',eml,'-hyperlink',hlink);
                    end
                    h.emitJS(fullfile(obj.getReportDir(),[obj.ModelName,'_traceInfo.js']));
                    h.emitSidMapJS(fullfile(obj.getReportDir(),[obj.ModelName,'_sid_map.js']));
                end
            end
        end

        function emitHTML(obj)
            obj.setFileInfo;

            codegenreport_fullfilename=obj.getReportFileFullName();
            hdlcoder.report.ReportInfo.getSavedRptPath(obj.ModelName,true,codegenreport_fullfilename);
            [~,codegenreport_name,ext]=fileparts(codegenreport_fullfilename);
            codegenreport_name=[codegenreport_name,ext];
            codegenreport_hyperlink=hdlcoder.report.getHDLCoderHyperLink(codegenreport_fullfilename,codegenreport_name);
            if obj.printHyperlinksInLog
                hdldisp(message('hdlcoder:hdldisp:GenHTMLFiles',codegenreport_hyperlink));
            else
                hdldisp(message('hdlcoder:hdldisp:GenHTMLFiles',codegenreport_name));
            end
            obj.convertCode2HTML();

            try
                obj.emitWebview;
            catch me
                if(strcmpi(me.identifier,'MATLAB:COPYFILE:OSError'))
                    warning(message('hdlcoder:engine:cannotcopyfileunderwebview',me.message));
                else
                    rethrow(me);
                end
            end
            obj.emitMain(obj.getReportFileFullName);
            obj.emitContents;
            obj.emitPages;
            obj.copyResources;
        end
    end

    methods(Static)
        function rptPathReturn=getSavedRptPath(mdlName,isCodeGenRpt,rptPath)







            persistent generatedCodeGenRptMap
            persistent generatedCheckRptMap

            if isempty(generatedCodeGenRptMap)
                generatedCodeGenRptMap=containers.Map;
            end

            if isempty(generatedCheckRptMap)
                generatedCheckRptMap=containers.Map;
            end

            maps={generatedCodeGenRptMap,generatedCheckRptMap};

            fetchExistingReport=false;
            if nargin<3

                fetchExistingReport=true;
            end

            if isCodeGenRpt

                mapIdx=1;
            else

                mapIdx=2;
            end


            if isKey(maps{mapIdx},mdlName)
                rptPathReturn=maps{mapIdx}(mdlName);
            else
                rptPathReturn=[];
            end


            if~fetchExistingReport
                maps{mapIdx}(mdlName)=rptPath;%#ok<NASGU>
            end
        end
    end
end


function out=isFullPath(d)
    out=false;
    if ispc
        if length(d)>=3
            out=(isletter(d(1))&&d(2)==':'&&d(3)=='\');
        end
    else
        if~isempty(d)
            out=d(1)=='/';
        end
    end
end


function replaceSpecificKeyword(fileName,keyword,replaceString)

    fid=fopen(fileName,'r','n','UTF-8');
    if fid==-1
        error(message('hdlcoder:engine:cannotopenfile',fileName));
    end
    fileContents=fread(fid,'*char')';
    fclose(fid);


    fileContents=strrep(fileContents,keyword,replaceString);


    fileattrib(fileName,'+w');
    fid=fopen(fileName,'w','n','UTF-8');
    if fid==-1
        error(message('hdlcoder:engine:cannotopenfile',fileName));
    end

    fprintf(fid,'%s',fileContents);
    fclose(fid);
end


function deleteTraceReport(model,htmlDir)
    rptName=fullfile(htmlDir,[model,'_trace.html']);
    if exist(rptName,'file')
        delete(rptName);
    end

    xmlName=fullfile(htmlDir,[model,'_trace.xml']);
    if exist(xmlName,'file')
        delete(xmlName);
    end
end


function blank=isLineBlank(fileLine)
    locationTag=strfind(fileLine,'</a>');
    blank=0;

    if~isempty(locationTag)

        isFileLineBlank=(locationTag(1)+length('</a>  '))>length(fileLine);

        if isFileLineBlank
            blank=1;
        end
    end
end


function lineNum=getLineNum(fileLine)
    locLineNum=extractBetween(fileLine,'class="LN" name="','">');
    lineNum=str2double(locLineNum);
end


function sid=getSIDFromLine(fileLine)
    sidExtract=extractBetween(fileLine,'matlab:coder.internal.code2model(''',''')"');
    sid=sidExtract;
end


function lineIndent=getIndentCurrLine(currLine)
    locationATag=strfind(currLine,'</a>');

    extractFromATag=extractAfter(currLine,locationATag(1)+3);
    spaceCharCheck=isspace(extractFromATag);

    [~,idx]=find(spaceCharCheck==0,1);
    lineIndent=idx-1;
end


function[newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,SID,lineNum,traceSelect,generateWebView,newFileLineIter)











    bdrootName=get_param(bdroot,'Name');


    if traceSelect==2
        locationTag=strfind(currLine,':');

        currLine=extractBefore(currLine,locationTag(1));
    end


    firstPart=extractBefore(currLine,'class="LN" name="');


    lineNumChar=int2str(lineNum);
    lineNumStr=sprintf('%5s',lineNumChar);
    nSID=length(SID);






    if generateWebView
        secondPart=[' class="LN" id="',lineNumChar,'" href="matlab:coder.internal.code2model('];
    else
        secondPart=[' class="LN" id="',lineNumChar,'" href="matlab:set_param(''',bdrootName,...
        ''',','''hiliteAncestors'', ''none'');coder.internal.code2model('];
    end


    if nSID>1
        secondPart=[secondPart,'{'];
    end
    for i=1:nSID
        secondPart=[secondPart,'''',SID{i}{:},''''];%#ok<AGROW>
        if i~=nSID
            secondPart=[secondPart,','];%#ok<AGROW>
        end
    end
    if nSID>1
        secondPart=[secondPart,'}'];
    end
    secondPart=[secondPart,')" name="code2model">',lineNumStr,'   <'];


    locationTag=strfind(currLine,'</a>');
    thirdPart=extractAfter(currLine,locationTag(1));


    if traceSelect==3
        tempPart=thirdPart;
        locationHref=strfind(tempPart,'<a href');
        thirdPart=extractBefore(tempPart,locationHref(1));
        fullNameSID=Simulink.ID.getFullName(SID{1}{:});
        locationSlash=strfind(fullNameSID,'/');
        nameOfSID=extractAfter(fullNameSID,locationSlash(end));
    end


    lineToPrint=[firstPart,secondPart,thirdPart];


    if traceSelect==2
        lineToPrint=[lineToPrint,'</span>'];
    end


    if traceSelect==3
        lineToPrint=[lineToPrint,nameOfSID,'</a></span>'];
    end

    newFileContents{newFileLineIter}=lineToPrint;newFileLineIter=newFileLineIter+1;
    newFileContents{newFileLineIter}=newline;newFileLineIter=newFileLineIter+1;
end


function[newFileContents,newFileLineIter]=printLine(newFileContents,currLine,lineNum,newFileLineIter)






    if(lineNum~=0)
        firstPart=extractBefore(currLine,'class="LN" name="');
        if isempty(firstPart)
            newFileContents{newFileLineIter}=currLine;newFileLineIter=newFileLineIter+1;
            newFileContents{newFileLineIter}=newline;newFileLineIter=newFileLineIter+1;
        else
            lineNumStr=num2str(lineNum);
            secondPart=strcat(' class="LN" id="',lineNumStr,'">',sprintf('%5s',lineNumStr),'   <');
            locationTags=strfind(currLine,'</a>');
            thirdPart=extractAfter(currLine,locationTags(1));

            lineToDump=strcat(firstPart,secondPart,thirdPart);
            newFileContents{newFileLineIter}=lineToDump;newFileLineIter=newFileLineIter+1;
            newFileContents{newFileLineIter}=newline;newFileLineIter=newFileLineIter+1;
        end
    else
        newFileContents{newFileLineIter}=currLine;newFileLineIter=newFileLineIter+1;
        newFileContents{newFileLineIter}=newline;newFileLineIter=newFileLineIter+1;
    end
end


function startTrace=isLineTraceStart(fileLine)
    startTrace=contains(fileLine,'@[tracestart]');
end


function endTrace=isLineTraceEnd(fileLine)
    endTrace=contains(fileLine,'@[traceend]');
end


function traceComment=isTraceComment(fileLine)
    traceComment=contains(fileLine,'matlab:coder.internal.code2model(');
end


function lineBlank=isLineBlankOrigCode(currLine)
    lineBlank=~(length(currLine)>1);
end


function lineBlankComment=isLineBlankCommentOrigCode(currLine)
    lineBlankComment=0;
    if contains(currLine,'//')
        locationTag=strfind(currLine,'//');
        lineBlankComment=(locationTag(1)+3)>length(currLine);
    elseif contains(currLine,'--')
        locationTag=strfind(currLine,'--');
        lineBlankComment=(locationTag(1)+3)>length(currLine);
    end
end


function traceLine=isLineTraceComment(currLine)
    traceLine=false;

    if contains(currLine,'//')||contains(currLine,'--')
        pattern='(\-\-|\/\/)\s\''<\S*>\/\S*';
        traceLine=~isempty(regexp(currLine,pattern,'match'));
    end
end


function lineSFCompStart=isLineTraceSFCompStart(currLine)
    lineSFCompStart=contains(currLine,'@[traceSFCompstart]');
end


function lineSFCompEnd=isLineTraceSFCompEnd(currLine)
    lineSFCompEnd=contains(currLine,'@[traceSFCompend]');
end


function lineMLFcn=isLinePointingToMLFcnFile(currLine)
    lineMLFcn=false;

    if contains(currLine,'//')||contains(currLine,'--')
        pattern='<span\sclass="CT">(\/\/|\-\-)MATLAB\sFunction\s''\S*'':';
        lineMLFcn=~isempty(regexp(currLine,pattern,'match'));
    end
end


function lineInternalCmt=isLineSFCompInternalCmt(currLine)
    pattern1='''<\S*>:\d+''';
    pattern2='''<\S*>:\d+:\d+''';
    lineInternalCmt=~isempty(regexp(currLine,pattern1,'match'))||...
    ~isempty(regexp(currLine,pattern2,'match'));
end

function extractedLine=removeInternalSIDPtr(currLine)
    locationTag=strfind(currLine,':');
    extractedLine=extractBefore(currLine,locationTag(1));
end


function lineNormalCmt=isLineNormalComment(currLine)
    lineNormalCmt=false;

    if contains(currLine,'//')||contains(currLine,'--')
        locationATag=strfind(currLine,'</a>');
        extractFromATag=extractAfter(currLine,locationATag(1));
        spaceCharCheck=isspace(extractFromATag);
        [~,idx]=find(spaceCharCheck==0,1);
        extractRestOfLine=extractAfter(extractFromATag,idx);
        lineNormalCmt=(contains(extractRestOfLine,'span class="CT">//')||contains(extractRestOfLine,'span class="CT">--'))&&~isTraceComment(extractRestOfLine);
    end
end


function blankComment=isLineBlankComment(fileLine)
    blankComment=0;
    normalCmt=isLineNormalComment(fileLine);

    if normalCmt

        if contains(fileLine,'<span class="CT">// </span>')||...
            contains(fileLine,'<span class="CT">-- </span>')
            blankComment=1;
        end
    end
end


function reqTrace=isLineBlkReq(currLine)
    reqTrace=false;

    if contains(currLine,'//')||contains(currLine,'--')
        pattern='(\/\/|\-\-)(\s)Block(\s)requirements(\s)for(\s)';
        reqTrace=~isempty(regexp(currLine,pattern,'match'));
    end
end


function stateStat=isCommentWithInfo(currLine)
    stateStat=contains(currLine,': ''<a href');
end


function usefulInfo=usefulInfoStateCmt(currLine)
    usefulInfo=true;

    if contains(currLine,'//')||contains(currLine,'--')
        pattern='(\/\/|\-\-)(\s|)''<\S*>';
        usefulInfo=isempty(regexp(currLine,pattern,'match'));
    end
end


function replaceHDLFile(mapForFile)
    nFiles=length(keys(mapForFile));
    keyMap=keys(mapForFile);

    gp=pir;
    validExt=gp.getHDLFileExtension;
    for i=1:nFiles
        traceOn=0;
        oldFileName=keyMap{i};


        [~,~,ext]=fileparts(oldFileName);

        if~(any(contains(validExt,ext)))
            continue;
        end




        fHdlOld=fopen(oldFileName,'r');
        if fHdlOld==-1
            error(message('hdlcoder:engine:cannotopenfile',oldFileName));
        end

        oldFileContents=textscan(fHdlOld,'%s','Delimiter','\n','whitespace','');
        fclose(fHdlOld);

        fileLineIter=0;
        fileSize=length(oldFileContents{1});

        newFileContents=cell(1,fileSize);idx=1;
        while fileLineIter<fileSize
            fileLineIter=fileLineIter+1;
            currLine=oldFileContents{1}{fileLineIter};

            if isLineTraceStart(currLine)
                traceOn=1;
            elseif isLineTraceEnd(currLine)
                traceOn=0;
            elseif isLineTraceSFCompStart(currLine)
                traceOn=1;
            elseif isLineTraceSFCompEnd(currLine)
                traceOn=0;
            elseif isLineBlkReq(currLine)
                locTag=strfind(currLine,'<');
                firstPart=extractBefore(currLine,locTag(1));
                remPart=extractAfter(currLine,locTag(1));
                locTag=strfind(remPart,'/');
                lineToPrint=[firstPart,extractAfter(remPart,locTag(end))];
                newFileContents{idx}=lineToPrint;idx=idx+1;
                newFileContents{idx}=newline;idx=idx+1;
            elseif isLineTraceComment(currLine)
                continue;
            elseif isLineBlankOrigCode(currLine)
                newFileContents{idx}=currLine;idx=idx+1;
                newFileContents{idx}=newline;idx=idx+1;
            elseif isLineSFCompInternalCmt(currLine)
                if traceOn
                    if usefulInfoStateCmt(currLine)
                        lineExtracted=removeInternalSIDPtr(currLine);
                        newFileContents{idx}=lineExtracted;idx=idx+1;
                        newFileContents{idx}=newline;idx=idx+1;
                    end
                else
                    newFileContents{idx}=currLine;idx=idx+1;
                    newFileContents{idx}=newline;idx=idx+1;
                end
            else
                newFileContents{idx}=currLine;idx=idx+1;
                newFileContents{idx}=newline;idx=idx+1;
            end
        end

        newFileData=[newFileContents{:}];
        fHdlNew=fopen(oldFileName,'w');
        if fHdlNew==-1
            error(message('hdlcoder:engine:cannotopenfile',oldFileName));
        end
        fprintf(fHdlNew,'%s',newFileData);
        fclose(fHdlNew);
    end
end


function modifyTraceInfo(hTrace,generateWebView)


    traceInfoFileName=fullfile(hTrace.BuildDirRoot,hTrace.getTraceInfoFileName);
    data=load(traceInfoFileName);
    infoStruct=data.infoStruct;
    datFile=[traceInfoFileName,'cd'];
    if slfeature('AsyncSaveTraceRegistry')>0&&exist(datFile,'file')
        tdata=rtwprivate('rtwctags_registry','load',datFile);
        fldNames=fieldnames(tdata);
        for k=1:numel(fldNames)
            infoStruct.(fldNames{k})=tdata.(fldNames{k});
        end
    end
    regEntry=hTrace.getRegistry();


    gp=pir;
    validExt=gp.getHDLFileExtension;

    mapForFile=containers.Map;



    mapForSID=containers.Map;


    fileIter=1;
    nComps=length(regEntry);



    for i=1:nComps
        if~isempty(regEntry(i).location)
            nLocStruct=length(regEntry(i).location);
            for locIter=1:nLocStruct
                srcFilePath=regEntry(i).location(locIter).file;


                if isKey(mapForFile,srcFilePath)
                    continue;
                else
                    mapForFile(srcFilePath)=fileIter;
                    fileIter=fileIter+1;


                    [topDir,name,ext]=fileparts(srcFilePath);


                    if~(any(contains(validExt,ext)))
                        continue;
                    end


                    ext(1)='_';
                    endExtension1=strcat(ext,'.html');
                    endExtension2=strcat(ext,'_mod.html');
                    srcFileHtmlName=strcat(name,endExtension1);
                    modFileHtmlName=strcat(name,endExtension2);
                    htmlFileOld=fullfile(topDir,hTrace.getCodeGenRptDir,srcFileHtmlName);
                    htmlFileNew=fullfile(topDir,hTrace.getCodeGenRptDir,modFileHtmlName);

                    fidread=fopen(htmlFileOld,'r','n','UTF-8');
                    if fidread==-1
                        error(message('hdlcoder:engine:cannotopenfile',htmlFileOld));
                    end
                    fidwrite=fopen(htmlFileNew,'w','n','UTF-8');
                    if fidwrite==-1
                        error(message('hdlcoder:engine:cannotopenfile',htmlFileNew));
                    end

                    oldFileContents=textscan(fidread,'%s','Delimiter','\n','whitespace','');
                    fclose(fidread);
                    prevLineNum=0;
                    traceOn=0;
                    SID={};
                    fileLineIter=0;
                    fileSize=length(oldFileContents{1});
                    newFileContents=cell(1,fileSize);newFileLineIter=1;
                    while fileLineIter<fileSize
                        fileLineIter=fileLineIter+1;
                        currLine=oldFileContents{1}{fileLineIter};
                        blank=isLineBlank(currLine);




                        if blank
                            if~prevLineNum
                                [newFileContents,newFileLineIter]=printLine(newFileContents,currLine,prevLineNum,newFileLineIter);
                            else
                                [newFileContents,newFileLineIter]=printLine(newFileContents,currLine,prevLineNum,newFileLineIter);
                                prevLineNum=prevLineNum+1;
                            end
                            continue;


                        elseif isLineTraceStart(currLine)
                            traceOn=1;


                            if~prevLineNum
                                prevLineNum=getLineNum(currLine);
                            end



                            fileLineIter=fileLineIter+1;
                            currLine=oldFileContents{1}{fileLineIter};
                            while~isTraceComment(currLine)&&~isLineTraceEnd(currLine)

                                blankCmt=isLineBlankComment(currLine);
                                if~blankCmt
                                    [newFileContents,newFileLineIter]=printLine(newFileContents,currLine,prevLineNum,newFileLineIter);
                                    if prevLineNum~=0
                                        prevLineNum=prevLineNum+1;
                                    end
                                end
                                fileLineIter=fileLineIter+1;
                                currLine=oldFileContents{1}{fileLineIter};
                            end

                            if isLineTraceEnd(currLine)
                                traceOn=0;
                                SID={};
                                continue;
                            end
                            SID{end+1}=getSIDFromLine(currLine);%#ok<AGROW> 
                            newSID=SID{end};





                            if isLineBlkReq(currLine)
                                if isKey(mapForSID,newSID)
                                    mapFile=mapForSID(newSID{:});
                                    if isKey(mapFile,srcFilePath)
                                        v=mapFile(srcFilePath);
                                        resVal=[v,prevLineNum];
                                        mapFile(srcFilePath)=resVal;
                                    else
                                        mapFile(srcFilePath)=prevLineNum;
                                    end
                                    mapForSID(newSID{:})=mapFile;
                                else
                                    mapFile=containers.Map;
                                    mapFile(srcFilePath)=prevLineNum;
                                    mapForSID(newSID{:})=mapFile;
                                end
                                [newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,{newSID},prevLineNum,3,generateWebView,newFileLineIter);
                                prevLineNum=prevLineNum+1;
                            end

                        elseif isLineTraceEnd(currLine)
                            traceOn=0;
                            SID={};
                            continue;


                        elseif isLineTraceSFCompStart(currLine)


                            if~prevLineNum
                                prevLineNum=getLineNum(currLine);
                            end

                            fileLineIter=fileLineIter+1;
                            currLine=oldFileContents{1}{fileLineIter};
                            SID={};
                            SIDIndents=[];
                            codeEncountered=[];
                            sfTraceOn=0;


                            while~isLineTraceSFCompEnd(currLine)





                                if isLineTraceStart(currLine)
                                    fileLineIter=fileLineIter+1;
                                    currLine=oldFileContents{1}{fileLineIter};
                                    continue;
                                end

                                if isTraceComment(currLine)



                                    mlFcnSID={};
                                    if isLinePointingToMLFcnFile(currLine)
                                        newSID=getSIDFromLine(currLine);
                                        mlFcnSID{end+1}=newSID;%#ok<AGROW> 


                                        [newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,mlFcnSID,prevLineNum,2,generateWebView,newFileLineIter);
                                        if isKey(mapForSID,mlFcnSID{end})
                                            mapFile=mapForSID(mlFcnSID{end}{:});
                                            if isKey(mapFile,srcFilePath)
                                                v=mapFile(srcFilePath);
                                                resVal=[v,prevLineNum];
                                                mapFile(srcFilePath)=resVal;
                                            else
                                                mapFile(srcFilePath)=prevLineNum;
                                            end
                                            mapForSID(mlFcnSID{end}{:})=mapFile;
                                        else
                                            mapFile=containers.Map;
                                            mapFile(srcFilePath)=prevLineNum;
                                            mapForSID(mlFcnSID{end}{:})=mapFile;
                                        end
                                        mlFcnSID(end)=[];%#ok<NASGU> 
                                        prevLineNum=prevLineNum+1;
                                        fileLineIter=fileLineIter+1;
                                        currLine=oldFileContents{1}{fileLineIter};
                                        continue;
                                    else

                                        sfTraceOn=1;
                                        newSID=getSIDFromLine(currLine);
                                        flag=0;

                                        if~isempty(SID)
                                            for iter=1:length(SID)
                                                if(strcmp(SID{iter}{:},newSID{:}))
                                                    flag=1;
                                                    break;
                                                end
                                            end
                                        end




                                        if(~flag)
                                            if(~isempty(SIDIndents))
                                                prevIndent=SIDIndents(end);
                                                currIndent=getIndentCurrLine(currLine);
                                                if prevIndent<currIndent
                                                    SIDIndents(end+1)=currIndent;%#ok<AGROW> 
                                                    SID{end+1}=newSID;%#ok<AGROW> 
                                                else
                                                    for t=length(SIDIndents):-1:1
                                                        if SIDIndents(t)>=currIndent
                                                            SIDIndents(t)=[];
                                                            SID(t)=[];
                                                            codeEncountered(t)=[];
                                                        else
                                                            break;
                                                        end
                                                    end
                                                    SIDIndents(end+1)=currIndent;%#ok<AGROW> 
                                                    SID{end+1}=newSID;%#ok<AGROW> 
                                                end
                                            else
                                                SIDIndents(end+1)=getIndentCurrLine(currLine);%#ok<AGROW> 
                                                SID{end+1}=newSID;%#ok<AGROW> 
                                            end
                                            codeEncountered(end+1)=0;%#ok<AGROW> 
                                        end



                                        if isLineBlkReq(currLine)
                                            if isKey(mapForSID,newSID)
                                                mapFile=mapForSID(newSID{:});
                                                if isKey(mapFile,srcFilePath)
                                                    v=mapFile(srcFilePath);
                                                    resVal=[v,prevLineNum];
                                                    mapFile(srcFilePath)=resVal;
                                                else
                                                    mapFile(srcFilePath)=prevLineNum;
                                                end
                                                mapForSID(newSID{:})=mapFile;
                                            else
                                                mapFile=containers.Map;
                                                mapFile(srcFilePath)=prevLineNum;
                                                mapForSID(newSID{:})=mapFile;
                                            end
                                            [newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,{newSID},prevLineNum,3,generateWebView,newFileLineIter);
                                            prevLineNum=prevLineNum+1;




                                        elseif isCommentWithInfo(currLine)
                                            if isKey(mapForSID,newSID)
                                                mapFile=mapForSID(newSID{:});
                                                if isKey(mapFile,srcFilePath)
                                                    v=mapFile(srcFilePath);
                                                    resVal=[v,prevLineNum];
                                                    mapFile(srcFilePath)=resVal;
                                                else
                                                    mapFile(srcFilePath)=prevLineNum;
                                                end
                                                mapForSID(newSID{:})=mapFile;
                                            else
                                                mapFile=containers.Map;
                                                mapFile(srcFilePath)=prevLineNum;
                                                mapForSID(newSID{:})=mapFile;
                                            end

                                            [newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,{newSID},prevLineNum,2,generateWebView,newFileLineIter);
                                            prevLineNum=prevLineNum+1;
                                        end
                                        fileLineIter=fileLineIter+1;
                                        currLine=oldFileContents{1}{fileLineIter};
                                    end
                                elseif sfTraceOn

                                    if isLineBlankComment(currLine)
                                        fileLineIter=fileLineIter+1;
                                        currLine=oldFileContents{1}{fileLineIter};

                                    elseif isLineNormalComment(currLine)||isLineBlank(currLine)
                                        [newFileContents,newFileLineIter]=printLine(newFileContents,currLine,prevLineNum,newFileLineIter);
                                        prevLineNum=prevLineNum+1;
                                        fileLineIter=fileLineIter+1;
                                        currLine=oldFileContents{1}{fileLineIter};
                                    else

                                        currIndent=getIndentCurrLine(currLine);
                                        if currIndent<SIDIndents(end)
                                            for t=length(SIDIndents):-1:1
                                                if SIDIndents(t)>=currIndent
                                                    SIDIndents(t)=[];
                                                    SID(t)=[];
                                                    codeEncountered(t)=[];
                                                else
                                                    break;
                                                end
                                            end
                                        end
                                        if~isempty(codeEncountered)
                                            codeEncountered(end)=1;
                                        end


                                        if isempty(SID)
                                            [newFileContents,newFileLineIter]=printLine(newFileContents,currLine,prevLineNum,newFileLineIter);
                                            prevLineNum=prevLineNum+1;
                                            fileLineIter=fileLineIter+1;
                                            currLine=oldFileContents{1}{fileLineIter};
                                            sfTraceOn=0;
                                            continue;
                                        end
                                        if isKey(mapForSID,SID{end})
                                            mapFile=mapForSID(SID{end}{:});
                                            if isKey(mapFile,srcFilePath)
                                                v=mapFile(srcFilePath);
                                                resVal=[v,prevLineNum];
                                                mapFile(srcFilePath)=resVal;
                                            else
                                                mapFile(srcFilePath)=prevLineNum;
                                            end
                                            mapForSID(SID{end}{:})=mapFile;
                                        else
                                            mapFile=containers.Map;
                                            mapFile(srcFilePath)=prevLineNum;
                                            mapForSID(SID{end}{:})=mapFile;
                                        end

                                        [newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,SID(end),prevLineNum,1,generateWebView,newFileLineIter);
                                        prevLineNum=prevLineNum+1;
                                        fileLineIter=fileLineIter+1;
                                        currLine=oldFileContents{1}{fileLineIter};
                                    end
                                    if isempty(SID)
                                        sfTraceOn=0;
                                    end
                                elseif isLineBlankComment(currLine)
                                    fileLineIter=fileLineIter+1;
                                    currLine=oldFileContents{1}{fileLineIter};
                                else

                                    [newFileContents,newFileLineIter]=printLine(newFileContents,currLine,prevLineNum,newFileLineIter);
                                    prevLineNum=prevLineNum+1;
                                    fileLineIter=fileLineIter+1;
                                    currLine=oldFileContents{1}{fileLineIter};
                                end
                            end
                            SID={};





                        elseif traceOn
                            if isTraceComment(currLine)
                                newSID=getSIDFromLine(currLine);
                                flag=0;
                                for iter=1:length(SID)
                                    if(strcmp(SID{iter}{:},newSID{:}))
                                        flag=1;
                                        break;
                                    end
                                end
                                if(~flag)
                                    SID{end+1}=newSID;%#ok<AGROW> 
                                end

                                if isLineBlkReq(currLine)
                                    if isKey(mapForSID,newSID)
                                        mapFile=mapForSID(newSID{:});
                                        if isKey(mapFile,srcFilePath)
                                            v=mapFile(srcFilePath);
                                            resVal=[v,prevLineNum];
                                            mapFile(srcFilePath)=resVal;
                                        else
                                            mapFile(srcFilePath)=prevLineNum;
                                        end
                                        mapForSID(newSID{:})=mapFile;
                                    else
                                        mapFile=containers.Map;
                                        mapFile(srcFilePath)=prevLineNum;
                                        mapForSID(newSID{:})=mapFile;
                                    end
                                    [newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,{newSID},prevLineNum,3,generateWebView,newFileLineIter);
                                    prevLineNum=prevLineNum+1;


                                elseif isCommentWithInfo(currLine)
                                    if isKey(mapForSID,newSID)
                                        mapFile=mapForSID(newSID{:});
                                        if isKey(mapFile,srcFilePath)
                                            v=mapFile(srcFilePath);
                                            resVal=[v,prevLineNum];
                                            mapFile(srcFilePath)=resVal;
                                        else
                                            mapFile(srcFilePath)=prevLineNum;
                                        end
                                        mapForSID(newSID{:})=mapFile;
                                    else
                                        mapFile=containers.Map;
                                        mapFile(srcFilePath)=prevLineNum;
                                        mapForSID(newSID{:})=mapFile;
                                    end

                                    [newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,{newSID},prevLineNum,2,generateWebView,newFileLineIter);
                                    prevLineNum=prevLineNum+1;
                                end
                                continue;

                            elseif isLineTraceComment(currLine)||isLineBlankComment(currLine)
                                continue;
                            end
                            for l=1:length(SID)
                                if isKey(mapForSID,SID{l})
                                    mapFile=mapForSID(SID{l}{:});
                                    if isKey(mapFile,srcFilePath)
                                        v=mapFile(srcFilePath);
                                        resVal=[v,prevLineNum];
                                        mapFile(srcFilePath)=resVal;
                                    else
                                        mapFile(srcFilePath)=prevLineNum;
                                    end
                                    mapForSID(SID{l}{:})=mapFile;
                                else
                                    mapFile=containers.Map;
                                    mapFile(srcFilePath)=prevLineNum;
                                    mapForSID(SID{l}{:})=mapFile;
                                end
                            end

                            [newFileContents,newFileLineIter]=addTraceability(newFileContents,currLine,SID,prevLineNum,1,generateWebView,newFileLineIter);
                            prevLineNum=prevLineNum+1;
                        elseif contains(currLine,'class="LN" name=')
                            if prevLineNum==0
                                prevLineNum=getLineNum(currLine);
                            end
                            [newFileContents,newFileLineIter]=printLine(newFileContents,currLine,prevLineNum,newFileLineIter);
                            prevLineNum=prevLineNum+1;


                        else
                            [newFileContents,newFileLineIter]=printLine(newFileContents,currLine,prevLineNum,newFileLineIter);
                            if prevLineNum~=0
                                prevLineNum=prevLineNum+1;
                            end
                        end
                    end

                    fprintf(fidwrite,'%s',[newFileContents{:}]);
                    fclose(fidwrite);
                    movefile(htmlFileNew,htmlFileOld);
                end
            end
        end
    end


    for i=1:nComps
        if(~isempty(regEntry(i).location))


            infoStruct.traceInfo(i).location=[];
            sid=regEntry(i).sid;
            location=regEntry(i).location(1);


            nLocs=length(regEntry(i).location);


            nonHDLTrace=false;

            iter=1;
            while iter<=nLocs

                filePath=regEntry(i).location(iter).file;


                [~,~,ext]=fileparts(filePath);


                if~(any(contains(validExt,ext)))
                    nonHDLTrace=true;
                    iter=iter+1;
                else
                    regEntry(i).location(iter)=[];


                    nLocs=length(regEntry(i).location);
                    iter=iter-1;
                    if iter==0
                        iter=1;
                    end
                end
            end





            if~isKey(mapForSID,sid)&&~nonHDLTrace
                regEntry(i).location=[];
                infoStruct.traceInfo(i).location=[];
                continue;
            end


            if~isKey(mapForSID,sid)&&nonHDLTrace
                continue;
            end
            mapFile=mapForSID(sid);
            files=keys(mapFile);
            nFiles=length(files);
            for k=1:nFiles
                nSidLines=length(mapFile(files{k}));
                lines=mapFile(files{k});
                for j=1:nSidLines
                    loc=location;
                    loc.line=lines(j);
                    loc.file=files{k};
                    regEntry(i).location(end+1)=loc;
                end
            end

            infoStruct.traceInfo(i).location=regEntry(i).location;
        end
    end

    hTrace.setHDLRegistry(regEntry);


    save(traceInfoFileName,'infoStruct');


    replaceHDLFile(mapForFile);
end


function h=registerTraceInfo(obj)
    h=slhdlcoder.TraceInfo.instance(obj.ModelName);
    fullDir={obj.codeGenDirRoot,obj.relCodeGenDir};
    if~isa(h,'slhdlcoder.TraceInfo')||~strcmp(h.Model,obj.ModelName)
        h=slhdlcoder.TraceInfo(obj.ModelName,fullDir);
    else
        h.clear;
        h.setBuildDir(fullDir);
    end
    if obj.traceability||obj.hdlgenerateWebview||obj.traceabilityProcessing
        hdlFileNames=obj.FileInfo;
        h.setRegistry(hdlFileNames);
        ts=h.getCodeTimeStamp(hdlFileNames{1});
        h.setTimeStamp(ts);
        h.saveTraceInfo;

        if strcmp(obj.HDLCoder.getParameter('traceabilitystyle'),'Line Level')

            modifyTraceInfo(h,obj.hdlgenerateWebview);
        end

        infoStruct=[];
        infoStruct.Subsystems=[];
        infoStruct.Subsystems.BlockPath='';
        infoStruct.Subsystems.TmpMdlName='';
        infoStruct.Subsystems.BuildDir=fullDir;
        infoStruct.Subsystems.TimeStamp=ts;

        save(fullfile(obj.slprjDir,'sinfo.mat'),'infoStruct');
    end
end


function trace_file=makeTraceFileWritable(htmlDir,model)
    trace_file=fullfile(htmlDir,[model,'_trace.html']);
    if exist(trace_file,'file')
        fileattrib(trace_file,'+w');
    end
end






