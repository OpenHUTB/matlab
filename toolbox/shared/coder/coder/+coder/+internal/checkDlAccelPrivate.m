function[result,errorList,report]=checkDlAccelPrivate()

    result.gpu=false;
    result.deepcodegen=false;
    result.deepcodeexec=false;

    dltarget='cudnn';
    [result.gpu,errorMsg,cc]=coder.internal.validateGpuDevice();

    if isempty(errorMsg)
        errorList={};
    else
        errorList={errorMsg};
    end


    [result.deepcodegen,report,tempFolder,errorList]=checkDeepCodegen(errorList,dltarget,cc);


    if result.deepcodegen&&result.gpu
        [result.deepcodeexec,errorList]=checkDeepCodeexec(errorList,tempFolder);
    end


    if result.deepcodegen&&result.deepcodeexec
        report='';
        [~,~]=rmdir(tempFolder);
    end

end

function[status,errorList]=checkCppCompilerForMex(errorList)


    [status,msgString]=coder.internal.checkCppCompilerForDLAccel();

    if~status
        errorList{end+1}=msgString;
    end

end

function[status,report,tempFolder,errorList]=checkDeepCodegen(errorList,dltarget,cc)

    report='';
    tempFolder='';
    [status,errorList]=checkCppCompilerForMex(errorList);
    if~status
        return;
    end

    minComputeCap=coder.GpuCodeConfig.DefaultComputeCapability;

    cfg=coder.config('mex');
    cfg.TargetLang='C++';
    cfg.GenerateReport=true;
    if(strcmpi(dltarget,'cudnn'))
        cfg.CppPreserveClasses=false;
        cfg.GpuConfig=coder.GpuCodeConfig;
        cfg.GpuConfig.Enabled=1;
        if~isempty(cc)
            try
                cfg.GpuConfig.ComputeCapability=cc;
            catch e %#ok<NASGU>
                cfg.GpuConfig.ComputeCapability=minComputeCap;
            end
        end
    end
    cfg.DeepLearningConfig=coder.DeepLearningConfig('TargetLibrary',dltarget,'DeepLearningAcceleration',true);
    cfg.GpuConfig.UseShippingLibs=true;

    tempFolder=tempname;
    mkdir(tempFolder);
    oldDir=cd(tempFolder);
    changeBack=onCleanup(@()cd(oldDir));
    reportLocation=fullfile(tempFolder,'dlaccel','mex','dlEntryPointTest','html','report.mldatx');

    xIn=ones(28,28,'uint8');
    ntwkfile='mnist.mat';
    magicKey='tp835d9653_bestej_4437_dlaccelbfd0_dc3f1d27bb78';
    codegenArgs={'-args',{xIn,coder.Constant(ntwkfile)},'-config',cfg,...
    '--preserve','dlEntryPointTest.m',magicKey};%#ok<NASGU>


    try
        filePath=fullfile(matlabroot,'toolbox','shared','coder','coder',...
        '+coder','+internal');
        fileNames={'dlEntryPointTest.m','mnist.mat','three_28x28.pgm'};
        for idx=1:numel(fileNames)
            fullFileName=fullfile(filePath,fileNames{idx});
            copyfile(fullFileName,'./');
        end
        evalc('report = dlcoder_base.internal.generateDlAccelPlugin(codegenArgs{:})');
    catch e
        msgString=string(message('gpucoder:system:codegen_failed_report',e.identifier,reportLocation));
        status=false;
    end

    if~isempty(report)
        status=status&&report.summary.passed;%#ok<BDSCI,BDLGI>
        report=report.summary;
        if~status
            msgString=string(message('gpucoder:system:codegen_failed_report_noerrorid',reportLocation));
        end
    end

    if~status
        errorList{end+1}=msgString;
    end

end

function[status,errorList]=checkDeepCodeexec(errorList,cgDir)

    status=true;

    oldDir=cd(cgDir);
    changeBack=onCleanup(@()cd(oldDir));

    ntwkfile='mnist.mat';
    in=imread('three_28x28.pgm');

    try
        pf=executeDeep(in,ntwkfile);
        if(any(pf))
            msgString=string(message('gpucoder:system:code_execution_failed'));
            status=false;
        end
    catch e
        msgString=string(message('gpucoder:system:code_execution_error',e.message));
        status=false;
    end

    if(~status)
        errorList{end+1}=msgString;
    end

end


function pf=executeDeep(in,ntwkfile)
    sim_out=dlEntryPointTest(in,ntwkfile);
    codegen_out=dlEntryPointTest_mex(in,ntwkfile);
    diff=abs(sim_out-codegen_out);
    pf=(diff>1e-5);
end


function opt=convertToCustomCompute(cc)
    cc=strrep(cc,'.','');
    opt=['-arch sm_',cc];
end
