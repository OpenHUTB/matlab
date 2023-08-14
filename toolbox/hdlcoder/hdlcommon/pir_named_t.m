function t=pir_named_t(paramName)










    narginchk(1,1);
    pir_udd;
    t=hdlcoder.tp_parameterized(paramName,2);
end
