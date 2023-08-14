function s=struct(this)






    s=[];

    for indx=1:length(this.prop_sets)
        if this.prop_set_enables(indx)
            s=merge(s,struct(this.prop_sets{indx}));
        end
    end


    function s=merge(s,s_new)

        fn=fieldnames(s_new);

        for indx=1:length(fn)
            s.(fn{indx})=s_new.(fn{indx});
        end


