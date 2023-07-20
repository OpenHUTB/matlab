function charts=obj_chart(objs)







    charts=zeros(length(objs),1);
    for i=1:length(objs)

        if(sf('get',objs(i),'.isa')==sf('get','default','chart.isa'))
            charts(i)=objs(i);
        else
            charts(i)=sf('get',objs(i),'.chart');
        end
    end
    charts=unique(charts);
