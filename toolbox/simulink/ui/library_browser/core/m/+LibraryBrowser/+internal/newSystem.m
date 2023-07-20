function sysname=newSystem(systype)




    sys=new_system('',systype);
    open_system(sys);
    sysname=get_param(sys,'Name');
end
