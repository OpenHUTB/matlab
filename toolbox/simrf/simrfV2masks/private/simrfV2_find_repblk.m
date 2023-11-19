function RepBlk=simrfV2_find_repblk(block,strToMatch)
    RepBlkFullPath=find_system(block,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'Regexp','on',...
    'Name',strToMatch);

    RepBlkFullPath=setdiff(RepBlkFullPath,block);

    [~,RepBlk]=fileparts(char(RepBlkFullPath));

end