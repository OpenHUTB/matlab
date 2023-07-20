function generateSPICEcore(A,B,C,D,filename,varargin)





    if nargin==6
        Zref=varargin{1};
    else
        Zref=50;
    end

    ns=size(A,1);
    assert(ns==size(A,2))
    np=size(D,1);
    assert(np==size(D,2))




    maxabsC=max(abs(C),[],1);

    maxabsC(maxabsC==0)=1;
    Tidiag=1./maxabsC.';
    Ti=spdiags(Tidiag,0,length(Tidiag),length(Tidiag));
    T=spdiags(1./Tidiag,0,length(Tidiag),length(Tidiag));

    TiA=T/A;
    Ais=TiA*Ti;
    Bs=TiA*B;
    Cs=C*Ti;

    if isempty(filename)
        fp=1;
    else
        [fp,errmsg]=fopen(filename,'wt');
        if fp==-1
            error(errmsg)
        end
    end

    fprintf(fp,'* Equivalent circuit model for %s\n',filename);

    [~,name,~]=fileparts(filename);
    fprintf(fp,'.SUBCKT %s',name);
    for i=1:np
        fprintf(fp,' po%d',i);
    end
    fprintf(fp,'\n');

    for i=1:np


        fprintf(fp,'Vsp%d po%d p%d 0\n',i,i,i);
        fprintf(fp,'Vsr%d p%d pr%d 0\n',i,i,i);
        fprintf(fp,'Rp%d pr%d 0 %.15g\n',i,i,Zref);
        fprintf(fp,'Ru%d u%d 0 %.15g\n',i,i,Zref);
        fprintf(fp,'Fr%d u%d 0 Vsr%d -1\n',i,i,i);
        fprintf(fp,'Fu%d u%d 0 Vsp%d -1\n',i,i,i);



        fprintf(fp,'Ry%d y%d 0 1\n',i,i);
        fprintf(fp,'Gy%d p%d 0 y%d 0 %.15g\n',i,i,i,-1/Zref);
    end


    [Aix,Ajx,Avx]=find(Ais);
    for i=1:ns
        fprintf(fp,'Rx%d x%d 0 1\n',i,i);
        ix=find(Aix==i,2);
        nix=length(ix);
        for k=1:nix
            ixk=ix(k);
            j=Ajx(ixk);
            if i==j
                Amdiag=-Avx(ixk);
            else
                fprintf(fp,'Fxc%d_%d x%d 0 Vx%d %.15g\n',...
                i,j,i,j,Avx(ixk)/Ais(j,j));
            end
        end
        if nix>1
            fprintf(fp,'Cx%d x%d xm%d %.15g\n',i,i,i,Amdiag);
            fprintf(fp,'Vx%d xm%d 0 0\n',i,i);
        else
            fprintf(fp,'Cx%d x%d 0 %.15g\n',i,i,Amdiag);
        end
        for jb=1:np
            btemp=full(Bs(i,jb));
            if btemp~=0
                fprintf(fp,'Gx%d_%d x%d 0 u%d 0 %.15g\n',i,jb,i,jb,btemp);
            end
        end
    end


    for i=1:np
        for j=1:ns
            if Cs(i,j)~=0
                fprintf(fp,'Gyc%d_%d y%d 0 x%d 0 %.15g\n',i,j,i,j,-Cs(i,j));
            end
        end
        for j=1:np
            if D(i,j)~=0
                fprintf(fp,'Gyd%d_%d y%d 0 u%d 0 %.15g\n',i,j,i,j,-D(i,j));
            end
        end
    end

    fprintf(fp,'.ENDS\n');

    if~isempty(filename)
        fclose(fp);
    end
