function outStr=capitalizeFirstChar(str)





    if~isempty(str)&&str~=""
        firstChar=extractBefore(str,2);
        c=upper(firstChar);
        remainingString=extractAfter(str,1);
        outStr=strcat(c,remainingString);
    else
        outStr=str;
    end
