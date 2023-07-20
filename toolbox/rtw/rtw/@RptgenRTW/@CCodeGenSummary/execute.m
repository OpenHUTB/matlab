function out=execute(thisComp,parentDoc)

















    out=[];
    adSL=rptgen_sl.appdata_sl;
    switch lower(adSL.Context)
    case{'','model','none'}
        currObj=adSL.CurrentModel;


    otherwise

        return
    end

    currModel=currObj;
    if~isempty(adSL.ReportedSystemList)
        currObj=adSL.ReportedSystemList{1};
    end

    [srcDir,prjDir]=RptgenRTW.getBuildDir;

    if~exist(srcDir,'dir')
        thisComp.status(DAStudio.message('RTW:report:buildFolderNotFound',srcDir),1);
        return
    end

    if~exist(prjDir,'dir')
        thisComp.status(DAStudio.message('RTW:report:slprjNotFound'),1);
        return
    end

    try
        if exist(fullfile(prjDir,'binfo.mat'),'file')
            load(fullfile(prjDir,'binfo.mat'));
        else
            load(fullfile(prjDir,'binfo_mdlref.mat'));
        end
    catch
        thisComp.status(DAStudio.message('RTW:report:buildInfoNotFound'),1);
        return
    end

    out=parentDoc.createDocumentFragment;

    if thisComp.General_information
        thisComp.makeSection(parentDoc);
        thisComp.addTitle(parentDoc,DAStudio.message('RTW:report:GeneralInformation'));

        tableTitle=DAStudio.message('RTW:report:VersionInformation');
        tableSrc{1,1}=DAStudio.message('RTW:report:ModelVersion');
        tableSrc{1,2}=get_param(currModel,'ModelVersion');
        tableSrc{2,1}=DAStudio.message('RTW:report:SimulinkCoderVersion');
        version_rtw=ver('simulinkcoder');
        tableSrc{2,2}=version_rtw.Version;

        tm=makeNodeTable(parentDoc,...
        tableSrc,...
        0,...
        true);
        tm.setColWidths([2,1]);
        tm.setTitle(tableTitle);
        tm.setNumHeadRows(0);
        m=tm.createTable;

        thisComp.RunTimeSerializer.write(m);

        m=getSrcList(srcDir,parentDoc);
        if~isempty(m)
            thisComp.RunTimeSerializer.write(m);
        end
        m=thisComp.closeSection;
        if~isempty(m)
            out.appendChild(m);
        end
    else

    end

    if thisComp.Configuration_settings
        thisComp.makeSection(parentDoc);
        thisComp.addTitle(parentDoc,DAStudio.message('RTW:report:secConfigurationSettings'));
        pane={'RTW:configSet:configSetOptimization',...
        'RTW:configSet:configSetCodeGen'};
        for i=1:length(pane)
            m=getConfig(infoStructConfigSet,pane{i},parentDoc);
            if~isempty(m)
                thisComp.RunTimeSerializer.write(m);
            end
        end
        m=thisComp.closeSection;
        if~isempty(m)
            out.appendChild(m);
        end
    end

    if thisComp.Subsystem
        thisComp.makeSection(parentDoc);
        thisComp.addTitle(parentDoc,DAStudio.message('RTW:report:secSubsystemMap'));
        n=length(infoStruct.SystemMap);
        sysmap=cell(n,2);
        for i=1:n
            sysmap{i,1}=sprintf('<S%d>',i);
            sysmap{i,2}=infoStruct.SystemMap{i};
            if~strcmp(currObj,currModel)

                try
                    [tmp,sysName]=strtok(infoStruct.SystemMap{i},'/');
                    sysmap{i,2}=[get_param(currObj,'Parent'),sysName];
                catch
                end
            end
        end
        if~isempty(sysmap)
            tm=makeNodeTable(parentDoc,...
            sysmap,...
            0,...
            true);
            tm.setColWidths([1,4]);
            tm.setTitle(DAStudio.message('RTW:report:subsystemMap'));
            tm.setNumHeadRows(0);
            m=tm.createTable;

            thisComp.RunTimeSerializer.write(m);
        end
        m=thisComp.closeSection;
        if~isempty(m)
            out.appendChild(m);
        end
    else

    end

    if thisComp.Makefile
        if~isempty(infoStruct.makeCmd)
            paraTitle='Generated makefile and make command';
            paraSrc='To build binary, use the following make command:';
            m=execute(rptgen.cfr_paragraph(...
            'TitleType','specify',...
            'ParaTitle',paraTitle,...
            'ParaText',paraSrc),...
            parentDoc);
            out.appendChild(m);

            m=execute(rptgen.cfr_text(...
            'Content',['    ',infoStruct.makeCmd],...
            'isCode',true),...
            parentDoc);
            out.appendChild(m);
        end

    else

    end

    if thisComp.Use_setting_from_model
        cs=getActiveConfigSet(adSL.CurrentModel);
        includeElim=strcmp(get_param(cs,'GenerateTraceReport'),'on');
        includeSl=strcmp(get_param(cs,'GenerateTraceReportSl'),'on');
        includeSf=strcmp(get_param(cs,'GenerateTraceReportSf'),'on');
        includeEml=strcmp(get_param(cs,'GenerateTraceReportEml'),'on');
    else
        includeElim=thisComp.Eliminated_virtual_blocks;
        includeSl=thisComp.Traceable_Simulink_blocks;
        includeSf=thisComp.Traceable_Stateflow_objects;
        includeEml=thisComp.Traceable_Embedded_MATLAB_functions;
    end

    if includeElim||includeSl||includeSf||includeEml
        if strcmp(get_param(currObj,'GenerateTraceInfo'),'off')
            thisComp.status(DAStudio.message('RTW:traceInfo:optionOff'),3)
        else

            thisComp.makeSection(parentDoc);
            thisComp.addTitle(parentDoc,DAStudio.message('RTW:report:traceabilityReport'));


            hTraceInfo=RTW.TraceInfo.instance(currObj);
            buildDir=RptgenRTW.getBuildDir;
            if~isa(hTraceInfo,'RTW.TraceInfo')
                hTraceInfo=RTW.TraceInfo(currObj);
            end


            msg='';
            try
                hTraceInfo.setBuildDir(buildDir);
            catch ME
                thisComp.status(ME.message,2);
                msg=[DAStudio.message('RTW:report:error'),': ',ME.message];
            end

            if isempty(msg)
                warnMsg=hTraceInfo.getLastWarningMessage;
                if~isempty(warnMsg)
                    thisComp.status(warnMsg,3);
                    msg=[DAStudio.message('RTW:report:warning'),': ',warnMsg];
                end
            end


            if~isempty(msg)
                m=execute(rptgen.cfr_text(...
                'Content',msg,...
                'isCode',false),...
                parentDoc);
                thisComp.RunTimeSerializer.write(m);
            end


            if isa(hTraceInfo,'RTW.TraceInfo')&&hTraceInfo.isReady

                reg=hTraceInfo.getRegistry;
                untraceable={DAStudio.message('RTW:report:colObjectName'),...
                DAStudio.message('RTW:report:colComment')};
                reasonMap=hTraceInfo.getBlockReductionReasons;
                for k=1:length(reg)
                    if isempty(reg(k).location)
                        untraceable{end+1,1}=reg(k).rtwname;%#ok<AGROW>
                        [~,reason]=hTraceInfo.getReason(reasonMap,reg(k));
                        untraceable{end,2}=reason;
                    end
                end


                if includeElim
                    tm=makeNodeTable(parentDoc,...
                    untraceable,...
                    0,...
                    true);
                    tm.setColWidths([1,3]);
                    tm.setTitle(DAStudio.message('RTW:report:secEliminatedVirtualBlocks'));
                    tm.setNumHeadRows(1);
                    m=tm.createTable;
                    thisComp.RunTimeSerializer.write(m);
                end

                if includeSf||includeEml

                    machine=find(sfroot,'-isa','Stateflow.Machine',...
                    'Name',adSL.CurrentModel);%#ok<GTARG>
                end
                sysmap=hTraceInfo.SystemMap;
                numsys=length(sysmap);
                for n=1:numsys
                    sys=sysmap(n);
                    first=sys.location;

                    if n==numsys
                        next=length(reg)+1;
                    else
                        next=sysmap(n+1).location;
                    end
                    if isempty(first)||isempty(next)
                        continue
                    end

                    systype=lower(sys.type);
                    isSlSystem=strcmp(systype,'root system')||strcmp(systype,'subsystem');
                    isSfChart=strcmp(systype,'chart');
                    isEmlBlock=strcmp(systype,'matlab function');
                    if~includeSl&&isSlSystem
                        continue
                    end
                    if includeEml&&isSfChart
                        chart=find(machine,'-isa','Stateflow.Chart',...
                        'Path',sys.pathname);%#ok<GTARG>
                        emfunctions=find(chart,'-isa','Stateflow.EMFunction');
                    else
                        emfunctions=[];
                    end
                    skipSf=false;
                    if~includeSf&&isSfChart
                        if includeEml&&~isempty(emfunctions)
                            skipSf=true;
                        else
                            continue
                        end
                    end
                    if~includeEml&&isEmlBlock
                        continue
                    end
                    traceable={DAStudio.message('RTW:report:colObjectName'),...
                    DAStudio.message('RTW:report:colCodeLocation')};
                    for k=first:next-1
                        if~isempty(reg(k).location)&&~skipSf&&...
                            ~(isSfChart&&length(strfind(reg(k).rtwname,':'))~=1)
                            traceable{end+1,1}=reg(k).rtwname;
                            traceable{end,2}=getCodeLocations(reg(k).location);
                        end
                    end


                    if(includeSl&&isSlSystem)||(includeSf&&isSfChart)
                        title=[sys.type,' - ',sys.pathname];
                        tm=makeNodeTable(parentDoc,...
                        traceable,...
                        0,...
                        true);
                        tm.setColWidths([1,3]);
                        tm.setTitle(title);
                        tm.setNumHeadRows(1);
                        m=tm.createTable;
                        thisComp.RunTimeSerializer.write(m);
                    end
                    if includeEml
                        eml={};
                        name={};
                        if isSfChart
                            len=length(emfunctions);
                            eml=cell(1,len);
                            name=cell(1,len);
                            for p=1:len
                                eml{p}=coder.internal.eml2html([],emfunctions(p),[]);
                                name{p}=emfunctions(p).Name;
                            end
                        elseif isEmlBlock
                            emchart=find(machine,'-isa','Stateflow.EMChart',...
                            'Path',sys.pathname);%#ok<GTARG>

                            if isempty(emchart)
                                hid=slreportgen.utils.HierarchyService.getDiagramHID(sys.pathname);
                                emchart=slreportgen.utils.getSlSfHandle(hid);
                            end
                            eml{1}=coder.internal.eml2html([],emchart,[]);%#ok<AGROW>
                            name{1}='';%#ok<AGROW>

                        end
                        for p=1:length(eml)
                            title=[DAStudio.message('RTW:report:secEmbeddedMatlabFunction')...
                            ,' - ',sys.pathname];
                            if~isempty(name{p})
                                title=[title,':',name{p}];%#ok<AGROW>
                            end
                            tm=makeNodeTable(parentDoc,...
                            eml{p},...
                            0,...
                            true);
                            tm.setColWidths([1,10,4]);
                            tm.setTitle(title);
                            tm.setNumHeadRows(0);
                            m=tm.createTable;
                            thisComp.RunTimeSerializer.write(m);
                        end
                    end
                end
            end

            m=thisComp.closeSection;
            if~isempty(m)
                out.appendChild(m);
            end
        end
    else

    end

    function out=getConfig(configSet,pane,parentDoc)
        tableSrc{1,1}=DAStudio.message('RTW:report:colOptionName');
        tableSrc{1,2}=DAStudio.message('RTW:report:colValue');

        switch pane
        case 'RTW:configSet:configSetOptimization'
            params=RptgenRTW.getConfigOpt();
        case 'RTW:configSet:configSetCodeGen'
            params=RptgenRTW.getConfigRTW();
        end
        paneName=DAStudio.message(pane);
        for i=1:size(params,1)
            tableSrc{i+1,1}=params{i,1};
            try
                tableSrc{i+1,2}=configSet.get_param(params{i,2});
            catch me
                tableSrc{i+1,2}=me.message;
            end
        end

        tm=makeNodeTable(parentDoc,...
        tableSrc,...
        0,...
        true);
        tm.setColWidths([3,1]);
        tm.setTitle([DAStudio.message('RTW:report:configurationSet'),' > ',paneName]);
        tm.setNumHeadRows(1);
        out=tm.createTable;



        function out=getSrcList(srcDir,parentDoc)
            listSrc=rtwprivate('rtwfindfile',srcDir,{'c','h','cpp','hpp'});

            if rptgen.use_java
                m=com.mathworks.toolbox.rptgencore.docbook.ListMaker(listSrc);
            else
                m=mlreportgen.re.internal.db.ListMaker(listSrc);
            end

            m.setTitle(DAStudio.message('RTW:report:generatedFiles'));
            m.setListType('itemizedlist');
            m.setNumerationType('arabic');
            m.setInheritnumType('ignore');
            m.setContinuationType('restarts');
            m.setSpacingType('compact');
            out=m.createList(parentDoc.Document);

            function out=getCodeLocations(locs)
                prev='';
                location='';
                for k=1:length(locs)
                    [nu,file,ext]=fileparts(locs(k).file);
                    if~strcmp(locs(k).file,prev)
                        if~isempty(prev)
                            location=sprintf('%s\n',location);
                        end
                        location=sprintf('%s%s%s:%d',location,file,ext,locs(k).line);
                        prev=locs(k).file;
                    else
                        location=sprintf('%s, %d',location,locs(k).line);
                    end
                end
                out=location;



