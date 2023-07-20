function value=evalStr(str)



    try
        value=double(eval(str));
    catch Exception %#ok
        value=[];
    end
end

