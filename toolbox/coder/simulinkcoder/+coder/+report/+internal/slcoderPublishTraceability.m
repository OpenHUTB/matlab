

classdef slcoderPublishTraceability<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
        dataObj=[]
        traceInfo=[];
    end
    methods
        function obj=slcoderPublishTraceability(type,template,rtwReportTraceability,reportInfo)
            if strcmp(reportInfo.Config.GenerateComments,'off')

                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'subchapter_template');
                aTraceInfo=[];
            else
                aTraceInfo=loc_getTraceInfo(reportInfo);
            end
            obj=obj@mlreportgen.dom.DocumentPart(type,template);
            obj.dataObj=rtwReportTraceability;
            obj.traceInfo=aTraceInfo;
        end
        function fillChapterTitle(obj)
            import mlreportgen.dom.*;
            obj.append(Text(DAStudio.message('RTW:report:TraceabilityChapterTitle')));
        end

        function fillChapterIntroduction(obj)
            import mlreportgen.dom.*;
            obj.append(Paragraph(DAStudio.message('RTW:report:TraceabilityReportEmptyNoCommentsTxt')));
        end
        function fillNonTraceableSection(obj)
            import mlreportgen.dom.*
            col1={DAStudio.message('RTW:report:BlockName')};
            col2={DAStudio.message('RTW:report:Comment')};
            tmp_registry=obj.traceInfo.getRegistry;
            reasonMap=obj.traceInfo.BlockReductionReason;
            len=length(tmp_registry);
            for k=1:len
                if~isempty(tmp_registry(k).location)
                    continue;
                end
                reg=tmp_registry(k);

                col1{end+1}=reg.rtwname;

                [~,comment]=obj.traceInfo.getReason(reasonMap,reg);
                if~isempty(comment)
                    col2{end+1}=comment;%#ok<*AGROW>
                else
                    col2{end+1}=DAStudio.message('RTW:report:TraceInfoNotAvailable');
                end
            end
            if length(col1)>1
                table=Table([col1',col2']);
                table.StyleName='TableStyleAltRow';
                obj.append(table);
                obj.append(Paragraph);
            else
                obj.append(Paragraph(DAStudio.message('RTW:report:NoEliminatedBlocks')));
            end
        end

        function fillTraceableSection(obj)
            import mlreportgen.dom.*
            h=obj.traceInfo;
            sfFeatureOn=true;
            machine=[];%#ok<*NASGU>
            if sfFeatureOn
                machine=find(get_param(h.Model,'Object'),'-isa','Stateflow.Machine','name',h.Model);%#ok<GTARG>
            end

            includeSl=true;
            includeSf=sfFeatureOn&&...
            ~isempty(find(get_param(h.Model,'Object'),'-isa','Stateflow.Machine',...
            'name',h.Model));%#ok<GTARG>
            includeEml=sfFeatureOn;

            for sys=1:length(h.SystemMap)
                if isempty(h.SystemMap(sys))
                    continue
                end
                [first,last]=locGetRegistryIndices(h,sys);
                if isempty(first)||first>last
                    continue
                end
                systemType=h.SystemMap(sys).type;
                includeSfEmlOnly=false;
                switch systemType
                case 'Root system'
                    if~includeSl,continue,end
                    isSf=false;
                    systemTypeMsg=DAStudio.message('RTW:report:RootSystem');
                case 'Subsystem'
                    if~includeSl,continue,end
                    isSf=false;
                    systemTypeMsg=DAStudio.message('RTW:report:Subsystem');
                case 'Chart'
                    if~includeSf&&~includeEml,continue,end
                    isSf=true;
                    if~includeSf
                        includeSfEmlOnly=true;
                    end
                    systemTypeMsg=DAStudio.message('RTW:report:Chart');
                case 'MATLAB Function'
                    if~includeEml,continue,end
                    isSf=true;
                    systemTypeMsg=DAStudio.message('RTW:report:MATLABFunction');
                case 'Truth Table'
                    continue
                otherwise
                    isSf=false;
                    systemTypeMsg=systemType;
                end

                sysname=h.SystemMap(sys).pathname;

                if~includeSfEmlOnly
                    tmp=Paragraph([systemTypeMsg,': ',sysname]);
                    tmp.Style={Bold()};
                    obj.append(tmp);
                end


                if strcmp(systemType,'MATLAB Function')
                    hBlk=get_param(h.SystemMap(sys).pathname,'Handle');
                    emchart=sfprivate('block2chart',hBlk);
                    hEml=idToHandle(slroot,emchart);
                    hTrace=h;
                    table=get_eml(hEml(1),hTrace,h.SystemMap(sys).pathname);
                    obj.append(table);
                    obj.append(Paragraph());


                    continue;
                end

                col1={DAStudio.message('RTW:report:ObjectName')};
                col2={DAStudio.message('RTW:report:CodeLocation')};
                tmp_registry=h.getRegistry;
                if~includeSfEmlOnly
                    for k=first:last
                        if isempty(tmp_registry(k).location)
                            continue
                        end
                        reg=tmp_registry(k);

                        if isSf&&locIsSfAuxOrSimFcn(reg.rtwname)
                            continue
                        end


                        tmp='';
                        if locIsSfObj(reg.rtwname)
                            tmp=locWriteSfType(reg.pathname);
                        end
                        col1{end+1}=[tmp,reg.rtwname];

                        col2{end+1}=loc_printCodeLocations(reg.location);
                    end

                    if length(col1)>1
                        table=Table([col1',col2']);
                        table.StyleName='TableStyleAltRow';
                        obj.append(table);
                        obj.append(Paragraph());
                    else
                        tmp=Paragraph(DAStudio.message('RTW:report:NoTraceableObjects',systemType));
                        obj.append(tmp);
                    end
                end


                if includeEml&&isSf
                    eh=locFindEMFunctions(machine,h.SystemMap(sys).pathname);
                    if~isempty(eh)
                        for k=1:length(eh)
                            ssIdNumber=locGetEMFunctionName(eh(k));

                            hlink=[Simulink.ID.getFullName(eh(k)),':',ssIdNumber];
                            tmp=Paragraph([DAStudio.message('RTW:report:MATLABFunction'),': ',hlink]);
                            tmp.Style={Bold()};
                            obj.append(tmp);




                            table=get_eml(eh(k),h,h.SystemMap(sys).pathname);
                            p=Paragraph();
                            obj.append(table);
                            obj.append(p);
                        end
                    end
                end
            end
        end
    end
