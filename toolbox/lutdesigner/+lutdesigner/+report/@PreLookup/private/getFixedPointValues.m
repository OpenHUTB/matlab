function fixedPointValues=getFixedPointValues(fixedPointData)





    fpData=fixedPointData.Value;

    fpDatawithoutBraces=fpData(2:end-1);
    sz=size(fixedPointData);

    fixedPointValues=cell(sz(1),sz(2));

    fpDatawithoutBraces=strsplit(fpDatawithoutBraces,';');
    dataWithoutBracesLen=size(fpDatawithoutBraces);

    fixedPointRowValues=cell(dataWithoutBracesLen(1),dataWithoutBracesLen(2));

    for i=1:length(fpDatawithoutBraces)
        fixedPointRowValues{i}=strsplit(fpDatawithoutBraces{i},' ');
    end

    for j=1:length(fixedPointRowValues)
        c=fixedPointRowValues{j};
        for m=1:length(c)
            fixedPointValues{j,m}=c{m};
        end

    end

end
