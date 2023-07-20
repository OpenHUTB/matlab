function[idq_limits]=autoblks_determine_max_current(T_max,PolePairs,lambda_pm)



    idq_limits=T_max/(1.5*PolePairs*lambda_pm);

end

