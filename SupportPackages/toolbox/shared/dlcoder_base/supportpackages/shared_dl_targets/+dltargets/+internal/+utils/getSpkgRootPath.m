function spPath=getSpkgRootPath(target)







    if strcmp(target,'armneon')
        target='arm_neon';
    elseif strcmp(target,'armmali')
        target='arm_mali';
    end

    spPath=dlcoder_base.internal.getSpkgRoot(target);

    filesubpath=fullfile('toolbox','shared','dlcoder_base',...
    'supportpackages');


    filesubpath=regexprep(filesubpath,'[(\\|\+)]','\\$0');
    splitres=regexp(spPath,filesubpath,'split');
    assert(~isempty(splitres{1}));
    spPath=splitres{1};

end
