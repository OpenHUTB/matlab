function setup(coveng)







    isTopMdlCovEnabled=cvi.SLCustomCodeCov.isMdlCovEnabled(coveng.topModelH);
    isMdlRefCovEnabled=cvi.SLCustomCodeCov.isMdlRefCovEnabled(coveng.topModelH);

    if(~isTopMdlCovEnabled&&~isMdlRefCovEnabled)||~coveng.slccCov.extractModelRefMap(coveng)


        coveng.slccCov.reset();
        return
    end


    cvi.SFunctionCov.setup(coveng);


    if~SlCov.isSLCustomCodeCovFeatureOn()
        return
    end




    topModelName=get_param(coveng.topModelH,'Name');
    [~,refBlks]=cv.ModelRefData.getMdlReferences(topModelName,true,false);
    refModels={};
    for ii=1:numel(refBlks)
        if(strcmpi(get_param(refBlks{ii},'BlockType'),'ModelReference'))
            refName=get_param(refBlks{ii},'NormalModeModelName');
            if~isempty(refName)
                coveng.slccCov.modelRefNameMap(refName)=get_param(refBlks{ii},'ModelName');
                refModels{end+1}=refName;%#ok<AGROW>
            end
        end
    end
    allModels=unique([topModelName;refModels(:)]);


    for ii=1:numel(allModels)
        cvi.SLCustomCodeCov.setupModel(coveng,get_param(allModels{ii},'Handle'));
    end


    rptTestId=0;
    if~isempty(coveng.lastReportingModelH)
        rptModelcovId=get_param(coveng.lastReportingModelH,'CoverageId');
        rptTestId=cv('get',rptModelcovId,'.activeTest');
    end

    if rptTestId==0
        return
    end


    fName2Info=coveng.slccCov.fileName2Info;
    libInfos=coveng.slccCov.libPath2Info.values();
    for ii=1:numel(libInfos)

        libInfo=libInfos{ii};
        if isempty(libInfo.dbFile)||isempty(libInfo.codeTr)
            continue
        end


        files=libInfo.codeTr.getFilesInResults();
        for jj=1:numel(files)
            file=files(jj);
            if file.kind~=internal.cxxfe.instrum.FileKind.SOURCE
                continue
            end


            fName=file.shortPath;
            [fPath,fName1,fExt]=fileparts(fName);
            fName=[fName1,fExt];
            if~fName2Info.isKey(fName)
                fInfo=containers.Map('KeyType','char','ValueType','any');
                fName2Info(fName)=fInfo;
            else
                fInfo=fName2Info(fName);
            end


            fChk=sprintf('%02X',file.structuralChecksum.toArray());
            if~fInfo.isKey(fChk)


                subInfo=struct(...
                'libName',[],...
                'fullPath',file.path,...
                'libPath',[],...
                'shortPaths',[],...
                'fileIdx',[],...
                'covId',[]...
                );
            else
                subInfo=fInfo(fChk);
            end


            subInfo.libName=[subInfo.libName,{libInfo.name}];
            subInfo.libPath=[subInfo.libPath,{libInfo.libPath}];
            subInfo.shortPaths=[subInfo.shortPaths,{fPath}];
            subInfo.fileIdx=[subInfo.fileIdx,jj];
            fInfo(fChk)=subInfo;%#ok<NASGU>
        end
    end


    cvTest=cvtest(rptTestId);
    settings=cvTest.settings;
    hasDec=settings.decision;
    hasCond=settings.condition;
    hasMcdc=settings.mcdc;
    hasRelationalBoundary=settings.relationalop;


    allmetrics=cvi.MetricRegistry.getDDEnumVals();
    if hasRelationalBoundary
        relOpMetricId=cvi.MetricRegistry.getEnum('cvmetric_Structural_relationalop');
    end


    allFilenames=fName2Info.keys();
    for ii=1:numel(allFilenames)

        fName=allFilenames{ii};
        fInfo=fName2Info(fName);


        allChks=fInfo.keys();
        numChks=numel(allChks);
        allFileInfo=cell(numChks,3);
        for jj=1:numChks
            allFileInfo{jj,1}=allChks{jj};
            subInfo=fInfo(allChks{jj});
            allFileInfo{jj,2}=subInfo;
            allFileInfo{jj,3}=sprintf('%s%s',subInfo.fullPath,fChk);
        end


        [~,idx]=sort(allFileInfo(:,3));
        allFileInfo=allFileInfo(idx,:);
        hasManyChk=numChks>1;

        for jj=1:size(allFileInfo,1)
            fChk=allFileInfo{jj,1};
            subInfo=allFileInfo{jj,2};

            scriptName=fName;
            if hasManyChk
                scriptName=sprintf('%s (%d)',scriptName,jj);
            end


            scriptNameMangled=SlCov.CoverageAPI.mangleModelcovName(scriptName);
            modelcovId=SlCov.CoverageAPI.findModelcovMangled(scriptNameMangled);
            oldRootId=0;
            if isempty(modelcovId)
                modelcovId=SlCov.CoverageAPI.createModelcov(scriptName,0);
                cv('set',modelcovId,'.isScript',1);
            else
                ct=cv('get',modelcovId,'.currentTest');
                if ct~=0
                    oldRootId=cv('get',ct,'.linkNode.parent');
                end
            end
            coveng.addScriptModelcovId(coveng.topModelH,modelcovId);


            testId=cv('get',modelcovId,'.activeTest');
            if testId==0
                testId=cvtest.create(modelcovId);
            end
            newTest=clone(cvTest,cvtest(testId));
            activate(newTest,modelcovId);


            ccPathInfo=coveng.slccCov.libPath2Info(subInfo.libPath{1});
            codeTr=ccPathInfo.codeTr;

            files=codeTr.getFilesInResults();
            file=files(subInfo.fileIdx(1));

            fChkSum=file.structuralChecksum.toArray();
            fChkSum=typecast(fChkSum,'uint32');




            fChkSum=uint32(CGXE.Utils.md5({fChkSum,[hasDec,hasCond,hasMcdc,hasRelationalBoundary]}));

            rootId=cv('new','root',...
            '.topSlHandle',0,...
            '.checksum',double(fChkSum(:)'),...
            '.modelcov',modelcovId);
            cv('set',modelcovId,'.activeRoot',rootId);


            topSlsfId=cv('new',...
            'slsfobj',1,...
            '.origin','SRC_OBJ',...
            '.modelcov',modelcovId,...
            '.handle',0,...
            '.refClass',0);
            cv('SetSlsfName',topSlsfId,scriptName);

            covId=cv('new',...
            'slsfobj',1,...
            '.origin','SRC_OBJ',...
            '.modelcov',modelcovId,...
            '.handle',0,...
            '.refClass',0);
            cv('SetSlsfName',covId,scriptName);

            cv('set',rootId,'.topSlsf',topSlsfId);
            cv('BlockAdoptChildren',topSlsfId,covId);


            codeTr.setSharedFilesAsCurrentModule({file.path},'');


            [numCyclo,numDec,numDecOutcomes,numCond,truthTablesForMCDC,exprsForMCDC,numRelOp,numRelOpOutcomes]=...
            cvi.SLCustomCodeCov.extractCovMetricInfoFromCodeTr(codeTr);


            codeTr.setSharedFilesAsCurrentModule({files.path},'');


            if hasDec&&numDec>0
                cv('defineSFunctionMetric',covId,allmetrics.MTRC_DECISION,numDec,numDecOutcomes);
            end

            if(hasCond||hasMcdc)&&numCond>0
                cv('defineSFunctionMetric',covId,allmetrics.MTRC_CONDITION,numCond);
            end

            if hasMcdc&&~isempty(truthTablesForMCDC)
                cv('defineSFunctionMetric',covId,allmetrics.MTRC_MCDC,truthTablesForMCDC,exprsForMCDC);
            end

            if numCyclo>0
                cv('defineSFunctionMetric',covId,allmetrics.MTRC_CYCLCOMPLEX);
            end

            if hasRelationalBoundary&&numRelOp>0
                cv('defineSFunctionMetric',covId,relOpMetricId,numRelOp,numRelOpOutcomes);
            end



            cv('compareCheckSumForScript',modelcovId,oldRootId);


            rootId=cv('get',modelcovId,'.activeRoot');
            cv('set',rootId,'.filterApplied','');
            cv('set',testId,'.filterApplied','');

            cvi.TopModelCov.setTestObjective(modelcovId,testId);
            cv('allocateModelCoverageData',modelcovId);


            coveng.slccCov.covId2ScriptName(modelcovId)=scriptName;
            subInfo.covId=modelcovId;
            fInfo(fChk)=subInfo;

        end

    end


