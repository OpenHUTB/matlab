function cs=getConfigSet(arg)






    narginchk(1,1);
    firstArg=convertStringsToChars(arg);
    model=[];
    cs=[];


    firstArgIsConfigSet=false;
    firstArgIsModelHandle=false;
    firstArgIsModelName=false;


    if isa(firstArg,'Simulink.ConfigSetRoot')
        firstArgIsConfigSet=true;
    elseif ishandle(firstArg)
        firstArgIsModelHandle=true;
    elseif ischar(firstArg)
        firstArgIsModelName=true;
    end


    if firstArgIsConfigSet
        cs=firstArg;
        sysFound=true;
    elseif firstArgIsModelHandle
        model=firstArg;
        sysFound=~isempty(find_system('type','block_diagram','handle',model));
    elseif firstArgIsModelName
        model=firstArg;
        sysFound=~isempty(find_system('type','block_diagram','name',model));
    else
        sysFound=false;
    end
    if~sysFound
        if firstArgIsModelHandle
            error(message('Simulink:dialog:NoModelWithHandle',num2str(model)));
        elseif firstArgIsModelName
            error(message('Simulink:dialog:ModelNotFound',model));
        else
            error(message('Simulink:dialog:FirstInpArgMustBeValidModel','Simulink.ConfigSet'));
        end
    end


    if firstArgIsModelName||firstArgIsModelHandle
        cs=getActiveConfigSet(model);
    else
        if firstArgIsConfigSet

            cs=cs.getConfigSetSource;
        end
    end
end


