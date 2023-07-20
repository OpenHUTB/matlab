function[saxlim,ticks,scale,units]=findMagTicks_Auto(mlim,rescaleLimits)
















    [~,scale,units]=engunits(max(abs(mlim)));
    saxlim=ensureValidLim(mlim*scale);

    if rescaleLimits

        rmax=saxlim(2);
        rmin=saxlim(1);
        r=10^floor(log10(rmax-rmin));
        rmax=ceil(saxlim(2)/r)*r;
        rmin=floor(saxlim(1)/r)*r;
        saxlim=[rmin,rmax];
    end





    if diff(saxlim)>2

        nice_deltas=[0.5,1,2,2.5,5,10,20,25,50,100,200,500];
    else




        nice_deltas=[0.01,0.02,0.05,0.1,0.2,0.25,0.5,1];
    end
    nice_num_ticks=[6,5,4,3];
    weight_num_ticks=[3,1,1,4];

    N_deltas=numel(nice_deltas);
    minJ_val=zeros(1,N_deltas);
    minJ_numTickIdx=zeros(1,N_deltas);
    for i=1:N_deltas






        delta_i=nice_deltas(i);




        t=saxlim(1)/delta_i;
        t1=delta_i*floor(t);
        if t1<saxlim(1)
            t1=delta_i*ceil(t);
        end




        t=saxlim(2)/delta_i;
        t2=delta_i*ceil(t);
        if t2>saxlim(2)
            t2=delta_i*floor(t);
        end


        dt=t2-t1;

        if dt<=0


            minJ_val(i)=inf;
            minJ_numTickIdx(i)=0;
        else

            spanPerTick=dt./(nice_num_ticks-1);







            j_i=abs(spanPerTick-delta_i)./delta_i.*weight_num_ticks;


            [minJ_val(i),minJ_numTickIdx(i)]=min(j_i);
        end
    end

    if all(isinf(minJ_val))






















        t=sum(saxlim)/2;
        tr=round(t*100)/100;
        if t>tr
            ticks=[tr,tr+.01];
        else
            ticks=[tr-.01,tr];
        end
        saxlim=ticks;

        return
    end




    [~,idx1]=min(minJ_val);
    best_delta=nice_deltas(idx1);



    t=saxlim(1)/best_delta;
    t1=best_delta*floor(t);
    if t1<saxlim(1)
        t1=best_delta*ceil(t);
    end

    t=saxlim(2)/best_delta;
    t2=best_delta*ceil(t);
    if t2>saxlim(2)
        t2=best_delta*floor(t);
    end



    ticks=t1:best_delta:t2;
    assert(numel(ticks)>1);

end
