function inputsigns=getInputSigns(~,slbh)


    inputsigns=get_param(slbh,'Inputs');
    inputsigns=strrep(inputsigns,'|','');

    if~strcmp(inputsigns(1),'+')&&~strcmp(inputsigns(1),'-')

        nval=str2double(inputsigns);
        inputsigns=repmat('+',1,nval);
    end
end
