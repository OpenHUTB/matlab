function result=filterChars(input,allowCR,allowHTab)

    if isempty(input)
        result='';
        return;
    end

    if nargin<2
        allowCR=false;
    end

    if nargin<3
        allowHTab=false;
    end

    if allowCR&&allowHTab
        badChars=[0:8,11:31,127,160,255];
    elseif allowCR
        badChars=[0:9,11:31,127,160,255];
    elseif allowHTab
        badChars=[0:8,10:31,127,160,255];
    else
        badChars=[0:31,127,160,255];
    end

    isBadChar=ismember(input,badChars);
    input(isBadChar)=32;
    noJointSpaces=regexprep(input,'  +',' ');
    result=strtrim(noJointSpaces);
end

