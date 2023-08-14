function p=isMexOrBlasCallbackEnabled(cfg)





    if~isempty(cfg)
        opt1=isCodeGenTarget(cfg,'mex');
        isMex=~isempty(opt1)&&opt1(1);

        opt2=getConfigProp(cfg,'CustomBLASCallback');
        isCallback=~isempty(opt2)&&opt2(1);
    else
        isMex=false;
        isCallback=false;
    end

    p=isMex||isCallback;

end