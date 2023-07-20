function docBlocks(obj)









    docBlocks=obj.findBlocksWithMaskType('DocBlock');


    for i=1:length(docBlocks)
        blk=docBlocks{i};

        if isR2006bOrEarlier(obj.ver)

            content=docblock('getContent',blk);
            set_param(blk,'UserData',content);

        elseif isR2009bOrEarlier(obj.ver)

            docblock('uncompress_rtf_document',blk);

            rawUserData=get_param(blk,'UserData');
            if isstruct(rawUserData)
                userData=rmfield(rawUserData,'format');
                userData.version=1.1;
            else
                userData=struct(...
                'version',1.1,...
                'content',rawUserData);
            end
            set_param(blk,'UserData',userData);
        end

    end

