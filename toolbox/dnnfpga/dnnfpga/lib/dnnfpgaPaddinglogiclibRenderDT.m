function dnnfpgaPaddinglogiclibRenderDT(gcb,dataType)




    if isempty(dataType)
        return;
    end

    try


        lines=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FindAll','on','type','line');
        delete_line(lines);


        blocks=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
        inID=0;
        outID=0;
        for i=1:length(blocks)
            if strcmp(get_param(blocks{i},'BlockType'),'Inport')
                inID=i;
                continue;
            end
            if strcmp(get_param(blocks{i},'BlockType'),'Outport')
                outID=i;
                continue;
            end
            if strcmp(get_param(blocks{i},'BlockType'),'SubSystem')&&...
                strcmp(get_param(blocks{i},'Name'),get_param(gcb,'Name'))
                continue;
            end
            delete_block(blocks{i});
        end

        if strcmp(dataType,'single')
            curBlockName=[gcb,'/Float_Typecast0'];
            add_block('hdlsllib/HDL Floating Point Operations/Float Typecast',curBlockName,'Position',[80,40,180,60]);
            add_line(gcb,sprintf('%s/1',get_param(blocks{inID},'Name')),'Float_Typecast0/1','autorouting','on');
            add_line(gcb,'Float_Typecast0/1',sprintf('%s/1',get_param(blocks{outID},'Name')),'autorouting','on');
            return;
        end

        add_line(gcb,sprintf('%s/1',get_param(blocks{inID},'Name')),sprintf('%s/1',get_param(blocks{outID},'Name')));

    catch me
        disp(me.message);
    end

end
