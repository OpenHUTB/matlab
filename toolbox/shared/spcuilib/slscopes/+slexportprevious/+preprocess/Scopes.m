function Scopes(obj)










    if bdIsLibrary(obj.modelName)


        svscopeblk=find_system(obj.modelName,'AllBlocks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','on','IOType','viewer','BlockType','Scope');
        for i=1:length(svscopeblk)
            delete_block(svscopeblk{i});
        end
    end



    if isR2014aOrEarlier(obj.ver)


        svscopeblk=find_system(obj.modelName,'AllBlocks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','on','IOType','viewer','BlockType','Scope');
        for jndx=1:length(svscopeblk)
            vblk=svscopeblk{jndx};
            sg=get_param(vblk,'ScopeGraphics');
            if~isempty(sg)
                markers=uiservices.pipeToCell(sg.MarkerStyles);
                if~all(strcmp(markers,'none'))
                    identifyingRule=slexportprevious.rulefactory.identifyBlockBySID(vblk);
                    obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(...
                    identifyingRule,'ShowDataMarkers','on'));
                end
            end
        end
    end








    scopeblks=find_system(obj.modelName,'AllBlocks','on','LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IncludeCommented','on','BlockType','Scope');
    for jndx=1:length(scopeblks)
        blk=scopeblks{jndx};
        [~,origBlock]=strtok(blk,'/');
        if strcmpi(get_param([obj.origModelName,origBlock],'Open'),'on')


            sid=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));
            obj.appendRule(['<Block<SID|"',sid,'"><Open|','off',':repval ','on','>>']);
        end
    end

end
