function[qrvalue,svalue]=quantizePluginParameterValue(param,rvalue)







    narginchk(2,2);
    [fromNorm,fromProp]=getPluginMappingRules(param);
    svalue=single(fromProp(rvalue));
    qrvalue=fromNorm(double(svalue));
end
