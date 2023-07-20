function hide(obj)





    cmp=obj.getComponent();
    if~isvalid(cmp)
        return;
    end

    st=obj.studio;
    st.hideComponent(cmp);

