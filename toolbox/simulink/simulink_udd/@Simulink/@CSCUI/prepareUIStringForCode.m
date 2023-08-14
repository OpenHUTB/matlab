function codeString=prepareUIStringForCode(string)









    before={'\\','\n'};
    after={'\\\\','\\n'};
    codeString=regexprep(string,before,after);
end


