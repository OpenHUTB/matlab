function v=validBlockMask(~,slbh)

    v=true;
    if slbh<0
        return;
    end

    inputsigns=get_param(slbh,'Inputs');
    inputsigns=strrep(inputsigns,'|','');

    if~isempty(strfind(inputsigns,'/'))

        v=false;
    end


    if length(inputsigns)>1

        v=false;
    else
        p=str2num(inputsigns);
        if~isempty(p)&&p>1

            v=false;
        end
    end

