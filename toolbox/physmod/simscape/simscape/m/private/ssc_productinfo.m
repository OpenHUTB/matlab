function info=ssc_productinfo












    persistent INFO;




    if isempty(INFO)
        INFO=lReadProductInfo;
    end

    info=INFO;
end

function info=lReadProductInfo






    info=ver('Simscape');

end

