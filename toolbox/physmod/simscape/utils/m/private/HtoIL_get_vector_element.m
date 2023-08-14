function element=HtoIL_get_vector_element(param,type)











    element=param;

    param_value=str2num(param.base);%#ok<ST2NM> for vector


    if strcmp(type,'first')

        if~isempty(param_value)
            element.base=num2str(param_value(1));
        elseif isvarname(param.base)
            element.base=[param.base,'(1)'];
        else
            element.base=[' getfield(',param.base,',{1})'];
        end

    else

        if~isempty(param_value)
            element.base=num2str(param_value(end));
        elseif isvarname(param.base)
            element.base=[param.base,'(end)'];
        else
            element.base=['getfield(',param.base,',{ numel(',param.base,') }) '];
        end

    end

end