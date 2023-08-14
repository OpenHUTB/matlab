function str=getPlaneInteractions(TF)









    n=sum(TF);
    switch n
    case 4
        str="all";
    case 0
        str="none";
    otherwise
        str=[];
        if TF(1)
            str=[str,"add"];
        end
        if TF(2)
            str=[str,"remove"];
        end
        if TF(3)
            str=[str,"rotate"];
        end
        if TF(4)
            str=[str,"translate"];
        end
    end