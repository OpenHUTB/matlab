function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2Cxo8S0BgVPCeGaJx0DvYVuVVeDPTJJHWseX/1jUGqTPvqGstlFXaoSMKH7'...
        ,'F2Rfe+fgKidiAQaiWB3O+R6ax5d4aI9+wmqwpU+gVfopV2pd6eu7ZEuSgvzY'...
        ,'XEYq9ybl/utdBWvU+b048MEBWWfk0EqcREIS4wawWHrnkokxxv8e9V9J4nlC'...
        ,'Wc58MsUKwEqrN/NLGp1R0I+ltuD5SAeVcvtpwQqKrRw0sDcBs6r1Lugiw7wd'...
        ,'3HvDxJxhbVuaDUMMnRA4Nji1lU1sX4W8Lk1jBiU4hXWkpFE/3gt0gL5jNzeA'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end