function[Uup,Udown,Uoffset,UoffsetScale]=uniqifyUpDownOffset(this,up,down,offset,offsetScale)





    found=false;
    Uup=up(1);
    Udown=down(1);
    Uoffset=offset(1);
    UoffsetScale=offsetScale(1);

    for i=2:length(up)
        found=false;
        for Ui=1:length(Uup)
            if(Uup(Ui)==up(i)&&Udown(Ui)==down(i)&&Uoffset(Ui)==offset(i))
                found=true;
                break;
            end
        end
        if~found
            Uup=[Uup,up(i)];
            Udown=[Udown,down(i)];
            Uoffset=[Uoffset,offset(i)];
            UoffsetScale=[UoffsetScale,offsetScale(i)];
        end
    end