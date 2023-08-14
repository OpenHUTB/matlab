function RowConvenience(obj)





    blockList={'Minimum','Maximum','Mean','Variance',...
    'Standard Deviation','RMS','Median','Normalization'};

    if isR2015aOrEarlier(obj.ver)
        for index1=1:length(blockList)
            blockName=blockList{index1};
            blks=obj.findBlocksWithMaskType(blockName);
            numBlks=length(blks);
            if numBlks>0
                for index2=1:numBlks
                    identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{index2});
                    obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(...
                    identifyBlock,getRowConvenienceParameterName(blockName),'off'));
                end
            end
        end
    end

    function param=getRowConvenienceParameterName(block)
        switch block
        case{'FFT','IFFT'}
            param='RowConvenienceOn';
        case{'Minimum','Maximum'}
            param='colComp';
        case{'Mean','Variance','Standard Deviation','RMS','Median'}
            param='treatSBRowAsCol';
        case 'Normalization'
            param='ColComp';
        end