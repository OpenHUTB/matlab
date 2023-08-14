function callRtm(blocks)




    import simscape.compiler.sli.internal.*;

    if isempty(blocks)
        return;
    end

    blockhandles=get_param(blocks,'Handle');
    if iscell(blockhandles)
        blockhandles=cell2mat(blockhandles);
    end

    numNeBlocks=numel(blockhandles);

    for i=1:numNeBlocks
        blockObject=get_param(blockhandles(i),'Object');
        callback('BlockCompile',blockObject);
    end


    callback('ModelCompile',bdroot(blockhandles(1)));

end

