
function name=generateMegafunctionName(baseType,className,mnemonic)



    if nargin<3
        mnemonic=[];
    end
    name=targetcodegen.alteradriver.getFunctionName(className,mnemonic);
    if baseType.isDoubleType
        name=sprintf('%s_double',name);
    else
        name=sprintf('%s_single',name);
    end

