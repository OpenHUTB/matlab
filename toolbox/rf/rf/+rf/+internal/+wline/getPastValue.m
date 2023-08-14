function vout=getPastValue(n,t,v1,v2,ttarget)%#codegen






    if ttarget<=t(1)
        vout=[v1(1),v2(1)];
    elseif ttarget>=t(n)
        vout=[v1(n),v2(n)];
    else

        i=first_greater_than(n,t,ttarget);
        if i<=2
            i=int32(3);
        end
        j=i-2;
        tscale=t(i)-t(j);
        m=vander([0;(t(j+1)-t(j))/tscale;1]);
        v=[v1(j:i),v2(j:i)];
        c=m\v;
        tts=(ttarget-t(j))/tscale;
        mt=[tts^2,tts,1];
        vout=mt*c;
    end
end

function indx=first_greater_than(n,t,val)
    assert(val>t(1))
    assert(val<t(n))
    lb=int32(1);
    ub=int32(n);

    while ub-lb>1
        med=int32(floor((ub+lb)/2));

        if t(med)>val
            ub=med;
        else
            lb=med;
        end
    end
    indx=ub;

end
