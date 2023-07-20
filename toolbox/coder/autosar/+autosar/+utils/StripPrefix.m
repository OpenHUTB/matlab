function res=StripPrefix(inputStr)













    res=regexprep(inputStr,'\s*((Enum)\s*:|(Bus)\s*:|(ValueType)\s*:|?)\s*','','ignorecase');
end


