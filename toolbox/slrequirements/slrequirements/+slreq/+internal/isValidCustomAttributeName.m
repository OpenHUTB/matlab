function[tf,invalidChars]=isValidCustomAttributeName(attrName)









    allowedSymbols='`~!@#\$%\^&\*\(\)\-=\+_\[\]\{\}\|:;"''/\?\., ';

    expr=['[^\w',allowedSymbols,']'];
    matchedCharCell=regexp(attrName,expr,'match');
    leadingSpaces=regexp(attrName,'^\s+','match');
    tf=isempty(matchedCharCell)&&isempty(leadingSpaces);



    invalidChars=unique([leadingSpaces,matchedCharCell]);
end
