function[normdata,linearbounds]=normalize(data,scale)






    if scale=="log"
        normdata=log(data);
    else
        normdata=data;
    end

    if all(diff(normdata)==0)

        linearbounds=[];
    else



        linearbounds=[min(normdata),max(normdata)];
        normdata=Aero.internal.math.map(normdata,linearbounds,[0,1]);
    end
end

