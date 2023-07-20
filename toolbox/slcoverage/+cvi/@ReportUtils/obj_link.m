function out=obj_link(id,str)






    if length(id)>1
        out=sprintf('<a href="#refobj%d_%d">%s</a>',id(1),id(2),str);
    else
        out=sprintf('<a href="#refobj%d">%s</a>',id,str);
    end

