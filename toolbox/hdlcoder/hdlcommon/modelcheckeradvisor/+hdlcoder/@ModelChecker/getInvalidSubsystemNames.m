function candidateBlks=getInvalidSubsystemNames(sys)




    candidateBlks=[];
    blocks=hdlcoder.ModelChecker.find_system_MAWrapper(sys,'RegExp','On','BlockType','SubSystem');


    for ii=1:numel(blocks)
        blk=blocks{ii};
        blkH=get_param(blk,'Handle');

        ref=get_param(blkH,'ReferenceBlock');
        if isempty(ref)
            name=get_param(blkH,'Name');
            len=strlength(name);
            if(len<2)
                candidateBlks(end+1)=blkH;%#ok<AGROW>
            elseif(len>32)
                candidateBlks(end+1)=blkH;%#ok<AGROW>
            end
        end
    end
end
