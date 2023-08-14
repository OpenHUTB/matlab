function[compType,accumType,rndMode,satMode]=getBlockInfo(this,slbh,hOutType)



    inputsigns=get_param(slbh,'Inputs');
    inputsigns=strrep(inputsigns,'|','');

    if~strcmp(inputsigns(1),'+')&&~strcmp(inputsigns(1),'-')

        nval=str2double(inputsigns);
        inputsigns=repmat('+',1,nval);
    end

    hasPlus=~isempty(regexpi(inputsigns,'+'));
    hasMinus=~isempty(regexpi(inputsigns,'-'));

    if hasPlus&&~hasMinus
        compType='sum';
    else
        error(message('hdlcoder:validate:unsupportedminus',this.localGetBlockName(slbh)));
    end






    accumType=this.getAccumTypeForSum(slbh,hOutType);



    rndMode=get_param(slbh,'RndMeth');
    if strcmpi(get_param(slbh,'DoSatur'),'on')
        satMode='Saturate';
    else
        satMode='Wrap';
    end




