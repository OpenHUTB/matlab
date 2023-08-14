function DSPmathops(obj)









    if isR2006bOrEarlier(obj.ver)
        Diffblk=obj.findBlocksWithMaskType('Difference',...
        'BlockType','S_Function');

        if~isempty(Diffblk)
            for i=1:length(Diffblk)
                diffAlong=get_param(Diffblk{i},'dim');
                if(strcmp(diffAlong,'Specified dimension'))
                    dimension=get_param(Diffblk{i},'Dimension');
                    if strcmp(dimension,'1')
                        dim='Columns';
                    end
                    if strcmp(dimension,'2')
                        dim='Rows';
                    end
                    set_param(Diffblk{i},'dim',dim);
                end
            end
        end
    end
