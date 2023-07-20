function t=pir_parameterized_t(paramName)











    narginchk(1,1);
    pir_udd;
    t=hdlcoder.tp_parameterized(paramName,1);
end
