function generateCode_implementation(KS)


















    mdlName=KS.ModelName.char;


    cgDirName=[mdlName,'_codegen_kinematics'];
    cgFullPath=fullfile(pwd,cgDirName,filesep);
    if~exist(cgFullPath,'dir')
        [dirCreated,msg,msgId]=mkdir(cgFullPath);
        if~dirCreated
            throw(MException(msgId,msg));
        end
    end


    KS.mSystem.generateCode(KS.ModelName,matlabroot,cgFullPath,...
    "DummyCoding",KS.MaxIterations,psp3Fcn());


    cgMFcnName=[mdlName,'_solveKinematics'];
    cgMFileName=[cgMFcnName,'.m'];
    fid=fopen(cgMFileName,'w+');

    nTgtVars=height(KS.targetVariables);
    nIGVars=height(KS.initialGuessVariables);
    nOutVars=height(KS.outputVariables);

    customSources={...
    [mdlName,'_asm_delegate.c'],...
    [mdlName,'_asserts.c'],...
    [mdlName,'_setParameters.c'],...
    [mdlName,'_compOutputs.c'],...
    [mdlName,'_checkTargets.c'],...
    [mdlName,'_geometries.c'],...
    [mdlName,'_kinematics.c']};

    customIncludes={
    [mdlName,'_kinematics.h'],...
    [mdlName,'_geometries.h']};

    tgtInp='expTargetVals';
    igInp='initGuessVals';
    outOut='outputVals';
    flagOut='status';
    tgtSOut='targetSuccess';
    tgtVOut='actTargetVals';


    fcnSig=sprintf('function [%s, %s, %s, %s] = %s(',outOut,...
    flagOut,tgtSOut,tgtVOut,cgMFcnName);

    inpSep='';
    if nTgtVars>0
        fcnSig=sprintf([fcnSig,'%s'],tgtInp);
        inpSep=', ';
    end

    if nIGVars>0
        fcnSig=sprintf([fcnSig,inpSep,'%s)'],igInp);
    else
        fcnSig=sprintf([fcnSig,')']);
    end
    fprintf(fid,'%s\n',fcnSig);


    fprintf(fid,'%%%s Stand-alone solve function for KinematicsSolver model %s\n',upper(cgMFcnName),mdlName);
    fprintf(fid,'%% This function is for code generation purposes only and will not work when\n');
    fprintf(fid,'%% called directly from MATLAB.  You can generate code for this function (or\n');
    fprintf(fid,'%% a function that calls it) using the CODEGEN function.\n');
    fprintf(fid,'%% \n');
    fprintf(fid,'%% ex: codegen -config:mex %s\n',cgMFcnName);
    fprintf(fid,'%% \n');
    fprintf(fid,'%% %s\n\n',pm_message('sm:mli:kinematicsSolver:UnsupportedCodegenConfig'));
    fprintf(fid,'%% Copyright 2021 The MathWorks, Inc.\n\n');


    if nTgtVars>0
        fprintf(fid,'\n%% Validate target: [1 x %d] or [%d x 1] vector\n',nTgtVars,nTgtVars);
        fprintf(fid,'assert(isa(%s,''double''));\n',tgtInp);
        fprintf(fid,'assert(all(size(%s) <= [%d %d]));\n',tgtInp,nTgtVars,nTgtVars);
        fprintf(fid,'assert(numel(%s) == %d);\n',tgtInp,nTgtVars);
        fprintf(fid,'assert(isvector(%s));\n',tgtInp);
    else
        fprintf(fid,'\n%% Initialize target\n');
        fprintf(fid,'%s = zeros(%d,1,''double'');\n\n',tgtInp,nTgtVars);
    end


    if nIGVars>0
        fprintf(fid,'\n%% Validate initial guess: [1 x %d] or [%d x 1] vector\n',nIGVars,nIGVars);
        fprintf(fid,'assert(isa(%s,''double''));\n',igInp);
        fprintf(fid,'assert(all(size(%s) <= [%d %d]));\n',igInp,nIGVars,nIGVars);
        fprintf(fid,'assert(numel(%s) == %d);\n',igInp,nIGVars);
        fprintf(fid,'assert(isvector(%s));\n\n',igInp);
    else
        fprintf(fid,'\n%% Initialize initial guess\n');
        fprintf(fid,'%s = zeros(%d,1,''double'');\n',igInp,nIGVars);
    end


    fprintf(fid,'\n%% Initialize outputs\n');
    fprintf(fid,'%s = zeros(%d,1,''double'');\n',outOut,nOutVars);
    fprintf(fid,'%s = 0.0; %%#ok<NASGU>\n',flagOut);
    fprintf(fid,'%s = zeros(%d,1,''logical'');\n',tgtSOut,nTgtVars);
    fprintf(fid,'%s = zeros(%d,1,''double'');\n',tgtVOut,nTgtVars);


    fprintf(fid,'\n%% Custom Source Files\n');
    fprintf(fid,'coder.updateBuildInfo(''addSourcePaths'',''%s'');\n',fullfile(pwd,cgDirName));
    for i=1:length(customSources)
        fprintf(fid,'coder.updateBuildInfo(''addSourceFiles'',''%s'');\n',customSources{i});
    end


    fprintf(fid,'\n%% Custom Includes\n');
    fprintf(fid,'coder.updateBuildInfo(''addIncludePaths'',''%s'');\n',fullfile(pwd,cgDirName));
    for i=1:length(customIncludes)
        fprintf(fid,'coder.cinclude(''%s'');\n\n',customIncludes{i});
    end


    outStr=sprintf('[%s, %s, %s, %s] = ...\\n',outOut,flagOut,tgtSOut,tgtVOut);
    fcnStr='  simscape.multibody.internal.KinematicsSolverCodeGenAPI.solveKinematics( ...\n';
    inp1Str='    ''%s'', ...\n';
    inp2Str='     %s, %s, %s, %s, %s);\n';
    fprintf(fid,[outStr,fcnStr,inp1Str,inp2Str],...
    mdlName,...
    tgtInp,igInp,outOut,tgtSOut,tgtVOut);
    fclose(fid);


