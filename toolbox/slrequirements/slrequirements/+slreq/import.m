












































































































































































































































































function[count,reqSetFile,reqSetObj]=import(docInfo,varargin)


    count=0;
    reqSetFile='';
    reqSetObj=[];

    if nargin<1
        error(message('Slvnv:slreq_import:NeedDocNameOrType'));
    end

    if nargin==1&&strcmpi(docInfo,'clearcache')
        cleanupUserCacheDir();
        return;
    end

    docInfo=convertStringsToChars(docInfo);
    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    [reqSetArg,doProxy,options,~,autoDetectMappingReqIF]=getOptionalArguments(varargin{:});

    [docType,docPath]=resolveDocTypeAndLocation(docInfo,options);


    if isempty(docType)
        error(message('Slvnv:reqmgt:getLinktype:UnregisteredTarget',docInfo));

    elseif isempty(docPath)

        error(message('Slvnv:oslc:MakeSureArtifactAccessible'));
    end

    isUpdate=isa(reqSetArg,'slreq.data.RequirementSet')&&strcmp(reqSetArg.name,'SCRATCH');

    options.docPath=docPath;
    if~isfield(options,'ReqSet')
        options.ReqSet=reqSetArg;
    end
    options.AsReference=doProxy;

    if strcmpi(docType.Registration,'reqif')
        options.autoDetectMapping=autoDetectMappingReqIF;
    end

    updateDetectionMgr=slreq.dataexchange.UpdateDetectionManager.getInstance();

    if~isfield(options,'preImportFcn')
        options.preImportFcn='';
    end

    if~isfield(options,'postImportFcn')
        options.postImportFcn='';
    end





    if~isUpdate
        if ischar(reqSetArg)


            if slreq.app.MainManager.exists()
                appMgr=slreq.app.MainManager.getInstance();
                appMgr.setSelectedObject(slreq.das.ReqLinkBase.empty());
            end
        end
        importOptions=slreq.internal.callback.ImportOptionFactory.createImportOptions(docType.Registration,options);
        if~isempty(options.preImportFcn)
            slreq.internal.callback.Utils.executeCallback([],'preImportFcn',options.preImportFcn,importOptions);
        end
        options=importOptions.exportOptions;
    end

    try
        switch docType.Registration

        case 'REQIF'



            if~isfield(options,'singleSpec')
                options.singleSpec='';
            end

            if~isfield(options,'asMultiple')
                options.asMultiple=false;
            end

            if~isfield(options,'importLinks')
                options.importLinks=true;
            end

            reqSetArg=options.ReqSet;
            if isa(reqSetArg,'slreq.ReqSet')
                reqSetName=reqSetArg.Filename;
            else
                reqSetName=reqSetArg;
            end
            if isfield(options,'mappingFile')
                [reqSetObj,count,topImportNodes]=...
                slreq.internal.importFromReqIF(reqSetName,...
                options.docPath,options.mappingFile,options.AsReference,...
                options.asMultiple,...
                options.singleSpec,...
                options.importLinks);
                reqSetFile=reqSetObj.Filename;
            elseif isfield(options,'attr2reqprop')


                mappingFile=slreq.internal.writeMappingToFile(options.docPath,options.attr2reqprop);
                [reqSetObj,count,topImportNodes]=...
                slreq.internal.importFromReqIF(reqSetName,...
                options.docPath,mappingFile,options.AsReference,...
                options.asMultiple,...
                options.singleSpec,...
                options.importLinks);
                reqSetFile=reqSetObj.Filename;
                delete(mappingFile);
            elseif options.autoDetectMappingReqIF
                mappingMgr=slreq.app.MappingFileManager.getInstance();
                [mappingInfo,reqifParseError]=mappingMgr.detectMapping(options.docPath);
                if~isempty(reqifParseError)

                    error(message('Slvnv:slreq_import:InvalidReqifParserError',reqifParseError));
                end
                mappingFile=mappingInfo.fullpath;
                if~isempty(mappingFile)


                    [reqSetObj,count,topImportNodes]=...
                    slreq.internal.importFromReqIF(reqSetName,...
                    options.docPath,mappingFile,options.AsReference,...
                    options.asMultiple,...
                    options.singleSpec,...
                    options.importLinks);
                    reqSetFile=reqSetObj.Filename;
                else



                    error(message('Slvnv:slreq_import:InvalidReqifAttributeMapping'));
                end
            else


                [reqSetObj,count,topImportNodes]=...
                slreq.internal.importFromReqIF(reqSetName,...
                options.docPath,[],options.AsReference,...
                options.asMultiple,...
                options.singleSpec,...
                options.importLinks);
                reqSetFile=reqSetObj.Filename;
            end
            updateDetectionMgr.checkUpdatesForAllArtifacts();

            for index=1:length(topImportNodes)
                if topImportNodes{index}.external
                    topImportNodes{index}.setPreImportFcn(options.preImportFcn);
                    topImportNodes{index}.setPostImportFcn(options.postImportFcn);
                end
            end
            topImportNodes=[topImportNodes{:}];
            if~isempty(topImportNodes)
                topImportNodes.executeCB('postImportFcn',importOptions)
            end
            return;

        case 'linktype_rmi_word'
            [count,reqSetFile,topImportNodes]=slreq.import.wordDocToReqSet(docPath,reqSetArg,options.AsReference,options);

        case 'linktype_rmi_excel'
            [count,reqSetFile,topImportNodes]=slreq.import.xlsDocToReqSet(docPath,reqSetArg,options.AsReference,options);

        otherwise

            [count,reqSetFile,topImportNodes]=slreq.import.customDefinedImport(docType,docPath,reqSetArg,options.AsReference,options);
        end

    catch ex
        throw(ex);
    end

    reqSetObj=slreq.data.ReqData.getInstance.getReqSet(reqSetFile);
    if isempty(reqSetObj)

        return;
    end


    updateDetectionMgr.checkUpdatesForAllArtifacts();

    if~isUpdate

        if~isempty(topImportNodes)&&topImportNodes.external
            topImportNodes.setPreImportFcn(options.preImportFcn);
            topImportNodes.setPostImportFcn(options.postImportFcn);
            topImportNodes.executeCB('postImportFcn',importOptions);
        end
    end

    if count>0&&isNameMatched(docPath,reqSetFile)
        reqSetObj.save();
    end

    reqSetObj=slreq.utils.dataToApiObject(reqSetObj);


    if nargout==0
        disp(getString(message('Slvnv:slreq_import:ImportedCountFromTo',num2str(count),docPath,reqSetFile)));
    end

