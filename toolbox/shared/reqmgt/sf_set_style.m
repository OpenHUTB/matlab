function sf_set_style(obj,style)



    if isempty(obj)||obj==0||~sf('ishandle',obj)

        return;
    end

    sf('SetAltStyle',style,obj);


    while(1)
        obj=sf('get',obj,'transition.subLink.next');
        if isempty(obj)||obj==0
            break;
        end
        sf('SetAltStyle',style,obj);
    end
