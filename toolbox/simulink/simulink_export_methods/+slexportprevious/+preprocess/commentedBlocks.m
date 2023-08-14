function commentedBlocks(obj)



    if~isR2013aOrEarlier(obj.ver)

        return;
    end


    opts=Simulink.FindOptions('IncludeCommented',true,'RegExp',true);
    if isR2012aOrEarlier(obj.ver)

        commented_blocks=Simulink.findBlocks(obj.modelName,'Commented','^(through|on)$',opts);
        if isempty(commented_blocks)
            return;
        end


        obj.reportWarning('Simulink:ExportPrevious:CommentedBlocksFound',obj.ver.release);






    else


        commented_blocks=Simulink.findBlocks(obj.modelName,'Commented','through',opts);
        if isempty(commented_blocks)
            return;
        end


        obj.reportWarning('Simulink:ExportPrevious:CommentedThroughBlocksFound',obj.ver.release);
        for i=1:numel(commented_blocks)
            set_param(commented_blocks(i),'Commented','on');
        end
    end
end