end


function h=loc_getTraceInfo(reportInfo)
    subsys=reportInfo.SourceSubsystem;
    if isempty(subsys)
        rootsys=reportInfo.ModelName;
    else

        rootsys=strtok(subsys,'/:');
    end
    h=RTW.TraceInfo.instance(rootsys);
    if~isa(h,'RTW.TraceInfo')
        h=loc_createTraceInfo(reportInfo,rootsys);
    end
end
function h=loc_createTraceInfo(reportInfo,rootsys)
    h=RTW.TraceInfo(rootsys);
    subsys=reportInfo.SourceSubsystem;
    buildDir=reportInfo.getBuildDir();
    sortedFileInfoList=reportInfo.getSortedFileInfoList();
    traceInfo_fileList={};
    for n=1:sortedFileInfoList.NumFiles
        if(isequal(fileparts(sortedFileInfoList.FileName{n}),buildDir))
            traceInfo_fileList{length(traceInfo_fileList)+1}=sortedFileInfoList.FileName{n};
        end
    end
    hlink=false;
    currModel=reportInfo.ModelName;
    ssHdl=[];
    newSSName='';
    if~isValidSlObject(slroot,currModel)
        if~isempty(reportInfo.SourceSubsystem)
            ssHdl=get_param(reportInfo.SourceSubsystem,'Handle');
            newSSName=reportInfo.TemporaryModelFullSSName;
        end
    else
        ssHdl=rtwprivate('getSourceSubsystemHandle',currModel);
        newSSName=rtwprivate('getNewSubsystemName',currModel);
    end
    modelPath=get_param(rootsys,'FileName');
    traceRequirements=false;
    bLink2Webview=false;
    if(~isempty(subsys)||isempty(coder.internal.ModelCodegenMgr.getInstance(currModel)))
        systemMap=reportInfo.SystemMap;
    else
        systemMap=[];
    end
    bBlockSIDComment=coder.internal.isBlockSIDCommentEnabled(rootsys);
    arg={hlink,currModel,ssHdl,newSSName,...
    modelPath,buildDir,traceRequirements,bLink2Webview,bBlockSIDComment,systemMap};
    gentrace=true;
    HtmlFileName=cell(size(sortedFileInfoList.FileName));
    for i=1:length(HtmlFileName)
        HtmlFileName{i}=tempname;
    end
    tempFolder=tempname;
    currDir=pwd;

    rtwprivate('rtw_create_directory_path',tempFolder);
    cd(tempFolder);
    try
        rtwprivate('rtwctags',sortedFileInfoList.FileName,...
        arg,true,...
        HtmlFileName,...
        gentrace,'utf-8');
    catch
        cd(currDir);
    end
    cd(currDir);
    h.setBuildDir(buildDir,'-noload','-standalone');
    h.setRegistry(traceInfo_fileList);
    h.setSubsystemInfo(subsys,reportInfo.ModelName);
















    h.saveTraceInfo;
end

function[first,last]=locGetRegistryIndices(h,sys)
    first=h.SystemMap(sys).location;
    last=[];
    if isempty(first),return,end
    for k=sys+1:length(h.SystemMap)
        if~isempty(h.SystemMap(k).location)
            last=h.SystemMap(k).location-1;
            break
        end
    end
    if isempty(last)
        last=length(h.getRegistry);
    end
