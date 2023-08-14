function status=getFastParamStatus(obj,pdata,component,cs,compStatusMap)






    if~pdata.DependencyOverride

        st(1)=compStatusMap(pdata.Component);

        if st(1)==3
            status=st(1);
            return;
        end
    end



    if~isempty(pdata.Dependency)
        st(2)=pdata.Dependency.getStatus(cs,pdata.Name,obj);
    else
        st(2)=0;
    end
    ln=2;

    if st(2)==3
        status=3;
        return;
    end

    if isa(pdata,'configset.internal.data.WidgetStaticData')

        if~isempty(pdata.Parameter.Dependency)
            st(3)=pdata.Parameter.Dependency.getStatus(cs,pdata.Parameter.Name,obj);
        else
            st(3)=0;
        end
        ln=3;
    end

    status=max(st);
    if status>=2
        return;
    end


    name=pdata.getParamName;




    if~component.isValidProperty(name)


        if isa(component,'hdlcoderui.hdlcc')
            component=[];
            st(ln+1)=strcmp(cs.readonly,'on');
        elseif isa(cs,'Simulink.ConfigSet')
            component=cs.getPropOwner(name);
        else
            component=[];
        end
    end
    if~isempty(component)
        st(ln+1)=component.isReadonlyProperty(name);
    end

    status=max(st);


end





