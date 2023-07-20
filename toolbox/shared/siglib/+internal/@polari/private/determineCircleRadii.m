function normRadii=determineCircleRadii(alim,ticks)






    a1=alim(1);
    a2=alim(2);
    da=a2-a1;
    Nt=numel(ticks);

    if Nt==0


        ticks=[alim(1),sum(alim)/2,alim(2)];

    elseif Nt==1

        if any(ticks==alim)


            ticks=[alim(1),sum(alim)/2,alim(2)];
        else


            ticks=[alim(1),ticks,alim(2)];
        end

    elseif Nt==2












        new_mid=sum(ticks)/2;
        t_lo=ticks(1);
        t_hi=ticks(2);
        new_circle_spacing=new_mid-t_lo;


        new_lo=t_lo-new_circle_spacing;
        if new_lo<=a1
            new_lo=[];
        end


        new_hi=t_hi+new_circle_spacing;
        if new_hi>=a2
            new_hi=[];
        end

        ticks=[new_lo,t_lo,new_mid,t_hi,new_hi];
        Nt=numel(ticks);
    end

    if Nt==0

        normRadii=1.0;
    elseif a1==ticks(1)
        if a2==ticks(end)




            normRadii=(ticks(2:end)-a1)./da;
        else




            normRadii=[(ticks(2:end)-a1)./da,1];
        end
    elseif alim(2)==ticks(end)



        normRadii=(ticks-a1)./da;
    else



        normRadii=[(ticks-a1)./da,1];
    end

end
