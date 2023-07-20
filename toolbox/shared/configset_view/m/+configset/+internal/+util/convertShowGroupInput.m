function output=convertShowGroupInput(input)





    comp=convertCharsToStrings(input);


    comp=strrep(comp,'\','/');
    comp=strrep(comp,'Data Import/Export','Data Import//Export');
    comp=strrep(comp,message('RTW:configSet:configSetDataIO').getString,...
    message('RTW:configSet:configSetDataIO_2').getString);

    output=comp;
