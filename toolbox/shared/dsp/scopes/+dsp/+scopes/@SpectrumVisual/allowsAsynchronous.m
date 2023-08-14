function b=allowsAsynchronous(this)






    stack=dbstack;
    for i=1:4
        if any(strcmp(stack(i).name,{'shouldShowControls','renderMenus'}))
            b=false;
            return;
        end
    end

    hSource=this.Application.DataSource;
    if~isempty(hSource)&&strcmp(hSource.Type,'Simulink')

        b=true;
    else
        b=false;
    end
