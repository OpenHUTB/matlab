function tdkcs=gettdkfpgaconfigset(cs)









    narginchk(1,1);



    if isa(cs,'tdkfpgacc.ConfigSet'),
        tdkcs=cs;
    else
        if~isa(cs,'Simulink.ConfigSet')&&~isa(cs,'Simulink.ConfigSetRef')
            error(message('EDALink:gettdkfpgaconfigset:InvalidConfigSet'));
        end
        components=cs.Components;
        names=get(components,'Name');
        tdkcs=components(find(strcmp(names,'EDA Link')));
    end
