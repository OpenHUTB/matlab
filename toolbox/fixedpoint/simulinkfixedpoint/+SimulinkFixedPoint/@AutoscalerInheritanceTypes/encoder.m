function encodedString=encoder(dataTypeString)






    encodedString=regexprep(dataTypeString,'Inherit:','');


    encodedString=regexprep(encodedString,'\W','');


    encodedString=upper(encodedString);
end