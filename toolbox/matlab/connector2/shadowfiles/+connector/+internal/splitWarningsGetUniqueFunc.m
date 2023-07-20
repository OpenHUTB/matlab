function[splitWarnings,func,uniqueFunc]=splitWarningsGetUniqueFunc(warnings)









    str=sprintf('[%cWarning: Function ',char(8));
    msg=strsplit(warnings,str);


    msg=msg(~cellfun('isempty',msg));


    splitWarnings=cellfun(@(x)[str,x],msg,'UniformOutput',0);


    func=regexp(msg,'\w*','match','once');


    uniqueFunc=unique(func);