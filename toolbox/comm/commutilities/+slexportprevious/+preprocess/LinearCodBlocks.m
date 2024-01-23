function LinearCodBlocks(obj)

    if isR2015aOrEarlier(obj.ver)
        linearCodBlocks=findLinearCodBlocks(obj);

        for i=1:length(linearCodBlocks)
            thisSet=linearCodBlocks{i};

            for j=1:length(thisSet)
                blk=thisSet{j};

                if i==1
                    polyParamName='p';
                elseif i==2
                    polyParamName='k';
                end
                hConvertStringPolysToNum(blk,polyParamName,'ascending');
            end
        end
    end

end


function linearCodBlocks=findLinearCodBlocks(obj)
    linearCodBlocks=find_system(obj.modelName,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IncludeCommented','on','regexp','on',...
    'MaskType','^Binary Cyclic Encoder$|^Binary Cyclic Decoder$|^Hamming Encoder$|^Hamming Decoder$');

end
