






function L=plotBoundingBoxes(ax,g,c)



    L=gobjects(0,1);




    [K,Ld]=size(g);
    g=double((g~=0));
    g=[zeros(K,1),g,zeros(K,1)];
    g=[zeros(1,Ld+2);g;zeros(1,Ld+2)];


    for d=1:2




        [k,l]=find(diff(g,[],d));



        k=k-1;
        l=l-1;










        nonconsecfn=@(a,b,f)(diff(f(a))~=1|diff(f(b))~=0);
        startfn=@(x)[-1;x];
        finishfn=@(x)[x;-1];




        if(d==1)
            [k,ia]=sort(k);
            l=l(ia);
            start=nonconsecfn(l,k,startfn);
            finish=nonconsecfn(l,k,finishfn);
        else
            [l,ia]=sort(l);
            k=k(ia);
            start=nonconsecfn(k,l,startfn);
            finish=nonconsecfn(k,l,finishfn);
        end








        kstart=k(start);
        kfinish=k(finish);
        lstart=l(start);
        lfinish=l(finish);








        if(d==1)
            lstart=lstart-1;
        else
            kstart=kstart-1;
        end


        N=length(kstart);
        Ld=gobjects(N,1);
        for i=1:N




            x=[lstart(i),lfinish(i)]-0.5;
            y=[kstart(i),kfinish(i)]-0.5;
            Ld(i)=line(ax,x,y);

        end


        set(Ld,'color',c);
        set(Ld,'LineWidth',1.25);
        tag='wirelessWaveformGenerator.internal.plotBoundingBoxes';
        set(Ld,'Tag',tag);


        L=[L;Ld];%#ok<AGROW>

    end

end
