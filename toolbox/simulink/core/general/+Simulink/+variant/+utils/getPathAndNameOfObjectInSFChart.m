function[objPath,objName]=getPathAndNameOfObjectInSFChart(objName)













    objPath='';

    strCell=strsplit(objName,'.');

    if numel(strCell)==1
        return;
    end

    objPath=strjoin(strCell(1:end-1),'/');

    objName=strCell{end};

end
