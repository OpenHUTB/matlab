

function ret=calcMultiRangeOp(opFunction,isComplex,inRange1,inRange2)










    if nargin()<4
        ranges=zeros(size(inRange1,1),2);
        for idx=1:size(inRange1,1)
            ranges(idx,:)=opFunction(inRange1(idx,:),isComplex);
        end
    else
        pairs=generateRangeCombinations(inRange1,inRange2);
        ranges=zeros(size(pairs,1),2);
        for idx=1:size(pairs,1)
            range=opFunction(pairs{idx,1},pairs{idx,2},isComplex);
            ranges(idx,:)=range;
        end
    end

    ranges=num2cell(ranges,2);
    ret=Simulink.FixedPointAutoscaler.InternalRange.mergeRange(ranges{:});
end

function ret=generateRangeCombinations(inRange1,inRange2)



    len1=size(inRange1,1);
    len2=size(inRange2,1);
    ret=cell(len1*len2,2);
    for i=1:len1
        for j=1:len2
            ret{(i-1)*len2+j,1}=inRange1(i,:);
            ret{(i-1)*len2+j,2}=inRange2(j,:);
        end
    end
end