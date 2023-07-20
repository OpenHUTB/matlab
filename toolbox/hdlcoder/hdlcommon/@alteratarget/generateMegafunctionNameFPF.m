
function name=generateMegafunctionNameFPF(baseType,className,mnemonic)



    if nargin<3
        mnemonic=[];
    end
    name=targetcodegen.alterafpfdriver.getFunctionName(className,mnemonic);
    baseType=strrep(baseType,',','_');
    baseType=strrep(baseType,'(','');
    baseType=strrep(baseType,')','');
    name=sprintf('%s_%s',name,lower(baseType));

