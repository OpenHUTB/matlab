%#codegen
function y=hdleml_deadzone(u,upper_limit,lower_limit)










    coder.allowpcode('plain')
    eml_prefer_const(upper_limit,lower_limit);

    y=hdleml_deadzone_dynamic(upper_limit,u,lower_limit);
end