end



function[reqSetArg,doProxy,options,useLegacyReqIF,autoDetectMapping]=getOptionalArguments(varargin)
    if mod(nargin,2)~=0
        error(message('Slvnv:reqmgt:rmi:WrongArgumentNumber'));
    end
    reqSetArg='';
    doProxy=true;
    options=[];
    useLegacyReqIF=false;
    autoDetectMapping=true;
    for i=1:2:nargin
        name=varargin{i};
        value=varargin{i+1};
        switch lower(name)
        case 'options'
            if isstruct(value)



                if isstruct(options)
                    options=mergeOptions(value,options);
                else
                    options=value;
                end
                if isfield(options,'ReqSet')
                    if ischar(options.ReqSet)
                        reqSetArg=options.ReqSet;
                    elseif isa(options.ReqSet,'slreq.ReqSet')
                        reqSetArg=options.ReqSet.Filename;
                    end
                end
                if isfield(options,'AsReference')
                    doProxy=options.AsReference;
                end
                return;
            else
                options.options=value;
            end
        case 'reqsetname'
            reqSetArg=value;
        case{'reqset','requirementset'}
            if isa(value,'slreq.ReqSet')
                reqSetArg=value.Filename;
            else
                reqSetArg=value;
            end
        case 'asreference'
            doProxy=value;
        case 'richtext'
            options.richText=value;
        case 'usdm'
            if isfield(options,'match')
                error(message('Slvnv:slreq_import:OptionConflict','slreq.import()','MATCH','USDM'));
            end



            options.usdm=value;
        case{'sheet','worksheet'}
            options.subDoc=value;
        case 'match'
            if isfield(options,'usdm')&&options.usdm
                error(message('Slvnv:slreq_import:OptionConflict','slreq.import()','MATCH','USDM'));
            end
            options.match=value;
        case 'uselegacyreqif'
            useLegacyReqIF=value;
        case 'autodetectmapping'
            autoDetectMapping=value;
        otherwise

            options.(name)=value;
        end
    end
