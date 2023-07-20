function register_simscape_product_checks(checks)







    mdlAdvisor=ModelAdvisor.Root;

    for i=1:length(checks)
        mdlAdvisor.publish(checks{i},'Simscape');
    end
end

