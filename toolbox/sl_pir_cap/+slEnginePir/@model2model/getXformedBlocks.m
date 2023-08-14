function xformedBlocks=getXformedBlocks(this)



    xformedBlocks=[];
    for i=1:length(this.fXformedBlks)
        xformedBlocks=[xformedBlocks;this.fXformedBlks(i).Before];%#ok
    end
    xformedRefBlocks=[{},get_param(xformedBlocks,'ReferenceBlock')];
    xformedRefBlocks=xformedRefBlocks(~cellfun('isempty',xformedRefBlocks));
    xformedRefBlocks=get_param(xformedRefBlocks,'Handle');
    xformedBlocks=[xformedBlocks;cell2mat(xformedRefBlocks)];
end
