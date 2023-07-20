function register_simscape_product_checks(checks)







    modelAdvisorRoot=ModelAdvisor.Root;

    for i=1:length(checks)
        modelAdvisorRoot.register(checks{i});
    end

end
