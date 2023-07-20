function[status,results]=import(sldvData,options)








    results.TestHarness='';
    results.TestFile='';
    status=false;
    if~slfeature('ExportTestcasesInSLTest')||~Simulink.harness.internal.isInstalled()||~Simulink.harness.internal.licenseTest()
        error(message('Simulink:Harness:LicenseError'));
    end



    model=sldvData.ModelInformation.Name;
    modelH=get_param(model,'Handle');


    fileName=get_param(model,'FileName');
    [~,~,ext]=fileparts(fileName);
    if~strcmpi(ext,'.slx')

        error(message('Simulink:Harness:LicenseError'));
    end


    options.harnessOnly=true;
    options.hanessName='';
    options.harnessSource='';
    options.testFileName='';

    try
        opts=sldvData.AnalysisInformation.Options;

        conflictMode=opts.MakeOutputFilesUnique;
        fullPath=Sldv.utils.settingsFilename(opts.SlTestFileName,...
        conflictMode,'.mldatx',modelH,false,true,opts);

        if strcmp(conflictMode,'off')
            id=1;
            [path,name,ext]=fileparts(fullPath);
            while id>=1
                if~stm.internal.isTestFileOpen(fullPath)
                    break;
                end
                fullPath=fullfile(path,[name,num2str(id),ext]);
                id=id+1;
            end
        end
        TestFileName=fullPath;

        if isfield(sldvData.ModelInformation,'SubsystemPath')
            owner=sldvData.ModelInformation.SubsystemPath;
        else
            owner=sldvData.ModelInformation.Name;
        end
        src=opts.SlTestHarnessSource;
        TestHarnessName=getHarnessName(model,opts);

        sldvshareprivate('create_sltest_harness_using_sldvdata',sldvData,model,owner,TestHarnessName,src);
        Simulink.harness.open(owner,TestHarnessName);

        results.TestHarness=TestHarnessName;

        stm.internal.createTestsFromModel(TestHarnessName,TestFileName);
        sltest.testmanager.view;
        sltest.testmanager.load(TestFileName);

        results.TestHarness=TestHarnessName;
        results.TestFile=TestFileName;
        status=true;
    catch ME
        ME.throwAsCaller;
    end

end

function harnessName=getHarnessName(model,opts)
    hList=Simulink.harness.internal.getHarnessList(model,'all');
    n=length(hList);
    existingHarnessNames=cell(1,n);
    for i=1:n
        hList(i).inMem=Simulink.harness.internal.isInMemory(get_param(hList(i).model,'Handle'),...
        hList(i).name,hList(i).ownerHandle);
        existingHarnessNames{i}=hList(i).name;
    end

    tmpName=opts.SlTestHarnessName;
    tmpName=strrep(tmpName,'$ModelName$',model);
    candName=tmpName;
    uniqueFlag=strcmp(opts.MakeOutputFilesUnique,'on');
    id=1;
    while true
        [~,ind]=ismember(candName,existingHarnessNames);
        if ind==0
            harnessName=candName;
            return;
        else
            if uniqueFlag==false&&hList(ind).inMem==0

                Simulink.harness.delete(hList(ind).ownerHandle,hList(ind).name);
                harnessName=candName;
                return;
            end
        end
        candName=[tmpName,num2str(id)];
        id=id+1;
    end
end


