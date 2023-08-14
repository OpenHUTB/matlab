function out=obj_anchor(id,str)






    if length(id)>1
        out=sprintf('<a name="refobj%d_%d"> %s </a>',id(1),id(2),str);
    else
        out=sprintf('<a name="refobj%d"> %s </a>',id,str);
    end
