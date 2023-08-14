function metalbasis=alignfeedcurrents(metalbasis,t,feededge,objname)

    if strcmpi(objname,'pcbStack')||strcmpi(objname,'customAntennaStl')...
        ||strcmpi(objname,'rfpcb.PrintedLine')...
        ||strcmpi(objname,'em.PrintedAntenna')
        Tp=metalbasis.TrianglePlus+1;
        for n=1:size(feededge,2)
            aa=t(:,Tp(:,feededge(:,n)));
            if~isequal(aa(4,:),aa(4,1))
                for m=2:size(feededge,1)
                    if(aa(4,m)~=aa(4,1))
                        temp=metalbasis.TrianglePlus(feededge(m,n));
                        metalbasis.TrianglePlus(feededge(m,n))=...
                        metalbasis.TriangleMinus(feededge(m,n));
                        metalbasis.TriangleMinus(feededge(m,n))=temp;

                        temp=metalbasis.VerP(feededge(m,n));
                        metalbasis.VerP(feededge(m,n))=...
                        metalbasis.VerM(feededge(m,n));
                        metalbasis.VerM(feededge(m,n))=temp;

                    end
                end
            end
        end
    end

end