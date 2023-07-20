function element=getVectorFirstLastElement(vector,element_type)









    param_value=protectedNumericConversion(vector);


    if strcmp(element_type,'first')
        if~isempty(param_value)
            element=num2str(double(param_value(1)),16);
        elseif isvarname(vector)
            element=[vector,'(1)'];
        else
            element=[' getfield(',vector,',{1})'];
        end
    else
        if~isempty(param_value)
            element=num2str(double(param_value(end)),16);
        elseif isvarname(vector)
            element=[vector,'(end)'];
        else
            element=['getfield(',vector,',{ numel(',vector,') }) '];
        end
    end

end