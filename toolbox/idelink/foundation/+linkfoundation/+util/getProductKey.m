function productKey=getProductKey(filePath)





    filePath=regexprep(filePath,'\','/');


    path_prefix=['test/tools','|'...
    ,'toolbox/shared/etargets','|'...
    ,'toolbox/idelink/extensions','|'...
    ,'toolbox/rtw/targets','|'...
    ,'toolbox/target/extensions/processor','|'...
    ,'toolbox/target/foundation','|'...
    ,'toolbox'];

    tokens=regexp(filePath,['(',path_prefix,')/(\w*)'],'tokens');
    if isempty(tokens)
        DAStudio.error('ERRORHANDLER:utils:unknownProductKey');
    end


    switch tokens{1}{1}
    case{'toolbox/idelink/extensions'}

        productKey=strcat(tokens{1}{2},'ext');
    case{'toolbox/target/foundation'}

        productKey='targetfoundation';
    case{'toolbox/target/extensions/processor'}
        if isequal(tokens{1}{2},'shared')

            productKey='targetshared';
        else
            productKey=tokens{1}{2};
        end
    case{'toolbox/shared/etargets'}

        productKey='targetshared';
    otherwise
        productKey=tokens{1}{2};
    end


    if strcmp(productKey,'idelink')
        productKey='errorhandler';
    end


