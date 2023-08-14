


function cleanout_slprj_for_deployment(path,mdl)



    if~isempty(getenv('RAPID_ACCELERATOR_OPTIONS_DEBUG'))||...
        ~isempty(getenv('RAPID_ACCELERATOR_OPTIONS_KEEP_ARTIFACTS'))
        return
    end

    assert(Simulink.isRaccelDeploymentBuild);

    folders=Simulink.filegen.internal.FolderConfiguration(mdl,true,false);
    rootDir=folders.RapidAccelerator.absolutePath('ModelCode');

    exemption_list={mdl,...
    [mdl,'.exe'],...
    'build_rtp.mat',...
    'rs_raccel.mat',...
    'ext_input_settings.mat',...
    'build_ext_inputs.mat',...
    'build_initial_state.mat',...
    'standaloneModelInterface.mat',...
    'standaloneModelLoggingInfo.mat',...
    fullfile(rootDir,[mdl,'_sfcn_info.mat']),...
    [mdl,'_get_checksum.mat'],...
    [mdl,'_mask_tree.xml']...
    ,'model_workspace.mat'...
    ,[mdl,'_enums.mat']...
    ,'buildInfo.mat'...
    ,'template_dataset.mat',...
    [mdl,'_variable_registry.xml']...
    };

    exempted_extensions={['.',mexext]};

    clean_out_directory_with_exemptions(rootDir,exemption_list,exempted_extensions);

    tmwInternalDir=fullfile(path,'slprj','raccel_deploy',...
    mdl,'tmwinternal');

    if(exist(tmwInternalDir,'dir'))
        hostBasedCAPILibraryName=...
        [mdl,'_capi_host.',mexext];
        binfoFile='binfo.mat';
        tmwInternalExemptions=...
        {hostBasedCAPILibraryName,binfoFile};
        tmwInternalExemptedExtensions={};
        clean_out_directory_with_exemptions(...
        tmwInternalDir,...
        tmwInternalExemptions,...
tmwInternalExemptedExtensions...
        );
    end
    if(exist(fullfile(path,'slprj','raccel_deploy',...
        mdl,'referenced_model_includes'),'dir'))
        rmdir(fullfile(path,'slprj','raccel_deploy',...
        mdl,'referenced_model_includes'),'s');
    end
    if(exist(fullfile(path,'slprj','sl_proj.tmw'),'file'))
        delete(fullfile(path,'slprj','sl_proj.tmw'));
    end
    if(exist(fullfile(path,'slprj','_sfprj'),'dir'))
        rmdir(fullfile(path,'slprj','_sfprj'),'s');
    end
    if(exist(fullfile(path,'slprj','raccel_deploy','_sharedutils'),'dir'))
        rmdir(fullfile(path,'slprj','raccel_deploy','_sharedutils'),'s');
    end
    if(exist(fullfile(path,'slprj','sim'),'dir'))
        rmdir(fullfile(path,'slprj','sim'),'s');
    end
end


function clean_out_directory_with_exemptions(directory,exemptions,exemptedExtensions)
    allfiles=dir(directory);
    checkExtensions=~isempty(exemptedExtensions);
    for i=1:length(allfiles)
        filename=allfiles(i).name;
        if(~any(contains(lower(exemptions),lower(filename)))&&~allfiles(i).isdir)
            if checkExtensions
                [~,~,extension]=fileparts(filename);
                if any(strcmpi(exemptedExtensions,extension))
                    continue;
                end
            end
            delete(fullfile(directory,filename));
        end
    end
end
