function genSLCIBuildInfo(model_name,top_model)











    if exist(model_name)~=4 %#ok
        DAStudio.error('Slci:ui:InvalidModel',model_name);
    end
    if~islogical(top_model)
        DAStudio.error('Slci:slci:TopModelMustBeLogical')
    end

    BuildDirInfo=RTW.getBuildDir(model_name);


    if top_model
        build_info_path=...
        fullfile(BuildDirInfo.CodeGenFolder,...
        BuildDirInfo.RelativeBuildDir);
    else
        build_info_path=...
        fullfile(BuildDirInfo.CodeGenFolder,...
        BuildDirInfo.ModelRefRelativeBuildDir);
    end


    build_info_full_path=...
    fullfile(build_info_path,'buildInfo.mat');

    if(exist(build_info_full_path,'file'))



        msgID='MATLAB:load:classNotFound';
        warnObj=warning('off',msgID);



        buildInfo=coder.make.internal.loadBuildInfo(build_info_full_path);

        warning(warnObj.state,warnObj.identifier);



        build_dirs=buildInfo.getBuildDirList();
        for i=1:numel(build_dirs)
            curr_dir=build_dirs{i};
            curr_files=dir(curr_dir);
            for j=1:numel(curr_files)
                curr_file=curr_files(j);
                code_info_pattern='codeInfo\.mat$';
                if(~isempty(regexp(curr_file.name,code_info_pattern,'ONCE')))
                    addFile(buildInfo,curr_dir,curr_file.name);

                    break;
                end
            end
        end



        if isfield(BuildDirInfo,'SharedUtilsTgtDir')
            shared_util_dir=...
            fullfile(BuildDirInfo.CodeGenFolder,...
            BuildDirInfo.SharedUtilsTgtDir);

            addFile(buildInfo,shared_util_dir,'shared_file.dmr');
            addFile(buildInfo,shared_util_dir,'filemap.mat');
        end




        SLCI_build_info_full_path=fullfile(build_info_path,'SLCIbuildInfo.mat');
        save(SLCI_build_info_full_path,'buildInfo');

    else
        DAStudio.error('Slci:slci:ERRORS_OPENINFO',build_info_full_path);
    end




    function addFile(buildInfo,file_path,file_name)

        full_file_name=fullfile(file_path,file_name);
        if(exist(full_file_name,'file'))
            buildInfo.addNonBuildFiles(full_file_name);
        end


