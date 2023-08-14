function[status,filename]=sldvextend(modelH,blockH,inpopts,showUI)


















    filename='';

    if~(checkWhethertoExtend(modelH,blockH,inpopts))
        status=2;
        return;
    end

    if~(Sldv.HarnessUtils.isSldvGenHarness(modelH)&&(~(isempty(Sldv.harnesssource.Source.getSource(modelH)))))
        errId='Sldv:HarnessUtils:MakeSystemTestHarness:NotCompatibleHarness';
        errString=getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:NotCompatibleHarness'));
        sldvError(errId,errString,true);
    end

    try

        if ishandle(modelH)
            modelName=get_param(modelH,'Name');
        else
            modelName=modelH;
        end
        savedFiles=generateFileNames(modelH,modelName);
        harnessSource=Sldv.harnesssource.Source.getSource(modelH);

        progressBar=Sldv.Utils.ScopedProgressIndicator('Sldv:HarnessUtils:MakeSystemTestHarness:ExtendAndMerge');


        progressBar.updateTitle('Sldv:HarnessUtils:MakeSystemTestHarness:Simulating');

        newlogs=convertInputsToSldvData(modelName,savedFiles);

        testUnitBlock=Sldv.HarnessUtils.extractInlineModel(modelH);




        progressBar.updateTitle('Sldv:HarnessUtils:MakeSystemTestHarness:RunningSLDV');
        if strcmp(get_param(testUnitBlock,'BlockType'),'ModelReference')
            designModelParamPair=(Sldv.HarnessUtils.getModelParamValuePairs(modelH));
            designModel=designModelParamPair.value;
            load_system(designModel);

            opts=prepareSLDVOptions(designModel,savedFiles);
            preExtract.extractH=get_param(designModel,'Handle');
            preExtract.AtomicSubChartWithParam=false;
            testUnitBlock=char(testUnitBlock);
            [analysisStatus,temp_filename]=sldvrun(testUnitBlock,opts,showUI,[],preExtract);
        else
            designModel=testUnitBlock;

            opts=prepareSLDVOptions(modelName,savedFiles);
            designParam=get_param(designModel,'TreatAsAtomicUnit');
            designModel=char(designModel);
            set_param(designModel,'TreatAsAtomicUnit','on');
            [analysisStatus,temp_filename]=sldvrun(designModel,opts,showUI);
            designParam=char(designParam);
            set_param(designModel,'TreatAsAtomicUnit',designParam);
            designSLDVData=load(temp_filename.DataFile);
            if(isfield(designSLDVData.sldvData.ModelInformation,'ExtractedModel'))
                designModel=designSLDVData.sldvData.ModelInformation.ExtractedModel;
            end
        end

        status=analysisStatus;
        progressBar.updateTitle('Sldv:HarnessUtils:MakeSystemTestHarness:MergingHarness');
        if(analysisStatus==1&&exist(temp_filename.DataFile,'file'))
            intermediateSLDVData=temp_filename.DataFile;
            intermediateSLDVDataHandle=load(intermediateSLDVData);
            if(isfield(intermediateSLDVDataHandle.sldvData,'TestCases'))

                sldvData=removeUserTestCases(intermediateSLDVDataHandle.sldvData);
                save(intermediateSLDVData,'sldvData');




                harnessfilename=generateIntermediateHarness...
                (designModel,temp_filename,savedFiles,harnessSource.getSourceType());

                mergeStatus=sldvmergeharness...
                (savedFiles.mergedmodelname,{modelName,harnessfilename});
                m=load_system(savedFiles.mergedmodelname);
                set_param(m,'InitFcn','');
                status=mergeStatus;
                if(mergeStatus==1)
                    filename=analysisStatusAndMergedTestcases...
                    (newlogs,temp_filename,designModel,savedFiles);
                end
            else
                filename=temp_filename;
            end
        end

    catch Mex
        throw(Mex);
    end

end

