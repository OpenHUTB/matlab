function daRoot=getDASRoot()
    if inmem('-isloaded','DAStudio.Root')
        daRoot=DAStudio.Root;
    else
        daRoot=[];
    end
end