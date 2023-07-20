function param=HtoIL_subtract_first_vector_element(param)









    vector_value=str2num(param.base);%#ok<ST2NM> for vector



    if~isempty(vector_value)
        param.base=['[',num2str(vector_value-vector_value(1)),']'];

    elseif isvarname(param.base)
        param.base=['[',param.base,' - ',param.base,'(1)]'];

    else
        param.base=['[',param.base,' - getfield(',param.base,',{1}) ]'];
    end

end