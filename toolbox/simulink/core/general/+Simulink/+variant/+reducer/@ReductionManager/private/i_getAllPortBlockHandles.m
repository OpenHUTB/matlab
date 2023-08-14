





























function blkCellH=i_getAllPortBlockHandles(blkH)



    portNumArr=char(get(blkH,'Port'));
    if isempty(portNumArr)
        blkCellH={};
        return;
    end
    portNumArr=str2num(portNumArr);%#ok<ST2NM>
    blkCellH=cell(1,max(portNumArr));
    for ii=1:numel(portNumArr)
        blkIdx=portNumArr(ii);
        blkCellH{blkIdx}=[blkCellH{blkIdx},blkH(ii)];
    end
end


