function flag=isStringBuiltInFloat(DTString)






    flag=any(strcmpi(DTString,{'double','single','half'}));
end
