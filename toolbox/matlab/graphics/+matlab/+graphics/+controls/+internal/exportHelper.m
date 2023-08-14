function result=exportHelper(ax)






    result=ax;



    if numel(ax)>1
        result=ax(1).Parent;
    end

