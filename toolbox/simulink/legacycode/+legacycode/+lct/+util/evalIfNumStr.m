function dataOut=evalIfNumStr(dataIn)











    if isnumeric(dataIn)
        dataOut=dataIn;
    elseif(ischar(dataIn)||(isstring(dataIn)&&isscalar(dataIn)))&&isNumStr(dataIn)
        dataOut=str2num(char(dataIn));%#ok<ST2NM>  Eval protected by isNumStr

    else
        dataOut=[];
    end

end

function flag=isNumStr(dataIn)



    dataIn=strtrim(dataIn);

    regexpNum='^\d*$';
    regexpArray='^\[[\d,;\s]*\]$';

    regexpTotal=sprintf('((%s)|(%s))',regexpNum,regexpArray);

    flag=~isempty(regexp(dataIn,regexpTotal,'once'));

end