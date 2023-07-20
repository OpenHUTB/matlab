function data=lct_pGetDataFromArg(info,arg)






    type=arg.Type;
    data=info.([type,'s']).(type)(arg.DataId);
