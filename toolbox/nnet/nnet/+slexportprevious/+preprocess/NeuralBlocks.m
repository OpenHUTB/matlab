function NeuralBlocks(obj)




    ver=obj.ver;
    if ver.isR2009aOrEarlier






















        blocks=find_system(obj.modelName,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','Regexp','on','MaskDisplay','^e = 0\.06;','MaskType',[]);
        for i=1:numel(blocks)
            blk=blocks{i};
            set_param(blk,'MaskDisplay','');
            set_param(blk,'MaskIconFrame','on');
        end

    end
end
