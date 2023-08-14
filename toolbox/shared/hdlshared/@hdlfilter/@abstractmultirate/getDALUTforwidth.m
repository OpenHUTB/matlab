function dalutm=getDALUTforwidth(this,width)






    fl=this.getfilterlengths;
    phases=size(fl.effective_polycoeffs,1);
    ncoeffs=zeros(1,phases);
    for ii=1:phases
        ncoeffs(ii)=length(find(fl.effective_polycoeffs(ii,:)));
    end

    dalut=cell(phases,1);
    for ph=1:phases
        taps=ncoeffs(ph);

        nwidth=floor(taps/width);
        if mod(taps,width)~=0
            dalut{ph}=[ones(1,nwidth)*width,rem(taps,width)];
        else
            dalut{ph}=ones(1,nwidth)*width;
        end
    end

    maxlen=0;
    for ph=1:phases
        maxlen=max(length(dalut{ph}),maxlen);
    end
    dalutm=zeros(phases,maxlen);
    for ph=1:phases
        dalutm(ph,:)=[dalut{ph},zeros(1,maxlen-length(dalut{ph}))];
    end