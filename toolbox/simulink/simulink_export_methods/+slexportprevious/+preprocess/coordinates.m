function coordinates(obj)



    if isReleaseOrEarlier(obj.ver,'R2018b')

        editor=GLUE2.Util.findAllEditors(obj.origModelName);
        if length(editor)==1
            sbOffsetOld=SLM3I.SLDomain.savedViewPosition(editor);
            sbOffsetNew=MG2.Util.fitPointInShortSceneLimits(sbOffsetOld);
            if~isequal(sbOffsetOld,sbOffsetNew)
                text='<Object<$PropName|BdWindowsInfo><Object<$PropName|WindowsInfo><Object<$PropName|EditorsInfo><Offset|[%.17g, %.17g]:repval [%.17g, %.17g]>>>>';
                rule=sprintf(text,sbOffsetOld(1),sbOffsetOld(2),sbOffsetNew(1),sbOffsetNew(2));
                obj.appendRule(rule);
            end
        else



        end


        blocks=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FindAll','on','Type','Block');
        for j=1:size(blocks,1)
            block=blocks(j);
            oldPos=get_param(block,'Position');
            oldPos(3)=oldPos(3)-oldPos(1);
            oldPos(4)=oldPos(4)-oldPos(2);
            newPos=MG2.Util.fitRectInShortSceneLimits(oldPos);
            if~isequal(oldPos,newPos)

                newPos(3)=newPos(1)+newPos(3);
                newPos(4)=newPos(2)+newPos(4);
                set_param(block,'Position',newPos);
            end
            clear newPos;
            clear oldPos;
        end


        notes=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FindAll','on','Type','Annotation');
        for j=1:size(notes,1)
            note=notes(j);
            oldPos=get_param(note,'Position');
            oldPos(3)=oldPos(3)-oldPos(1);
            oldPos(4)=oldPos(4)-oldPos(2);
            newPos=MG2.Util.fitRectInShortSceneLimits(oldPos);
            if~isequal(oldPos,newPos)

                newPos(3)=newPos(1)+newPos(3);
                newPos(4)=newPos(2)+newPos(4);
                set_param(note,'Position',newPos);
            end
            clear newPos;
            clear oldPos;
        end



        lines=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FindAll','on','Type','Line');

        for j=1:size(lines,1)
            line=lines(j);
            oldPos=get_param(line,'Points');
            for k=1:size(oldPos,1)
                newPos(k,:)=MG2.Util.fitPointInShortSceneLimits(oldPos(k,:));
            end
            if~isequal(oldPos,newPos)

                set_param(line,'Points',newPos);
            end
            clear newPos;
            clear oldPos;
        end

    end

end
