function rtwbindmodel(modelFile,buildDir,target,isTestHarness,testHarnessName,testHarnessOwner)
















    if nargin==0||isempty(modelFile)
        return
    end

    if nargin<3||isempty(target)
        target='rtw';
    end

    if nargin<4
        isTestHarness=false;
        testHarnessName='';
        testHarnessOwner='';
    end



    if isTestHarness
        assert(~isempty(testHarnessName));
        assert(~isempty(testHarnessOwner));
    end



    model=locGetModelName(modelFile);

    if isempty(find_system('type','block_diagram','name',model))
        if exist(modelFile,'file')
            open_system(modelFile);
        else

            open_system(model);
        end
    end


    if isTestHarness
        Simulink.harness.open(testHarnessOwner,testHarnessName);


        modelToBind=testHarnessName;
    else
        modelToBind=model;
    end

    if strcmp(get_param(modelToBind,'GenerateTraceInfo'),'off')
        return
    end

    if~strcmp(target,'rtw')

        return
    end

    h=RTW.TraceInfo.instance(modelToBind);
    if~isa(h,'RTW.TraceInfo')
        h=RTW.TraceInfo(modelToBind);
    end


    if filesep=='\'&&buildDir(1)=='/'
        buildDir=buildDir(2:end);
    end

    [dirname,nu,ext]=fileparts(buildDir);%#ok
    if strcmp(ext,'.html')
        buildDir=fileparts(dirname);
    end

    if~strcmp(h.BuildDir,buildDir)
        try
            h.setBuildDir(buildDir);
        catch me %#ok<NASGU>
        end
    end

    function out=locGetModelName(modelFile)


        sep1=strfind(modelFile,'/');
        sep2=strfind(modelFile,'\');
        if isempty(sep1)&&isempty(sep2)
            idx=1;
        else
            idx=max([sep1,sep2])+1;
        end
        [nu,out]=fileparts(modelFile(idx:end));
