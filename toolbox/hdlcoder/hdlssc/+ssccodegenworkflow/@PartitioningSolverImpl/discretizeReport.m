function report=discretizeReport(obj)








    hasDiffClump=~isempty(obj.EqnData.DiffClumpInfo.DiffStates);
    numClumps=hasDiffClump+numel(obj.EqnData.ClumpInfo);


    report=cell(numClumps,1);
    if hasDiffClump
        Asize=size(obj.EqnData.DiffClumpInfo.MdInv);
        report{1}=sizeToReport(Asize);
    else
        report{1}='';
    end

    for i=1:numel(obj.EqnData.ClumpInfo)
        Asize=size(obj.EqnData.ClumpInfo(i).Ad);
        Bsize=size(obj.EqnData.ClumpInfo(i).MdInv);
        report{i+1}{1}=sizeToReport(Asize);
        report{i+1}{2}=sizeToReport(Bsize);

    end



end

function r=sizeToReport(matSize)

    r=join(cellstr(num2str(matSize')),' x ');
end
