function funhandle=snapExtraParams(fun,extraParams)










    funhandle=@(x)fun(x,extraParams);

end