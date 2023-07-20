function[ownerPath,testHarnessName,testFileName,testCaseObj]=importDVData(sldvDataFilePath,varargin)




    import stm.internal.SlicerDebuggingStatus;
    if~slfeature('ExportTestcasesInSLTest')||~Simulink.harness.internal.isInstalled()||~Simulink.harness.internal.licenseTest()
        error(message('Simulink:Harness:LicenseNotAvailable'));
    end


    if stm.internal.slicerDebugStatus~=SlicerDebuggingStatus.DebugInactive
        error(message('stm:general:OperationProhibitedWhileDebugging','sltest.import.sldvData'));
    end

    s=load(sldvDataFilePath);
    sldvData=sltest.internal.convertSldvData(s);

    if isfield(sldvData.ModelInformation,'HarnessOwnerModel')
        model=sldvData.ModelInformation.HarnessOwnerModel;
    elseif Sldv.DataUtils.isBDExtractedModel(sldvData)



        assert(~isfield(sldvData.ModelInformation,'SubsystemPath'),...
        'Block diagram extraction should be true only during top-model analysis');
        model=get_param(sldvprivate('getExtractedMdl',sldvData,sldvData.ModelInformation.Name),'name');
    else
        model=sldvData.ModelInformation.Name;
    end

    modelH=get_param(model,'Handle');

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
        testFileName=fullPath;

        if isfield(sldvData.ModelInformation,'ExtractedModel')
            if~isfield(sldvData.ModelInformation,'HarnessOwnerModel')
                if isfield(sldvData.ModelInformation,'SubsystemPath')
                    ownerPath=sldvData.ModelInformation.SubsystemPath;
                else
                    if Sldv.DataUtils.isBDExtractedModel(sldvData)
                        ownerPath=model;
                    else
                        ownerPath=sldvData.ModelInformation.Name;
                    end
                end
            else
                harness=sldvData.ModelInformation.Name;
                hInfo=Simulink.harness.internal.find(model,'Name',harness);
                ownerPath=hInfo.ownerFullPath;
            end
        else
            if isfield(sldvData.ModelInformation,'SubsystemPath')
                ownerPath=sldvData.ModelInformation.SubsystemPath;
            elseif~isfield(sldvData.ModelInformation,'HarnessOwnerModel')
                ownerPath=sldvData.ModelInformation.Name;
            else
                harness=sldvData.ModelInformation.Name;
                hInfo=Simulink.harness.internal.find(model,'Name',harness);
                ownerPath=hInfo.ownerFullPath;
            end
        end

        [testHarnessName,harnessToDelete]=Simulink.harness.internal.getSLDVHarnessName(model,ownerPath,opts);




        if~isfield(sldvData.ModelInformation,'SubsystemPath')&&...
            isfield(sldvData.ModelInformation,'HarnessOwnerModel')
            param.CreateHarness=false;
            param.TestHarnessName=sldvData.ModelInformation.Name;
        else
            param.CreateHarness=true;
            param.TestHarnessName=testHarnessName;
        end

        param.TestFileName=testFileName;

        if isfield(sldvData.ModelInformation,'ExtractedModel')
            param.ExtractedModelPath=sldvData.ModelInformation.ExtractedModel;
        else
            param.ExtractedModelPath='';
        end

        param.ExcelFilePath='';
        param.TestHarnessSource=opts.SlTestHarnessSource;
        param.TestCase=[];

        if nargin>1

            p=inputParser;
            p.CaseSensitive=0;
            p.KeepUnmatched=0;
            p.PartialMatching=0;

            p.addParameter('CreateHarness',param.CreateHarness,@islogical);
            p.addParameter('TestHarnessName',param.TestHarnessName,@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('TestFileName',param.TestFileName,@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('ExtractedModelPath',param.ExtractedModelPath,@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('ExcelFilePath',param.ExcelFilePath,@(x)validateattributes(x,{'char'},{}));

            harnessSources={'Inport','Signal Builder','Signal Editor'};
            p.addParameter('TestHarnessSource',param.TestHarnessSource,@(x)any(validatestring(x,harnessSources)));
            p.addParameter('TestCase',param.TestCase,@(x)validateattributes(x,{'sltest.testmanager.TestCase'},{'nonempty','scalar'}));
            p.parse(varargin{:});

            param.CreateHarness=p.Results.CreateHarness;
            param.TestHarnessName=p.Results.TestHarnessName;
            param.TestFileName=p.Results.TestFileName;
            param.ExtractedModelPath=p.Results.ExtractedModelPath;
            param.excelFilePath=p.Results.ExcelFilePath;

            param.TestHarnessSource=p.Results.TestHarnessSource;
            param.TestCase=p.Results.TestCase;
        end

        if~isempty(param.TestCase)

            if~isequal(p.UsingDefaults,{'CreateHarness','TestHarnessName','TestFileName','ExtractedModelPath',...
                'ExcelFilePath','TestHarnessSource'})
                error(message('Simulink:Harness:ImportSLDVData_InvalidParams'));
            end
            param.TestFileName=param.TestCase.TestFile.FilePath;
        end


        dir=fileparts(param.TestFileName);
        [~,attrib]=fileattrib(dir);
        if~attrib.UserWrite
            error(message('Simulink:Harness:ImportSLDVData_ReadOnlyDir'));
        end
        if exist(param.TestFileName,'file')
            [~,attrib]=fileattrib(param.TestFileName);
            if attrib.UserWrite~=1
                error(message('Simulink:Harness:ImportSLDVData_ReadOnlyFile'));
            end
        end


        if~isempty(param.TestCase)


            if any(cell2mat(param.TestCase.RunOnTarget))
                error(message('Simulink:Harness:ImportSLDVData_TCInvalidTestCaseType'));
            end

            mdlName=param.TestCase.getProperty('Model');
            if~strcmp(model,mdlName)
                error(message('Simulink:Harness:ImportSLDVData_TCInvalidModel',model));
            end

            hName=param.TestCase.getProperty('HarnessName');
            if isempty(hName)
                error(message('Simulink:Harness:ImportSLDVData_TCInvalidHarness'));
            end
            hList=Simulink.harness.internal.find(ownerPath,'Name',hName);
            if isempty(hList)||(~strcmp(hList.origSrc,'Inport')&&~strcmp(hList.origSrc,'Signal Builder'))
                error(message('Simulink:Harness:ImportSLDVData_TCInvalidHarness'));
            end

            param.CreateHarness=false;
            param.TestHarnessSource=hList.origSrc;
            param.TestHarnessName=hName;
        end


        if~isfield(sldvData.ModelInformation,'SubsystemPath')&&...
            isfield(sldvData.ModelInformation,'HarnessOwnerModel')
            if param.CreateHarness==true


                error(message('Simulink:Harness:SLDVImport_CannotCreateTestHarness',sldvData.ModelInformation.Name));
            end

            if~strcmp(param.TestHarnessName,sldvData.ModelInformation.Name)


                error(message('Simulink:Harness:SLDVImport_CannotUseOtherTestHarness',param.TestHarnessName,sldvData.ModelInformation.Name));
            end
        end





        sldvDataInfo.FilePath=sldvDataFilePath;
        sldvDataInfo.Data=sldvData;

        param.Model=model;
        param.harnessToDelete=harnessToDelete;
        param.ownerPath=ownerPath;
        [testHarnessName,testFileName,testCaseObj]=stm.internal.sldv.importSLDVDataMain(sldvDataInfo,param);

    catch ME
        ME.throwAsCaller;
    end
end


