function CompressRTFDocBlock(block,h)




    [~,format]=docblock('getContent',block);

    if strcmp(format,'RTF')
        if askToReplace(h,block)
            funcSet=uCompressRTFDocBlock(h,block);
            appendTransaction(h,...
            block,...
            'The following RTF DocBlock can be updated to produce a smaller MDL file size.',...
            funcSet);
        end
    end

    function funcSet=uCompressRTFDocBlock(h,block)
        funcSet={@docblock,'compress_rtf_documents',block};
        if doUpdate(h)
            docblock('compress_rtf_documents',block);
        end
    end

end
