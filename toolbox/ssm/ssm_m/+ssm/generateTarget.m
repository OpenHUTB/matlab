function generateTarget(varargin)


    fprintf('RUNNING GENERATETARGET\n');


    if ispc
        setenv('MAKEFLAGS','');
    end


    wd=varargin{1};
    fprintf('working dir: %s\n',wd);


    fd=varargin{2};
    fprintf('Final directory will be changed to: %s\n',fd);


    models=varargin(3:end);
    addpath(pwd);


    if~exist(wd,'dir')
        mkdir(wd)
    end

    cd(wd);


    wd=pwd;
    for idx=1:length(models)
        [~,model]=fileparts(models{idx});
        slprjdir=fullfile(wd,model);
        fprintf('----\nGenerating slprj for\nmodel: %s\ndirectory: %s\n',...
        model,slprjdir);


        load_system(model);


        oc=onCleanup(@()bdclose(find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices)));


        set_param(model,'RTWCAPIRootIO','on');
        set_param(model,'LoggingToFile','on');
        set_param(model,'StopTime','inf');


        if exist(slprjdir,'dir')~=7
            mkdir(slprjdir);
        end
        cd(slprjdir);


        sfprivate('sfpurgedir','all');
        try

            ssm.hBuildRapidAcceleratorTarget(model);
        catch ME
            fprintf(['!!! The following error occurred while building %s in\n'...
            ,'accelerator mode.'],model);
            disp(ME.getReport);
            sfprivate('sfpurgedir','all');
        end
        cd(wd);
    end

    cd(fd);
end



