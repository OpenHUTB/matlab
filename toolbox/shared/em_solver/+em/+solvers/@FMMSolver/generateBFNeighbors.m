function generateBFNeighbors(obj)




    lambda=2*pi/obj.Wavenumber;
    geom=obj.Geom;
    tempNumRWG=ceil(obj.PreconditionerSize*geom.EdgesTotal);
    if strcmpi(obj.PreconditionerSize,'Auto')||tempNumRWG<10

        obj.NumRWG=ceil((lambda/2/mean(geom.RWGDistance))^2);

        if obj.NumRWG>geom.EdgesTotal
            obj.NumRWG=ceil(geom.EdgesTotal/4);
        end

        if geom.EdgesTotal>1500

            preconRatio=obj.NumRWG/geom.EdgesTotal;
            if geom.EdgesTotal<1e6

                fillfactor=[.0025,.01];
                if(preconRatio>max(fillfactor))||(preconRatio<min(fillfactor))
                    obj.NumRWG=ceil(max(fillfactor)*geom.EdgesTotal);
                end
            else

                fillfactor=[.0001,.005];
                obj.NumRWG=ceil(max(fillfactor)*geom.EdgesTotal);
            end
        end





    else
        obj.NumRWG=tempNumRWG;
    end

    kdt=KDTreeSearcher(geom.RWGCenter);
    Neighbors=knnsearch(kdt,geom.RWGCenter,'k',obj.NumRWG);


    obj.Geom.Neighbors=Neighbors;
end