function savedFiles=generateFileNames(modelH,modelName)
    options=sldvoptions(modelH);



    dirName=strrep(options.OutputDir,'$ModelName$',modelName);
    dirName=strrep(dirName,'\',filesep);
    dirName=strrep(dirName,'/',filesep);
    if(~exist(dirName,'file'))
        mkdir(dirName);
    end


    savedFiles.designmodeldata=Sldv.utils.settingsFilename...
    ('$ModelName$_designdata','on','.mat',modelH,true);
    savedFiles.tempmodelname=Sldv.utils.settingsFilename...
    ('$ModelName$_extended','on','.slx',modelH,true);
    savedFiles.mergedmodelname=Sldv.utils.settingsFilename...
    ('$ModelName$_merged','on','.slx',modelH,true);
    savedFiles.mergedmodeldata=Sldv.utils.settingsFilename...
    ('$ModelName$_mergeddata','on','.mat',modelH,true);
end

function[newlogs]=convertInputsToSldvData(modelName,savedFiles)

    newlogs=sldvlogsignals(modelName);

    save(savedFiles.designmodeldata,'newlogs');
end

function intermediateHarness=generateIntermediateHarness(designModelName,temp_filename,savedFiles,harnessSourceType)


    hopt=sldvharnessopts;
    hopt.harnessFilePath=savedFiles.tempmodelname;


    hopt.harnessSource=harnessSourceType;

    intermediateHarness=sldvmakeharness(designModelName,temp_filename.DataFile,hopt);
end

function filename=analysisStatusAndMergedTestcases(newlogs,temp_filename,...
    designModel,savedFiles)

    mergedModel_sldvData=slvnvmergedata(newlogs,temp_filename.DataFile);
    mergedModel_sldvData=Sldv.DataUtils.addModelInformationFieldToSldvData(mergedModel_sldvData);
    save(savedFiles.mergedmodeldata,'mergedModel_sldvData');
    filename.DataFile=savedFiles.mergedmodeldata;
    filename.HarnessModel=savedFiles.mergedmodelname;
    bdclose(savedFiles.tempmodelname);
    delete(savedFiles.tempmodelname);
    delete(savedFiles.designmodeldata);
    bdclose(designModel);

end

function opts=prepareSLDVOptions(modelName,savedFiles)


    opts=sldvoptions(modelName);
    opts.ExtendExistingTests='on';
    opts.ExistingTestFile=savedFiles.designmodeldata;
end

function continueWithMergeHarness=checkWhethertoExtend(modelH,blockH,inpopts)


    continueWithMergeHarness=slavteng('feature','MergeHarness')...
    &&Sldv.HarnessUtils.isSldvGenHarness(modelH)...
    &&(~(isempty(Sldv.harnesssource.Source.getSource(modelH))))...
    &&(isempty(blockH))&&(strcmp(inpopts.Mode,'TestGeneration'));
end














function sldvDataNew=removeUserTestCases(sldvData)

    oCount=numel(sldvData.Objectives);

    testIdxUseful=zeros(1,oCount);
    for idx=1:oCount
        currStatus=sldvData.Objectives(idx).status;
        isSatByUserData=strcmpi(currStatus,'Satisfied by existing testcase')||...
        strcmpi(currStatus,'Satisfied by coverage data');

        testIdx=sldvData.Objectives(idx).testCaseIdx;
        if~isSatByUserData&&~isempty(testIdx)
            testIdxUseful(idx)=testIdx;
        end
    end

    testIdxAll=arrayfun(@(x)(x.testCaseId),sldvData.TestCases);








    testIdxUseless=setdiff(testIdxAll,testIdxUseful);


    for idx=1:numel(testIdxUseless)
        for jdx=1:numel(sldvData.TestCases)
            if sldvData.TestCases(jdx).testCaseId==testIdxUseless(idx)
                sldvData.TestCases(jdx)=[];
                break;
            end
        end
    end


    sldvDataNew=sldvData;
end
