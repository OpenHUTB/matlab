function[result,position]=isNameValid(name,failRegExp)

    result=true;
    position=[0,0];


    [startIndex,endIndex]=regexp(name,failRegExp);
    if~isempty(startIndex)&&~isempty(endIndex)
        result=false;
        position=[startIndex',endIndex'];
        return;
    end
end