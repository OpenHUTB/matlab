function clearSelection(varargin)






    if nargin==1
        [srcName,remainder]=strtok(varargin{1},'|');
        if isempty(remainder)
            return;
        else
            id=remainder(2:end);
        end
        if contains(id,'-')
            targetPosition=str2num(strtok(id,'-'));%#ok<ST2NM>
        else
            targetPosition=rmiml.idToRange(srcName,id);
        end
        if isempty(targetPosition)||targetPosition(end)==0
            return;
        end
    else
        srcName=varargin{1};
        targetPosition=varargin{2};
    end

    targetSelection=[targetPosition(1),targetPosition(1)];
    rmiut.RangeUtils.setSelection(srcName,targetSelection);
end
