function entries = getGotoTagsList(blkH, followLinks)

%   Copyright 2020-2021 The MathWorks, Inc.

% @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
% instead use the post-compile filter activeVariants() - g2599363
gotoBlks = find_system(bdroot(blkH), 'LookUnderMasks', 'on', ...
			 'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,... % look only inside active choice of VSS
                         'FollowLinks', followLinks, 'BlockType', 'Goto');
% Remove Goto blocks with 'local' or 'scoped' tag from different subsystems
gotoBlksWithLocalTags = [];
gotoBlksWithScopedTags = [];
if ~isempty(gotoBlks)
  gotoBlksTags =  get_param(gotoBlks,'TagVisibility');
  idx = strcmp(gotoBlksTags,'local');
  if ~isempty(idx)
      gotoBlksWithLocalTags = gotoBlks(idx);
  end
  idxScopedTags = strcmp(gotoBlksTags,'scoped');
  if ~isempty(idxScopedTags)
      gotoBlksWithScopedTags =  gotoBlks(idxScopedTags);
  end

end

parentBlkHandle = get_param(get_param(blkH,'Parent'),'Handle');
for i = 1:length(gotoBlksWithLocalTags)
  parentGotoBlkWithLocalTag = get_param(get_param(gotoBlksWithLocalTags(i), 'Parent'), 'Handle');
  if ~( parentBlkHandle == parentGotoBlkWithLocalTag)
    % Remove this block from gotoBlks because its tab is local
    % and it's in a different subsystem then blkH
    idx = (gotoBlks(:) == gotoBlksWithLocalTags(i));
    gotoBlks(idx) = [];
  end
end

for i = 1:length(gotoBlksWithScopedTags)
    GotoParentBlock = get_param(gotoBlksWithScopedTags(i), 'Parent');
    tagVisBlockParent = -1;
    % Find the tagVisibility block for the Goto block that has tag marked as "scoped"
    while ~(isempty(GotoParentBlock))
        GotoParentBlockHandle = get_param(GotoParentBlock,'Handle');
        tagVisBlock = find_system(GotoParentBlockHandle,'SearchDepth',1,'LookUnderMasks', 'on',...
                                  'FollowLinks', followLinks, 'BlockType','GotoTagVisibility');

        for k = 1:length(tagVisBlock)
            if strcmp( get_param(tagVisBlock(k),'Gototag'), get_param(gotoBlksWithScopedTags(i),'Gototag'))
                tagVisBlockParent = get_param(get_param(tagVisBlock(k),'Parent'),'Handle');
                break;
            end
        end      
        if tagVisBlockParent ~= -1
            break;
        end
        GotoParentBlock =  get_param(GotoParentBlock, 'Parent');
    end 
    
    FromParentBlk = get_param(blkH,'Parent');
    found = false;
    while ~(isempty(FromParentBlk))
        % walk up the subsystem hierarchy and determine if the "From" block's parent
        % matches the parent of the Goto Tag Visibility block that was found for the GotoBlock
        if (tagVisBlockParent == get_param(FromParentBlk,'Handle'))
            found = true;
            break;
        end                      
        FromParentBlk = get_param(FromParentBlk,'Parent');      
    end      
    % if we did not find a subsystem that contains the Goto block with the "scoped" tag
    % then remove this Goto block from the list of the goto blocks
    if ~(found)      
        idx = (gotoBlks(:) == gotoBlksWithScopedTags(i));
        gotoBlks(idx) = [];
    end 
end


if isempty(gotoBlks)
    entries = {''};
elseif length(gotoBlks) == 1
    entries = {get_param(gotoBlks, 'GotoTag')};
else
    entries = sort(get_param(gotoBlks,'GotoTag'));
end
