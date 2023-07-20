function out=execute(thisComp,parentDoc,varargin)


















    out=[];
    adSL=rptgen_sl.appdata_sl;
    switch lower(adSL.Context)
    case{'','model','none'}
        currObj=adSL.CurrentModel;
    case{'system'}
        thisComp.status(DAStudio.message('RTW:report:codeImportInSysLoop'),1);
        return
    otherwise
        thisComp.status(DAStudio.message('RTW:report:codeImportInUnknown'),1);
        return
    end

    srcsys=RptgenRTW.getSourceSubsystem;
    if~isempty(srcsys)
        currObj=srcsys;
    end

    if isempty(currObj)
        thisComp.status(DAStudio.message('RTW:report:modelNotFound'),1);
        return
    end



    currModel=adSL.CurrentModel;

    adRG=rptgen.appdata_rg;

    html_dir=adRG.ImageDirectory;

    src_dir=RptgenRTW.getBuildDir;

    if~exist(src_dir,'dir')
        thisComp.status(DAStudio.message('RTW:report:buildFolderNotFound',src_dir),1);
        return
    end

    if~exist(html_dir,'dir')
        mkdir(html_dir);
    end

    out=parentDoc.createDocumentFragment;

    src_files={};

    [mdlfilesC,rtwfilesC]=RptgenRTW.getGeneratedCodeList(currObj,src_dir,...
    {'c','cpp'});

    [mdlfilesH,rtwfilesH]=RptgenRTW.getGeneratedCodeList(currObj,src_dir,...
    {'h','hpp'});

    if thisComp.Source_files__auto_generated
        src_files=[src_files;mdlfilesC];
        if thisComp.include_rtw_c
            src_files=[src_files;rtwfilesC];
        end
    end


    if thisComp.Header_files__auto_generated
        src_files=[src_files;mdlfilesH];
        if thisComp.include_rtw_h
            src_files=[src_files;rtwfilesH];
        end
    end

    if thisComp.Custom_files
        try
            cust_files=RptgenRTW.getCustomCodeList(currModel);
        catch
            thisComp.status(DAStudio.message('RTW:report:customCodeNotFound'),1);
        end
        src_files=[src_files;cust_files];
    end

    filtered=RptgenRTW.getSourceFileNames(src_files);
    excluded=setxor(filtered,src_files);
    if~isempty(excluded)
        thisComp.status(DAStudio.message('RTW:report:filesExcluded'),2);
    end
    src_files=filtered;

    html_files={};
    htm_files={};
    for i=1:length(src_files)
        [p,fileName,ext]=fileparts(src_files{i});
        ext(1)='_';
        html_files=[html_files;fullfile(html_dir,[fileName,ext,'.html'])];
        htm_files=[htm_files;fullfile(html_dir,[fileName,ext,'.htm'])];
    end


    convert2HTML=false;
    if strcmp(adRG.RootComponent.Format,'html')
        convert2HTML=true;
    end
    if convert2HTML
        try
            opt='r';
            rtwprivate('rtwctags',src_files,false,true,html_files,false,opt);
            rtwprivate('rtwctags_esc',html_files);
        catch
            convert2HTML=false;
        end
    end

    if convert2HTML
        importType='external';
    else
        importType='fixedwidth';
    end

    for i=1:length(src_files)
        if convert2HTML
            if exist(htm_files{i},'file')==2
                fileName=htm_files{i};
                builtin('delete',html_files{i});
            else
                fileName=html_files{i};
            end
        else
            fileName=src_files{i};
        end
        try
            if rptgen.use_java
                srccode=javaMethod('importFile',...
                'com.mathworks.toolbox.rptgencore.docbook.FileImporter',...
                importType,...
                fileName,...
                java(parentDoc));
            else
                srccode=rptgen.internal.docbook.FileImporter.importFile(...
                importType,...
                fileName,...
                parentDoc.Document);
            end
            if strcmpi(importType,'external')
                adRG=rptgen.appdata_rg;
                adRG.PostConvertImport=true;
            end


            section=makeCodeGenSection(thisComp,parentDoc,src_files{i},srccode);
            out.appendChild(section);
        catch
            errMsg=[DAStudio.message('RTW:report:cannotImportFile',fileName)];
            out=parentDoc.createComment(errMsg);
            thisComp.status(errMsg,1);
        end
    end

    function section=makeCodeGenSection(thisComp,parentDoc,fileName,contents)

        thisComp.makeSection(parentDoc);

        [p,fName,fExt]=fileparts(fileName);
        titleContent=parentDoc.createDocumentFragment(...
        DAStudio.message('RTW:report:generatedCodeListing'),' - ',[fName,fExt]);
        thisComp.addTitle(parentDoc,titleContent);

        tableSrc={DAStudio.message('RTW:report:fileName'),[fName,fExt];DAStudio.message('RTW:report:fullPath'),p};

        tm=makeNodeTable(parentDoc,...
        tableSrc,...
        0,...
        true);
        tm.setColWidths([1,4]);
        tm.setNumHeadRows(0);
        tbl=tm.createTable;

        thisComp.RunTimeSerializer.write(tbl);
        thisComp.RunTimeSerializer.write(contents);
        section=thisComp.closeSection;