end

function out=locIsSfAuxOrSimFcn(rtwname)
    out=length(strfind(rtwname,':'))~=1;
end
function out=locFindEMFunctions(machine,blockpath)
    chart=find(machine,'-isa','Stateflow.Chart','Path',blockpath);
    out=find(chart,'-isa','Stateflow.EMFunction');
end

function out=locGetEMFunctionName(eh)
    out=num2str(sf('get',eh.Id,'.ssIdNumber'));
end

function out=locWriteSfType(pathname)
    out='';
    hObj=sfprivate('ssIdToHandle',pathname);
    name='';
    switch class(hObj)
    case 'Stateflow.State'
        typename=DAStudio.message('RTW:report:State');
        name=hObj.Name;
    case 'Stateflow.TruthTable'
        typename=DAStudio.message('RTW:report:TruthTable');
        name=hObj.Name;
    case 'Stateflow.EMFunction'
        typename=DAStudio.message('RTW:report:MATLABFunction');
        name=hObj.Name;
    case 'Stateflow.Transition'
        if sf('get',hObj.Id,'.autogen.isAutoCreated')
            src=sf('get',hObj.Id,'.autogen.source');
            if sfprivate('is_truth_table_fcn',src)
                typename=DAStudio.message('RTW:report:TruthTable');
                name=sf('get',src,'.name');
            else
                typename=DAStudio.message('RTW:report:Transition');
            end
        else
            typename='Transition';
        end
    case 'Stateflow.Function'
        typename=DAStudio.message('RTW:report:Function');
        name=hObj.Name;
    otherwise
        [~,typename]=strtok(class(hObj),'.');
        if~isempty(typename)
            typename=typename(2:end);
        end
    end
    if~isempty(typename)
        out=[typename,' '];
        if~isempty(name)
            out=[out,'''',name,''' '];
        end
    end
end






function out=loc_printCodeLocations(locs)
    prev='';
    out='';
    hyperlink='';
    hyperlinkEnd='';
    linebreak=sprintf('\n');
    for k=1:length(locs)
        [~,file,ext]=fileparts(locs(k).file);
        ln=sprintf('%d',locs(k).line);
        buf='';
        if~strcmp(locs(k).file,prev)
            if~isempty(prev)
                buf=[buf,linebreak];
            end
            buf=[buf,hyperlink,file,ext,':',ln,hyperlinkEnd];
            prev=locs(k).file;
        else
            buf=[', ',hyperlink,ln,hyperlinkEnd];
        end
        out=[out,buf];
    end
end

function out=locIsSfObj(rtwname)

    k=strfind(rtwname,'>');
    out=length(rtwname)>k(1)&&rtwname(k(1)+1)==':';
end

function table=get_eml(hEml,hTrace,block)



    import mlreportgen.dom.*
    emlScript=locGetEmbeddedMATLABScript(hEml,block,hTrace);
    table=Table(3);
    row=TableRow;
    row.append(TableEntry(''));
    row.append(TableEntry('Script'));
    row.append(TableEntry(DAStudio.message('RTW:report:CodeLocation')));
    table.append(row);
    for k=1:size(emlScript,1)
        row=TableRow;
        row.append(TableEntry(emlScript{k,1}));
        t=Text(emlScript{k,2});
        t.StyleName='TextStyleCode';
        te=TableEntry(t);
        t.StyleName='TextStyleCode';
        row.append(te);
        row.append(TableEntry(emlScript{k,3}));
        table.append(row);
    end
    table.StyleName='TableStyleAltRow';
end

function out=locGetEmbeddedMATLABScript(hEml,block,hTrace)

    out=[];


    if isa(hEml,'Stateflow.EMChart')
        chart=sf('get',hEml.Id,'.states');
        ssIdNum=sf('get',chart,'.ssIdNumber');
    elseif isa(hEml,'Stateflow.EMFunction')
        ssIdNum=hEml.SSIdNumber;
    else
        return
    end

    emlScript=hEml.Script;


    lines=textscan(emlScript,'%s','Whitespace','','Delimiter','\n');
    lines=lines{1};
    blank=false;
    for n=1:length(lines)
        tok=strtok(lines{n});
        if~isempty(tok)
            if tok(1)=='%',continue,end
            blank=false;
        else
            if blank,continue,end
            blank=true;
        end
        linenum=num2str(n);
        out{end+1,1}=linenum;

        out{end,2}=lines{n};

        if~isempty(hTrace)
            locs=hTrace.getCodeLocations([block,sprintf(':%d:%d',ssIdNum,n)]);
            location=loc_printCodeLocations(locs);
            out{end,3}=location;
        else
            out{end,3}='';
        end
    end
end

