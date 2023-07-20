function metalbasis=findLitRegions(metalbasis,P,t,idPO,feededge,mode)


    idTri=find(idPO);

    vert1=P(:,t(1,idTri))';
    vert2=P(:,t(2,idTri))';
    vert3=P(:,t(3,idTri))';
    dist=1e9;
    C=em.internal.meshprinting.meshtricenter(P',t(1:3,idTri)');
    N_angs=size(feededge,2);
    if N_angs>2
        msg=sprintf('Calculating illuminated region for %d incident angles',...
        N_angs);
        hwaitlit=waitbar(0,msg,'Name','Lit region sweep',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(hwaitlit,'canceling',0)
    else
        hwaitlit=[];
    end

    for k=1:N_angs
        litID=[];
        switch mode
        case 'edge'
            FeedCenter=metalbasis.RWGCenter(:,feededge(1,k));
        case 'location'
            FeedCenter=feededge(:,k);
        end
        O=C-FeedCenter';
        O=O./vecnorm(O,2,2);





        for i=1:size(O,1)

            D=em.internal.SegmentTriangleIntersectionNtoN(FeedCenter',O(i,:),...
            vert1,vert2,vert3,...
            dist);







            [~,minID]=min(D);
            litID=[litID,minID'];
        end

        N=size(O,1);

        litID=unique(idTri(litID));
        metalbasis.Lit(:,k)=double(ismember(metalbasis.TrianglePlus+1,litID)&ismember(metalbasis.TriangleMinus+1,litID));
        if N_angs>2

            if getappdata(hwaitlit,'canceling')
                status=1;
                break
            end
            msg=sprintf('Calculating illuminated region for %d/%d incident angles',...
            k,N_angs);
            waitbar(k/N_angs,hwaitlit,msg);
        end
    end

    if N_angs>2
        delete(hwaitlit);
    end

end