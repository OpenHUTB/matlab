function[objIdx,gradIdx,objIdxArray]=createClosedFormIdxString(idxObjectives,...
    idxVector,IsJacobianRequired)









    objIdx="";

    if isempty(idxVector)

        gradIdx="";
        objIdxArray="";
        return;
    end


    nLabelledObjectives=numel(idxObjectives);
    objIdxArray=strings(1,nLabelledObjectives);
    for i=1:nLabelledObjectives
        lIdx=idxObjectives(i);
        thisIdx=[idxVector.Start(lIdx),idxVector.End(lIdx)];


        thisIdx=unique(thisIdx);
        thisIdxStr=optim.internal.problemdef.indexing.getIndexingString(thisIdx,true);
        objIdx=objIdx+thisIdxStr+", ";
        objIdxArray(i)=thisIdxStr;
    end


    objIdx=extractBefore(objIdx,strlength(objIdx)-1);


    if nLabelledObjectives>1
        objIdx="["+objIdx+"]";
    end
    if IsJacobianRequired
        gradIdx="("+objIdx+", :)";
    else
        gradIdx="(:, "+objIdx+")";
    end
    objIdx="("+objIdx+")";

end
