function[failed,dosOutput]=cgxe_dos(command)



    if strncmp(pwd,'\\',2)
        [dosOutput,failed]=evalc(['mydos(''',command,''');']);
    else
        [dosOutput,failed]=evalc(['dos(''',command,''');']);
    end

    cgxe_display(sprintf('%s\n',dosOutput));


    function[status,result]=mydos(b)%#ok

        p=pwd;
        t=tempdir;
        cd(t);

        newcmd=sprintf('pushd %s & %s & popd',p,b);
        [status,result]=dos(newcmd,'-echo');

        cd(p);
