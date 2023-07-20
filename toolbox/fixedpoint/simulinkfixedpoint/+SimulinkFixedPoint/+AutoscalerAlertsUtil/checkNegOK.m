function isOK=checkNegOK(curVal,containerInfo)




    isOK=true;

    if isempty(curVal)||isinf(curVal)
        return;
    end

    if isempty(containerInfo)
        return;
    end



    if curVal<0&&~containerInfo.evaluatedNumericType.Signed
        isOK=false;
    end
end