function DSPstat3(obj)






    if isR2007aOrEarlier(obj.ver)
        Minblk=obj.findBlocksWithMaskType('Minimum');
        if~isempty(Minblk)
            for i=1:length(Minblk)
                operateOver=get_param(Minblk{i},'operateOver');
                if strcmp(operateOver,'Specified dimension')
                    dimension=get_param(Minblk{i},'Dimension');
                    if strcmp(dimension,'1')
                        set_param(Minblk{i},'colComp','off');
                        set_param(Minblk{i},'operateOver','Each column');
                    end
                    if strcmp(dimension,'2')
                        set_param(Minblk{i},'operateOver','Each row');
                    end
                end
            end
        end

        Maxblk=obj.findBlocksWithMaskType('Maximum');
        if~isempty(Maxblk)
            for i=1:length(Maxblk)
                operateOver=get_param(Maxblk{i},'operateOver');
                if strcmp(operateOver,'Specified dimension')
                    dimension=get_param(Maxblk{i},'Dimension');
                    if strcmp(dimension,'1')
                        set_param(Maxblk{i},'colComp','off');
                        set_param(Maxblk{i},'operateOver','Each column');
                    end
                    if strcmp(dimension,'2')
                        set_param(Maxblk{i},'operateOver','Each row');
                    end
                end
            end
        end
    end


