


function[data,modelcovId]=init(~,path)

    scriptName=cvi.TopModelCov.getScriptNameFromPath(path);
    modelcovId=SlCov.CoverageAPI.findModelcovMangled(SlCov.CoverageAPI.mangleModelcovName(scriptName));
    if length(modelcovId)>1
        error(message('Slvnv:simcoverage:cvmodel:MoreThanOneId'));
    end
    data=cvi.TopModelCov.getScriptDataStruct();

    if isempty(modelcovId)
        modelcovId=SlCov.CoverageAPI.createModelcov(scriptName,0);
        cv('set',modelcovId,'.isScript',1);
    else
        rootId=cv('RootsIn',modelcovId);
        data.oldRootId=rootId;
    end

    data.scriptPath=path;
    data.scriptName=scriptName;

    scriptNum=0;
    newRootId=cv('new','root',...
    '.topSlHandle',0,...
    '.modelcov',modelcovId);

    cv('set',modelcovId,'.activeRoot',newRootId);

    cvScriptId=cv('new','slsfobj',1,...
    '.origin','SCRIPT_OBJ',...
    '.modelcov',modelcovId,...
    '.handle',0,...
    '.refClass',scriptNum);

    scriptTxt=readFile(path);
    codeBlockId=cv('new','codeblock',1,'.slsfobj',cvScriptId);
    cv('SetScript',codeBlockId,scriptTxt);


    cv('CodeBloc','refresh',codeBlockId);
    cv('set',cvScriptId,'.code',codeBlockId);
    cv('SetSlsfName',cvScriptId,scriptName);

    scriptsSubSysObj=cv('new','slsfobj',1,...
    '.origin','SCRIPT_OBJ',...
    '.modelcov',modelcovId,...
    '.handle',0,...
    '.refClass',0);
    cv('SetSlsfName',scriptsSubSysObj,scriptName);
    cv('set',newRootId,'.topSlsf',scriptsSubSysObj);
    cv('BlockAdoptChildren',scriptsSubSysObj,cvScriptId);
    data.cvScriptId=cvScriptId;

    function scriptTxt=readFile(path)

        scriptTxt='';
        fid=fopen(path);
        if fid==-1
            return;
        end
        code=fread(fid,'*char')';
        fclose(fid);
        scriptTxt=strrep(code,char(13),'');
