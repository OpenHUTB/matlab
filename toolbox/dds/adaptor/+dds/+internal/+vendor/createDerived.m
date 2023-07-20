function createDerived(basedOn,newKey,newDisplayName,newBaseDir,newPackageName,verbose)










    validateattributes(basedOn,{'char','string'},{'nonempty'});
    validateattributes(newKey,{'char','string'},{'nonempty'});
    validateattributes(newDisplayName,{'char','string'},{'nonempty'});
    validateattributes(newBaseDir,{'char','string'},{'nonempty'});
    if nargin<5
        [~,newPackageName]=fileparts(newBaseDir);
        newPackageName=upper(newPackageName);
    else
        validateattributes(newPackageName,{'char','string'},{'nonempty'});
    end
    if nargin<6
        verbose=false;
    end
    validateattributes(verbose,{'logical'},{'scalar'});

    basedOn=convertStringsToChars(basedOn);
    newKey=convertStringsToChars(newKey);
    newDisplayName=convertStringsToChars(newDisplayName);
    newBaseDir=convertStringsToChars(newBaseDir);

    data=struct();
    reg=dds.internal.vendor.DDSRegistry;
    curList=reg.getVendorList;


    basedOnIdx=find(strcmp(basedOn,{curList(:).DisplayName}),1);
    if isempty(basedOnIdx)

        basedOnIdx=find(strcmp(basedOn,{curList(:).Key}),1);
        if isempty(basedOnIdx)
            allVendorList=sprintf('%s, ',curList(:).DisplayName);
            error(message('dds:vendor:BaseVendorNotFound',basedOn,allVendorList(1:end-2)));
        end
    end
    assert(~isempty(basedOnIdx));
    baseEntry=reg.getEntryFor(curList(basedOnIdx).Key);
    printInfo('dds:vendor:CreateBasedOn',baseEntry.DisplayName);


    newKey=lower(newKey);
    newKey=strrep(newKey,'.','_');
    data.newKey=dds.internal.coder.Util.genCppVarName(newKey,{curList(:).Key});


    newIdx=find(strcmp(newDisplayName,{curList(:).DisplayName}),1);
    if~isempty(newIdx)
        if isequal(newKey,curList(newIdx).Key)
            printInfo('dds:vendor:VendorRegistered',newDisplayName);
            return;
        else
            error(message('dds:vendor:VendorAlreadRegistered',newDisplayName));
        end
    end
    data.newDisplayName=newDisplayName;
    newToolchainName=[data.newDisplayName,' Project'];
    rtwReg=RTW.TargetRegistry.getInstance;
    rtwReg.refresh('coder.make.ToolchainInfoRegistry');
    if ismember(newToolchainName,{rtwReg.ToolchainInfos(:).Name})
        error(message('dds:vendor:ToolchainAlreadyRegistered',newToolchainName));
    end
    data.newToolchainName=newToolchainName;

    printInfo('dds:vendor:CreatingEntry',data.newKey,data.newDisplayName,data.newToolchainName);

    if~isfolder(newBaseDir)
        [status,emsg,emsgId]=mkdir(newBaseDir);
        if~status
            error(emsgId,strrep(emsg,'\','/'));
        end
    end
    data.newBaseDir=newBaseDir;
    data.newPackageName=newPackageName;
    printInfo('dds:vendor:UsingBaseDir',strrep(data.newBaseDir,'\','/'));


    data.registerVendorFuncName=['register',dds.internal.coder.Util.genCppVarName(data.newDisplayName,{})];
    registerFilePath=fullfile(data.newBaseDir,'+dds','+internal','+vendor',[data.registerVendorFuncName,'.m']);
    [status,emsg,emsgId]=mkdir(fileparts(fileparts(registerFilePath)),'+vendor');
    if~status
        error(emsgId,emsg);
    end
    thisDir=fileparts(mfilename('fullpath'));
    data.base.SetupModel=char(baseEntry.SetupModel);
    data.base.ImportXML=char(baseEntry.ImportXML);
    if isfield(baseEntry,'ImportXMLAndIDL')
        data.base.ImportXMLAndIDL=char(baseEntry.ImportXMLAndIDL);
    else
        data.base.ImportXMLAndIDL=[];
    end
    data.base.VendorPostCompileValidation=char(baseEntry.VendorPostCompileValidation);

    data.base.ExportToXML=char(baseEntry.ExportToXML);
    data.base.GenerateIDLAndXMLFiles=char(baseEntry.GenerateIDLAndXMLFiles);
    data.base.GenerateServices=char(baseEntry.GenerateServices);
    data.AnnotationKey=baseEntry.AnnotationKey;
    data.SetupModel=sprintf('dds.internal.coder.%s.setupModel',data.newPackageName);
    data.ImportXML=sprintf('dds.internal.coder.%s.importXML',data.newPackageName);
    if~isempty(data.base.ImportXMLAndIDL)
        data.ImportXMLAndIDL=sprintf('dds.internal.coder.%s.importXMLAndIDL',data.newPackageName);
    else
        data.ImportXMLAndIDL=[];
    end
    data.VendorPostCompileValidation=data.base.VendorPostCompileValidation;
    data.ExportToXML=sprintf('dds.internal.coder.%s.exportToXML',data.newPackageName);
    data.GenerateIDLAndXMLFiles=sprintf('dds.internal.coder.%s.generateIDLAndXMLFiles',data.newPackageName);
    data.GenerateServices=sprintf('dds.internal.coder.%s.generateServices',data.newPackageName);
    data.GetIsTraditionalCppSafeEnum=char(baseEntry.GetIsTraditionalCppSafeEnum);
    data.GetIsStructUsingAccessFcn=char(baseEntry.GetIsStructUsingAccessFcn);

    data.comment='%';
    getStrAndWriteFile(fullfile(thisDir,'registerVendor.tlc'),registerFilePath,'genRegisterVendor',data);

    infoIdx=find(strcmp(baseEntry.DefaultToolchain,{rtwReg.ToolchainInfos(:).Name}),1);
    data.baseTCFileName=rtwReg.ToolchainInfos(infoIdx).FileName;
    if startsWith(data.baseTCFileName,matlabroot)
        try %#ok<TRYNC> 

            rest=strrep(data.baseTCFileName,[matlabroot,filesep],'');
            splitRest=strsplit(rest,filesep);
            platform=rtwReg.ToolchainInfos(infoIdx).Platform;
            if contains(splitRest{end},rtwReg.ToolchainInfos(infoIdx).Platform)
                endentry=strsplit(splitRest{end},platform);
                filename=sprintf('[''%s'', computer(''arch''), ''%s'']',endentry{1},endentry{2});
            else
                filename=['''',splitRest{end},''''];
            end
            concated=sprintf('''%s'',',splitRest{1:end-1});
            data.baseTCFileName=['fullfile(matlabroot,',concated,filename,')'];
        end
    end
    rtwTargetInfoFilePath=fullfile(data.newBaseDir,'rtwTargetInfo.m');
    getStrAndWriteFile(fullfile(thisDir,'rtwTargetInfo.tlc'),rtwTargetInfoFilePath,'genRTWTargetInfo',data);


    pkgDir=fullfile(data.newBaseDir,'+dds','+internal','+coder',['+',data.newPackageName]);
    [status,emsg,emsgId]=mkdir(fileparts(pkgDir),['+',data.newPackageName]);
    if~status
        error(emsgId,emsg);
    end


    setupModelPath=fullfile(pkgDir,'setupModel.m');
    getStrAndWriteFile(fullfile(thisDir,'setupModel.tlc'),setupModelPath,'genSetupModel',data);


    importXMLPath=fullfile(pkgDir,'importXML.m');
    callBaseData=struct('baseFcn',data.base.ImportXML,'comment',data.comment);
    getStrAndWriteFile(fullfile(thisDir,'importXML.tlc'),importXMLPath,'genCallBase',callBaseData);


    if~isempty(data.ImportXMLAndIDL)
        importXMLAndIDLPath=fullfile(pkgDir,'importXMLAndIDL.m');
        callBaseData=struct('baseFcn',data.base.ImportXMLAndIDL,'comment',data.comment);
        getStrAndWriteFile(fullfile(thisDir,'importXMLAndIDL.tlc'),importXMLAndIDLPath,'genCallBase',callBaseData);
    end


    exportToXMLPath=fullfile(pkgDir,'exportToXML.m');
    callBaseData=struct('baseFcn',data.base.ExportToXML,'comment',data.comment);
    getStrAndWriteFile(fullfile(thisDir,'exportToXML.tlc'),exportToXMLPath,'genCallBase',callBaseData);


    generateIDLAndXMLFilesPath=fullfile(pkgDir,'generateIDLAndXMLFiles.m');
    callBaseData=struct('baseFcn',data.base.GenerateIDLAndXMLFiles,'comment',data.comment);
    getStrAndWriteFile(fullfile(thisDir,'generateIDLAndXMLFiles.tlc'),generateIDLAndXMLFilesPath,'genCallBase',callBaseData);


    generateServicesPath=fullfile(pkgDir,'generateServices.m');
    callBaseData=struct('baseFcn',data.base.GenerateServices,'comment',data.comment);
    getStrAndWriteFile(fullfile(thisDir,'generateServices.tlc'),generateServicesPath,'genCallBase',callBaseData);


    function printInfo(msgId,varargin)
        if verbose
            if nargin>1
                msg=message(msgId,varargin{:});
            else
                msg=message(msgId);
            end
            fprintf(msg.getString);
        end
    end

    function getStrAndWriteFile(tmplFile,filePath,tmplFunction,data)
        str=dds.internal.coder.evalTLCWithParam(tmplFile,tmplFunction,data);
        fp=fopen(filePath,'wt');
        if fp<0
            error(message('MATLAB:save:cantWriteFile',filePath));
        else
            fwrite(fp,str);
            fclose(fp);
        end
    end
end