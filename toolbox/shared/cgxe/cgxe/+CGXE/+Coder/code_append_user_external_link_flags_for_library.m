function code_append_user_external_link_flags_for_library(objListFile,targetDirName,buildInfo)

    allFlags=buildInfo.getLinkFlags();
    mdlSimFlags=buildInfo.getLinkFlags('CCLinkFlags');
    userFlags=setdiff(allFlags,mdlSimFlags);

    if isempty(userFlags)
        return;
    end

    fileName=fullfile(targetDirName,objListFile);
    file=fopen(fileName,'At');
    if file<3
        construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
    end
    for i=1:numel(userFlags)
        fprintf(file,'%s\n',userFlags{i});
        fclose(file);
    end