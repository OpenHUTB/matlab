




function cvScriptId=scriptInit(scriptId,scriptNum,chartId,instanceHandle)


    try
        cvScriptId=0;

        modelH=get_param(bdroot(sf('Private','chart2block',chartId)),'handle');
        coveng=cvi.TopModelCov.getInstance(modelH);

        if isempty(coveng)
            topModelcovId=cv('find','all','~modelcov.topModelcovId',0);

            for idx=1:numel(topModelcovId)
                coveng=cv('get',topModelcovId(idx),'.topModelCov');
                if~isempty(coveng)
                    modelH=cv('get',topModelcovId(idx),'.handle');
                    break;
                end
            end
        end
        allModelcovIds=coveng.getAllModelcovIds;
        aCallingModelcovId=allModelcovIds(1);
        actTestId=cv('get',aCallingModelcovId,'.activeTest');

        compileForCoverage=(actTestId==0);
        if~compileForCoverage&&~cv('get',actTestId,'.covExternalEMLEnable')
            return;
        end

        chartIdStr=['m',num2str(chartId)];
        scriptPath=sf('get',scriptId,'.filePath');
        scriptPath=fullfile(scriptPath);
        if~isempty(coveng.scriptDataMap)
            scriptDataIdx=find({coveng.scriptDataMap.scriptPath}==string(scriptPath));
            if~isempty(scriptDataIdx)
                cvScriptId=coveng.scriptDataMap(scriptDataIdx).cvScriptId;
                coveng.scriptDataMap(scriptDataIdx).chartIdStrs{end+1}={chartIdStr,instanceHandle,scriptNum};
                return;
            end
        end
        scriptName=cvi.TopModelCov.getScriptNameFromPath(scriptPath);
        scriptNameMangled=SlCov.CoverageAPI.mangleModelcovName(scriptName);
        modelcovId=SlCov.CoverageAPI.findModelcovMangled(scriptNameMangled);
        assert(numel(modelcovId)<2);
        oldRootId=0;
        if isempty(modelcovId)
            modelcovId=SlCov.CoverageAPI.createModelcov(scriptName,0);
            cv('set',modelcovId,'.isScript',1);
        elseif~compileForCoverage

            ct=cv('get',modelcovId,'.currentTest');
            if ct~=0
                oldRootId=cv('get',ct,'.linkNode.parent');
            end
        end

        coveng.addScriptModelcovId(modelH,modelcovId);

        if~compileForCoverage

            newTestId=cvtest.create(modelcovId);
            newTest=clone(cvtest(actTestId),cvtest(newTestId));
            activate(newTest,modelcovId);
        end
        newRootId=cv('new','root',...
        '.topSlHandle',scriptId,...
        '.modelcov',modelcovId);

        cv('set',modelcovId,'.activeRoot',newRootId);

        cvScriptId=cv('new','slsfobj',1,...
        '.origin','SCRIPT_OBJ',...
        '.modelcov',modelcovId,...
        '.handle',scriptId,...
        '.refClass',scriptNum);

        codeBlockId=cv('new','codeblock',1,'.slsfobj',cvScriptId);
        cv('SetScript',codeBlockId,sf('get',scriptId,'.script'));


        cv('CodeBloc','refresh',codeBlockId);
        cv('set',cvScriptId,'.code',codeBlockId);
        cv('SetSlsfName',cvScriptId,scriptName);

        scriptsSubSysObj=cv('new','slsfobj',1,...
        '.origin','SCRIPT_OBJ',...
        '.modelcov',modelcovId,...
        '.handle',scriptId,...
        '.refClass',0);
        cv('SetSlsfName',scriptsSubSysObj,scriptName);
        cv('set',newRootId,'.topSlsf',scriptsSubSysObj);
        cv('BlockAdoptChildren',scriptsSubSysObj,cvScriptId);
        scriptData=cvi.TopModelCov.getScriptDataStruct();
        scriptData.scriptPath=scriptPath;
        scriptData.scriptName=scriptName;
        scriptData.cvScriptId=cvScriptId;
        scriptData.oldRootId=oldRootId;

        scriptData.chartIdStrs{1}={chartIdStr,instanceHandle,scriptNum};
        if isempty(coveng.scriptDataMap)
            coveng.scriptDataMap=scriptData;
        else
            coveng.scriptDataMap(end+1)=scriptData;
        end
    catch MEx
        rethrow(MEx);
    end
end


