function DSPMtrx3(obj)







    if isR2007aOrEarlier(obj.ver)
        AVMultblk=obj.findBlocksWithMaskType('Array-Vector Multiply');

        if~isempty(AVMultblk)
            for i=1:length(AVMultblk)
                dimension=get_param(AVMultblk{i},'Dimension');
                if strcmp(dimension,'1')
                    mode='Scale Rows (D*A)';
                end

                if strcmp(dimension,'2')
                    mode='Scale Columns (A*D)';
                end

                set_param(AVMultblk{i},'saveAsFlag','1');
                set_param(AVMultblk{i},'mode',mode);
            end
        end
    end
