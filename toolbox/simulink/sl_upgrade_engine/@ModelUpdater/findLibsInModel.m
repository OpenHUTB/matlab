function libs=findLibsInModel(mdlName)






    libLinks=find_system(mdlName,...
    'FollowLinks','on',...
    'LookInsideSubsystemReference','off',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LinkStatus','resolved');

    srcBlocks=get_param(libLinks,'ReferenceBlock');
    libs=cell(size(srcBlocks));
    for i=1:length(srcBlocks)
        srcBlock=srcBlocks{i};
        slashIdx=findstr(srcBlock,'/');
        libs{i}=srcBlock(1:(slashIdx(1)-1));
    end

    [ignoreText,libInfo]=sldiagnostics(mdlName,'libs');%#ok
    if isempty(libInfo)
        libs=[];
    else
        libs=[libInfo(:).libName];
    end







    nLibs=length(libs);

    if nLibs>0

        toolboxBaseDir=fullfile(matlabroot,'toolbox');
        lenBaseStr=length(toolboxBaseDir);

        idxKeep=repmat(true,nLibs,1);

        for iLib=1:nLibs

            curLib=libs{iLib};

            if strncmp(curLib,'simulink',8)||...
                strncmp(which(curLib),toolboxBaseDir,lenBaseStr)

                idxKeep(iLib)=false;
            end
        end

        libs=libs(idxKeep);
    end

end
