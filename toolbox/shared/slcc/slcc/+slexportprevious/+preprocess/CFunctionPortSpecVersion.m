function CFunctionPortSpecVersion(obj)


    if isR2021bOrEarlier(obj.ver)
        cFcnBlocks=obj.findBlocksOfType('CFunction');
        for i=1:numel(cFcnBlocks)




            set_param(cFcnBlocks{i},'ExportingToR2021bOrEarlier','on');
        end
    end
