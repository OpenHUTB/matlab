function copyTclHelper(h,tclHelper)





    str=fileread(tclHelper);




    expr='foreach +\w+ +\$env\(SOURCES\).*?}';
    idx=regexp(str,expr,'end');

    coreloop=sprintf([...
    '\n\t','foreach source $env(SOURCES_CORE) {\n'...
    ,'\t\t','set source $env(SOURCE_ROOT)$source\n'...
    ,'\t\t','puts ">>> Adding copy of source to project: $source"\n'...
    ,'\t\t','xfile add $source -copy\n'...
    ,'\t','}\n']);


    str=[str(1:idx),coreloop,str(idx+1:end)];


    h.writeTclScript('ise_helper.tcl',str,'',false);

