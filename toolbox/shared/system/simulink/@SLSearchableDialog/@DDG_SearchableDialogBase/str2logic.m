function result=str2logic(~,cellstr)





    result=cellfun(@str2logic_element,cellstr);

end


function result=str2logic_element(str)



    if strcmp(str,'on')
        result=true;
    else
        result=false;
    end

end
