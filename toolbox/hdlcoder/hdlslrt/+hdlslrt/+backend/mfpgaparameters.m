function mfpgaparameters()










    setupname=find_system(gcb,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name','IO3(\d|x){2}\s+Setup');

    matfile=get_param(setupname,'fpga_mat_file');
    if exist(matfile{1},'file')
        load(matfile{1},'turnkeyInfo');

        params=get_param(gcb,'DialogParameters');

        names=fieldnames(params);
        for idx=1:length(names)
            value=get_param(gcb,names{idx});
            turnkeyInfo.xpcparameters.(names{idx})=value;%#ok<STRNU>
        end
        save(matfile{1},'turnkeyInfo');
    end

    return;
end
