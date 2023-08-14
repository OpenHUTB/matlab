function ReplaceLatchWithRef(block,h)




    ports=get_param(block,'ports');
    inportNames=get_param(find_system(block,'MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'BlockType','Inport'),'name');
    libBlock='';

    if(ports(1)==2)&&(length(inportNames)==2)
        if strcmp(inportNames{1},'D')&&strcmp(inportNames{2},'C'),

            libBlock='simulink_extras/Flip Flops/D Latch';
        elseif strcmp(inportNames{1},'S')&&strcmp(inportNames{2},'R'),

            libBlock=sprintf('simulink_extras/Flip Flops/S-R\nFlip-Flop');
        end
    elseif(ports(1)==3)&&(length(inportNames)==3)
        if strcmp(inportNames{1},'D')&&strcmp(inportNames{2},'CLK')&&strcmp(inportNames{3},'!CLR'),

            libBlock='simulink_extras/Flip Flops/D Flip-Flop';
        elseif strcmp(inportNames{1},'J')&&strcmp(inportNames{2},'CLK')&&strcmp(inportNames{3},'K'),

            libBlock=sprintf('simulink_extras/Flip Flops/J-K\nFlip-Flop');
        end
    end





    if~isempty(libBlock),


        if askToReplace(h,block)
            funcSet=uBlock2Link(h,block,libBlock);
            appendTransaction(h,block,h.ConvertToLinkReasonStr,{funcSet});
        end

    end

end