end

function[docType,docPath]=resolveDocTypeAndLocation(docInfo,options)
    [docDir,~,docExt]=fileparts(docInfo);
    if isempty(docExt)



        docPath='';
        docType=rmi.linktype_mgr('resolveByRegName',docInfo);
        if~isempty(docType)
            if isfield(options,'DocID')

                docPath=options.DocID;

                docType.NavigateFcn(docPath,'');
            elseif~isempty(docType.SelectionLinkFcn)

                tempReq=docType.SelectionLinkFcn([],false);
                if~isempty(tempReq)
                    docPath=tempReq.doc;
                    if docType.isFile
                        docPath=rmiut.absolute_path(docPath,pwd);
                    end
                end
            end
        end
    else


        switch lower(docExt)
        case{'.reqif','.reqifz'}


            docType.Registration='REQIF';
        otherwise

            docType=rmi.linktype_mgr('resolveByFileExt',docInfo);
        end
        if isempty(docDir)

            docPath=fullfile(pwd,docInfo);
        elseif~rmiut.isCompletePath(docDir)

            docPath=rmiut.simplifypath(fullfile(pwd,docInfo));
        else

            docPath=docInfo;
        end
    end
end

function tf=isNameMatched(srcInfo,reqSetFile)
    [~,reqSetName]=fileparts(reqSetFile);
    tf=contains(srcInfo,reqSetName);
end

function options=mergeOptions(options,oldOptions)
    oldFields=fields(oldOptions);
    for i=1:numel(oldFields)
        field=oldFields{i};
        if isfield(options,field)
            if options.(field)==oldOptions.(field)

            else

                error(message('Slvnv:slreq_import:ConflictingArgument',field));
            end
        else
            options.(field)=oldOptions.(field);
        end
    end
end


function cleanupUserCacheDir()
    userCacheDirIMPORT=slreq.import.resourceCachePaths('IMPORT');
    if exist(userCacheDirIMPORT,'dir')

        rmdir(userCacheDirIMPORT,'s');
        mkdir(userCacheDirIMPORT);
    end
    userCacheDirWord=slreq.import.resourceCachePaths('MSWORD');
    if exist(userCacheDirWord,'dir')

        rmdir(userCacheDirWord,'s');
        mkdir(userCacheDirWord);
    end
    userCacheDirExcel=slreq.import.resourceCachePaths('MSEXCEL');
    if exist(userCacheDirExcel,'dir')

        rmdir(userCacheDirExcel,'s');
        mkdir(userCacheDirExcel);
    end
    userCacheDirDOORS=slreq.import.resourceCachePaths('DOORS');
    if exist(userCacheDirDOORS,'dir')

        rmdir(userCacheDirDOORS,'s');
        mkdir(userCacheDirDOORS);
    end
    userCacheDirReqIF=slreq.import.resourceCachePaths('REQIF');
    if exist(userCacheDirReqIF,'dir')

        rmdir(userCacheDirReqIF,'s');
        mkdir(userCacheDirReqIF);
    end
    userCacheDirScratch=slreq.import.resourceCachePaths('scratch');
    if exist(userCacheDirScratch,'dir')

        rmdir(userCacheDirScratch,'s');
        mkdir(userCacheDirScratch);
    end
    userCacheDirAttachments=slreq.import.resourceCachePaths('ATTACHMENTS');
    if exist(userCacheDirAttachments,'dir')

        rmdir(userCacheDirAttachments,'s');
        mkdir(userCacheDirAttachments);
    end
end


