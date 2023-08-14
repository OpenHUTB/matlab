function flag=isStringBoolean(DTString)






    flag=strcmpi(DTString,'boolean')||strcmpi(DTString,'logical');
end
