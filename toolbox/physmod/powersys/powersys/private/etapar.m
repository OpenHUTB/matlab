function[rlc,liste_neu,ind_neu,ind_neusrc,ind_neusw,mat_tr,unit,rlccar]=...
    etapar(rlc,switches,source,nb_sortie,neuref_auto,unit_auto,...
    power2sys_flag,fid,rlcnames,srcnames)







































































    Erreur.identifier='SpecializedPowerSystems:Compiler:StateSpace';

    if~isempty(srcnames)
        srcnames=char(srcnames);
    end

    if nargin==8
        rlcnames=[];
        srcnames=[];
    end

    [nbr,nbcol]=size(rlc);
    if nbcol==10,rlc=rlc(:,1:8);nbcol=8;end
    if nbcol==7,rlc=[rlc,zeros(nbr,1)];nbcol=8;end
    if nbcol~=0&&nbcol~=6&&nbcol~=8,
        str=sprintf('Incorrect dimensions for [rlc] :%gx%g;',nbr,nbcol);
        Erreur.message=[str,sprintf(' Expected dimensions:  %gx6 ou %gx7',nbr,nbr)];
        psberror(Erreur)
    end
    if nbcol==6,



        rlc(1,8)=0;
    end

    nbr_mut=0;
    nbr_ligne=0;
    ntr=0;mat_tr=[];

    nbneu=0;liste_neu=[];
    if nbr,liste_neu(1)=rlc(1,1);nbneu=1;end

    for ib=1:nbr,

        if~any(liste_neu==rlc(ib,1)),nbneu=nbneu+1;liste_neu(nbneu)=rlc(ib,1);end
        if~any(liste_neu==rlc(ib,2)),nbneu=nbneu+1;liste_neu(nbneu)=rlc(ib,2);end

        if nbcol==6,rlc(ib,7)=ib;end
        if rlc(ib,8)>0,nbr_mut=nbr_mut+1;end
        if rlc(ib,3)<0,nbr_ligne=nbr_ligne+1;end
        if rlc(ib,3)<=0&&all(rlc(ib,4:6)==0)




















            flagError=0;



            idx1=find(rlc(:,3)==4);

            if~isempty(idx1)








                idx2=[idx1(2:end);0];
                idxDiff=idx2-idx1;
                idx3=find(idxDiff~=1);



                idxMutEnd=idx1(idx3);
                nbMutuals=length(idxMutEnd);
                idxMutStart=idx1([1;idx3(1:end-1)+1]);
                nbWindings=(idxMutEnd-idxMutStart)+1;









                nbCouplingRows=(nbWindings.^2-nbWindings)/2;
                idxRowsToIgnore=[];
                for k=1:nbMutuals
                    idxRowsToIgnore=[idxRowsToIgnore,idxMutEnd(k)+1:idxMutEnd(k)+nbCouplingRows(k)];
                end



                if~any(idxRowsToIgnore==ib)
                    flagError=1;
                end
            else

                flagError=1;
            end

            if flagError
                Erreur.message=sprintf('Series branch %g located between nodes %g and %g has a zero impedance',ib,rlc(ib,1),rlc(ib,2));
                psberror(Erreur);
            end

        end
        if rlc(ib,3)==1&&rlc(ib,5)==inf;rlc(ib,5)=0;end
        if rlc(ib,3)==0&&rlc(ib,6)==inf&&strcmp(unit_auto,'OMU')%#ok
            rlc(ib,6)=0;
        end
    end
    nbr_prop=nbr-nbr_mut;

    if nbcol==8,






        [y,i]=sort(rlc(1:nbr_prop,7));rlc(1:nbr_prop,:)=rlc(i,:);

    end












    ib=0;
    nxfo=0;nmut=0;
    while ib<nbr,
        ib=ib+1;
        if rlc(ib,3)==2||rlc(ib,3)==3,
            ntr=ntr+1;n=0;
            mat_tr(ntr,1:3)=[ib,0,0];
            ib1=ib;
            if rlc(ib1,3)==2,
                nxfo=nxfo+1;
            elseif rlc(ib1,3)==3,
                nmut=nmut+1;
            end

            while rlc(ib,3)==rlc(ib1,3)&&ib<nbr,
                if rlc(ib,3)==2&&rlc(ib,6)<=0,
                    Erreur.message=sprintf(['Transformer no. %g: nominal voltage',...
                    ' of winding %g (branch %g) must be positive'],...
                    nxfo,n,ib);
                    psberror(Erreur);
                end
                if rlc(ib,3)==3&&rlc(ib,6)~=0,
                    Erreur.message=sprintf(['Mutual no. %g: the content of',...
' column 6 of [rlc] matrix must be zero'...
                    ,'for winding %g (branch %g) '],nmut,n,ib);
                    psberror(Erreur);
                end
                n=n+1;


                if rlc(ib,3)==2,
                    mat_tr(ntr,3*n+1:3*n+3)=[rlc(ib,2),rlc(ib,4),rlc(ib,6)];
                elseif rlc(ib,3)==3,

                    mat_tr(ntr,3*n+1:3*n+3)=[rlc(ib,2),rlc(ib,4),1];
                end
                ib=ib+1;
            end



            if~(rlc(ib,2)==rlc(ib-n,2)&&...
                ((rlc(ib1,3)==3&&rlc(ib,3)==0)||(rlc(ib1,3)==2&&rlc(ib,3)==1))),

            else
                if(rlc(ib,3)==1&&(rlc(ib,4)<=0||isinf(rlc(ib,4)))),
                    if power2sys_flag~=1
                        Erreur.message=sprintf(['Transformer no. %g: the parallel ',...
                        'resistance of the magnetisation branch (branch %g) ',...
                        'must be positive and finite'],nxfo,ib);
                        psberror(Erreur);
                    end
                end
                if rlc(ib,3)==0&&rlc(ib,5)==0
                    if power2sys_flag~=1
                        Erreur.message=sprinf(['Mutual no. %g: the mutual inductance',...
                        ' (branch %g) cannot be zero'],nmut,ib);
                        psberror(Erreur);
                    end
                end
                mat_tr(ntr,2)=n;
                mat_tr(ntr,3)=rlc(ib,1);
            end



            for i=1:n,
                if rlc(ib1,3)==2,
                    if rlc(ib1+i-1,4)<=0,
                        if power2sys_flag~=1
                            Erreur.message=sprintf(['Transformer no. %g: ',...
                            'the resistance of winding %g (branch %g) ',...
                            'must be positive'],nxfo,i,ib1+i-1);
                            psberror(Erreur);
                        end
                    end
                elseif rlc(ib1,3)==3,
                    if(rlc(ib1+i-1,4)-rlc(ib,4))<0,
                        if power2sys_flag~=1
                            Erreur.message=sprintf(['Mutual no. %g: the resistance',...
                            ' Rself-Rmut of winding %g (branches %g and %g)',...
                            ' must be positive or null'],nmut,i,ib1+i-1,ib);
                            psberror(Erreur);
                        end
                    end
                end
            end
        end
    end

    nbr_add=0;
    if nbr_ligne>0,
        if neuref_auto>=0,
            neu_ref=neuref_auto;
            if fid>0
                fprintf(fid,'Reference node number for transmission lines : %g\n',neu_ref);
            end
        else
            neu_ref=input...
            ('Reference node number (ground) for transmission lines : ');
            if~any(liste_neu==neu_ref)&&fid>0
                fprintf(fid,'Node %g does not exist; it will be added to the list of nodes\n',neu_ref);
            end
        end
        if~any(liste_neu==neu_ref),nbneu=nbneu+1;liste_neu(nbneu)=neu_ref;end



        n=find(liste_neu~=neu_ref);
        n1=find(liste_neu==neu_ref);
        liste_neu=[liste_neu(n),liste_neu(n1)];






        rlc(nbr,10)=0;
        rlc_add=zeros(1,10);
        nbr1=nbr;
        for ib=1:nbr1,
            if rlc(ib,3)<0,
                for ineu=1:2,
                    itrouve=0;
                    neu1=rlc(ib,ineu);
                    ibr=nbr1;
                    while~itrouve&&ibr<nbr,
                        ibr=ibr+1;
                        if((rlc(ibr,1)==neu_ref&&rlc(ibr,2)==neu1)||...
                            (rlc(ibr,2)==neu_ref&&rlc(ibr,1)==neu1))&&rlc(ibr,3)==1,


                            rlc(ib,8+ineu)=ibr;
                            itrouve=1;
                        end
                    end
                    if~itrouve,

                        rlc_add(1,1)=neu1;
                        rlc_add(1,2)=neu_ref;
                        rlc_add(1,3)=1;

                        rlc_add(1,7)=nbr_prop+1;
                        rlc=[rlc(1:nbr_prop,:);rlc_add;rlc(nbr_prop+1:nbr,:)];
                        nbr_prop=nbr_prop+1;
                        nbr=nbr+1;
                        rlc(ib,8+ineu)=nbr_prop;
                        nbr_add=nbr_add+1;
                    end
                end
            end
        end
    end

    if unit_auto(1)~='%',
        unit=unit_auto;
        if fid>0
            fprintf(fid,['Unit specified : ',unit,'\n']);
        end
    else
        if fid>0
            fprintf(fid,'Allowed units are: OHM or OMU (Ohms mH uF)\n');
        end
        if~exist('zcal_auto'),unit='   ';end
        while(~all(unit=='OHM')&&~all(unit=='P.U')&&~all(unit=='OMU')),
            unit=input('Specify units for R L C branches (OHM or OMU):','s');
            dimu=size(unit);
            if dimu(2)==2,
                if all(unit=='PU'),unit='P.U';else unit='   ';end
                dimu=size(unit);
            end
            if dimu(2)~=3,unit='   ';end
        end
    end

    if~isempty(rlc)&&fid>0
        fprintf(fid,'\nrlc matrix:\n\n');
    end
    unit1=['(',unit,')'];

    if nbr_ligne>0,
        rlccar1(1,:)='Node_1 Node_2 Type/L(km)';
    else
        rlccar1(1,:)='Node_1 Node_2 Type      ';
    end
    rlccar2(1,:)='R(ohms)     ';
    if all(unit=='OHM'),
        rlccar3(1,:)='Xl(ohms)    ';
        rlccar4(1,:)='Xc(ohms)    ';
    elseif all(unit=='P.U'),
        rlccar2(1,:)='R(pu)       ';
        rlccar3(1,:)='Xl(pu)      ';
        rlccar4(1,:)='Xc(pu)      ';
    else
        rlccar3(1,:)='L(mH)       ';
        rlccar4(1,:)='C(uF)/U(V)  ';
    end

    rlccar5(1,:)='Branch#  ';
    if~isempty(rlcnames)
        rlccar6(1,:)='Block name';
        str=[rlccar1(1,:),rlccar2(1,:),rlccar3(1,:),rlccar4(1,:),...
        rlccar5(1,:),rlccar6(1,:),'\n'];
    else
        str=[rlccar1(1,:),rlccar2(1,:),rlccar3(1,:),rlccar4(1,:),...
        rlccar5(1,:),'\n'];
    end

    if~isempty(rlc)&&fid>0
        fprintf(fid,str);
        if~isempty(rlcnames)
            fprintf(fid,'------------------------------------------------------------------------------------\n');
        else
            fprintf(fid,'-------------------------------------------------------------------\n');
        end
    end

    for ib=1:nbr,
        if rlc(ib,3)==0,
            conex='S         ';
        elseif rlc(ib,3)==1,
            conex='P         ';
        elseif rlc(ib,3)<0,
            conex=sprintf('Li %6.1f ',-rlc(ib,3));
        elseif rlc(ib,3)==2,
            conex='Tr        ';
        elseif rlc(ib,3)==3,
            conex='Mut       ';
        elseif rlc(ib,3)==4,
            conex='Mut       ';
        end

        str=sprintf('%-6g %-6g ',rlc(ib,1),rlc(ib,2));
        str=[str,conex];
        rlccar1(ib+1,:)=str;
        str=sprintf('%-6.4g      ',rlc(ib,4));
        rlccar2(ib+1,:)=str(1:12);
        str=sprintf('%-6.4g      ',rlc(ib,5));
        rlccar3(ib+1,:)=str(1:12);
        str=sprintf('%-6.4g      ',rlc(ib,6));
        rlccar4(ib+1,:)=str(1:12);
        str=sprintf('%-6g      ',rlc(ib,7));
        rlccar5(ib+1,:)=str(1:9);
        if~isempty(rlcnames)
            if ib<=size(rlcnames,1)
                blockname=char(rlcnames(ib,:));
            else
                blockname=' ';
            end

            rlccar6=strvcat(rlccar6,blockname);
            str=[rlccar1(ib+1,:),rlccar2(ib+1,:),rlccar3(ib+1,:),...
            rlccar4(ib+1,:),rlccar5(ib+1,:),rlccar6(ib+1,:),'\n'];
        else
            str=[rlccar1(ib+1,:),rlccar2(ib+1,:),rlccar3(ib+1,:),...
            rlccar4(ib+1,:),rlccar5(ib+1,:),'\n'];
        end

        str=strrep(str,'%','%%');
        if fid>0
            fprintf(fid,str);
        end
    end
    rlccar=[rlccar1,rlccar2,rlccar3,rlccar4];



    for ib=1:nbr_prop,
        if ib~=rlc(ib,7),
            str=sprintf(...
            'Numbering of the %g branches is incorrect; Branch %g  not specified',...
            nbr_prop,ib);
            Erreur.message=str;
            psberror(Erreur);
        end
    end





    ind_neu=[];
    for ib=1:nbr,
        index=1;
        while rlc(ib,1)~=liste_neu(index),index=index+1;end
        ind_neu(ib,1)=index;
        index=1;
        while rlc(ib,2)~=liste_neu(index),index=index+1;end
        ind_neu(ib,2)=index;
    end

    if fid>0
        fprintf(fid,'\nNumber of nodes: %g\n',nbneu);
        fprintf(fid,'Number of branches: %g\n',nbr_prop);
        if nbr_ligne>0,
            fprintf(fid,'Number of lines: %g\n',nbr_ligne);
            fprintf(fid,'Number of shunt branches added: %g\n',nbr_add);
        end
        fprintf(fid,'Number of transformers: %g\n',nxfo);
        fprintf(fid,'Number of mutuals (inductive coupling): %g\n',nmut);
    end



    nbr_src=0;nbr_srcU=0;nbr_srcI=0;
    ind_neusrc=[];
    if exist('source')&&~isempty(source),
        [nbr_src,n]=size(source);
        if n~=3&&n~=5&&n~=6&&n~=7,
            str=sprintf(...
            'Dimensions of matrix [source] are incorrect :%gx%g;',...
            nbr_src,n);
            str=[str,sprintf(...
            ' Expected dimensions: %gx3 or %gx5 or %gx6 or %gx7',...
            nbr_src,nbr_src)];
            Erreur.message=str;
            psberror(Erreur);
        end

        for ib=1:nbr_src,

            i1=[];if length(liste_neu)>0,i1=find(liste_neu==source(ib,1));end
            if isempty(i1),
                liste_neu=[liste_neu,source(ib,1)];
                nbneu=nbneu+1;
                i1=nbneu;
            end
            ind_neusrc(ib,1)=i1;
            i2=find(liste_neu==source(ib,2));
            if isempty(i2),
                liste_neu=[liste_neu,source(ib,2)];
                nbneu=nbneu+1;
                i2=nbneu;
            end
            ind_neusrc(ib,2)=i2;

            if source(ib,3)==0,nbr_srcU=nbr_srcU+1;
            elseif source(ib,3)==1,nbr_srcI=nbr_srcI+1;
            else,
                str=sprintf...
                ('Source type : %g between nodes %g and %g is not valid\n',...
                source(ib,3),source(ib,1),source(ib,2));
                psberror(Erreur);
            end
        end
        if fid>0
            fprintf(fid,'Number of voltage sources: %g\n',nbr_srcU);
            fprintf(fid,'Number of current sources: %g\n',nbr_srcI);
        end
    end



    ind_neusw=[];
    if exist('switches')
        [nsw,n]=size(switches);
        if n~=7&&nsw~=0,
            str=sprintf('Dimensions of matrix [switches] are not correct :%gx%g;',...
            nsw,n);
            str=[str,sprintf(' Expected dimensions: %gx7',nsw)];
            Erreur.message=str;
            psberror(Erreur);
        end

        for ib=1:nsw,

            i1=find(liste_neu==switches(ib,1));
            if~isempty(i1),
                ind_neusw(ib,1)=i1;
            else
                Erreur.message=sprintf(...
                'Switch connected between nodes %g and %g; Node %g is not valid\n',...
                switches(ib,1),switches(ib,2),switches(ib,1));
                psberror(Erreur)
            end
            i2=find(liste_neu==switches(ib,2));
            if~isempty(i2),
                ind_neusw(ib,2)=i2;
            else
                Erreur.message=sprintf(...
                'Switch connected between nodes %g and %g; Node %g is not valid\n',...
                switches(ib,1),switches(ib,2),switches(ib,2));
                psberror(Erreur);
            end

            if switches(ib,3)~=0&&switches(ib,3)~=1,
                str=sprintf...
                ('Status (%g) of switches %g is not valid 0 or 1 expected 1)\n',...
                switches(ib,3),ib);
                Erreur.message=str;
                psberror(Erreur);
            end

            flag=0;
            if switches(ib,6)<=nbr_src,
                if source(switches(ib,6),3)~=1,flag=1;end
            else,
                flag=1;
            end
            if flag,
                str=sprintf(...
                'Invalid current source number (col. 6) for switch %g\n',ib);
                Erreur.message=str;
                psberror(Erreur);
            end

            if switches(ib,7)>nb_sortie,
                str=sprintf(...
                'Invalid output number (col. 7) for switch %g\n',ib);
                Erreur.message=str;
                psberror(Erreur);
            end
        end
        if fid>0
            fprintf(fid,'Number of switches: %g\n',nsw);
        end
    end



    if fid>0
        fprintf(fid,'\n');
        if nbr_src,
            fprintf(fid,'Source matrix:\n\n');
            [nbr_src,n]=size(source);
            switch n
            case 5
                fprintf(fid,'Node1 Node2 U/I  Mag.     Phase  \n');
                fprintf(fid,'           (0/1) (V/A)  (degrees)\n');
                fprintf(fid,'---------------------------------\n');
            case 6
                fprintf(fid,'Node1 Node2 U/I  Mag.     Phase    Frequency\n');
                fprintf(fid,'           (0/1) (V/A)  (degrees)     (Hz)\n');
                fprintf(fid,'-------------------------------------------------\n');
            case 7
                fprintf(fid,'Node1 Node2 U/I  Mag.     Phase    Frequency Type   Block name\n');
                fprintf(fid,'           (0/1) (V/A)  (degrees)     (Hz)\n');
                fprintf(fid,'--------------------------------------------------------------\n');
            end

            for i=1:nbr_src,
                switch n
                case 5
                    if~isempty(srcnames)
                        fprintf(fid,'%-5g %-5g %-4g %-8g %-8g %s\n',...
                        source(i,1),source(i,2),source(i,3),source(i,4),...
                        source(i,5),srcnames(i,:));
                    else
                        fprintf(fid,'%-5g %-5g %-4g %-8g %-8g \n',...
                        source(i,1),source(i,2),source(i,3),source(i,4),...
                        source(i,5));
                    end
                case 6
                    if~isempty(srcnames)
                        fprintf(fid,'%-5g %-5g %-4g %-8g %-8g %-8g %s\n',...
                        source(i,1),source(i,2),source(i,3),source(i,4),...
                        source(i,5),source(i,6),srcnames(i,:));
                    else
                        fprintf(fid,'%-5g %-5g %-4g %-8g %-8g %-8g \n',...
                        source(i,1),source(i,2),source(i,3),source(i,4),...
                        source(i,5),source(i,6));
                    end
                case 7
                    if~isempty(srcnames)
                        fprintf(fid,'%-5g %-5g %-4g %-8g %-8g %-8g  %-2g     %s\n',...
                        source(i,1),source(i,2),source(i,3),source(i,4),...
                        source(i,5),source(i,6),source(i,7),srcnames(i,3:end));
                    else
                        fprintf(fid,'%-5g %-5g %-4g %-8g %-8g %-8g  %-2g\n',...
                        source(i,1),source(i,2),source(i,3),source(i,4),...
                        source(i,5),source(i,6),source(i,7));
                    end
                end
            end
        end

        fprintf(fid,'\n');
        if nsw,
            fprintf(fid,'Switch matrix:\n\n');
            [nsw,n]=size(switches);
            fprintf(fid,'Node1 Node2 0/1  R.       L.       I#  U#  Switch type\n');
            fprintf(fid,'------------------------------------------------------\n');
            for i=1:nsw
                strdesc='';
                [nbr_src,n]=size(source);
                if n==7,
                    switch source(switches(i,6),7)
                    case 1
                        strdesc='Ideal Switch';
                    case 11
                        strdesc='MOSFET';
                    case 10
                        strdesc='GTO';
                    case{3,7}
                        strdesc='Diode';
                    case{4,5,8,9}
                        strdesc='Thyristor';
                    case 2
                        strdesc='Breaker';
                    otherwise
                        strdesc=' ';
                    end
                end

                fprintf(fid,'%-5g %-5g %-4g %-8g %-8g %-3g %-3g %s\n',...
                switches(i,1),switches(i,2),switches(i,3),switches(i,4),...
                switches(i,5),switches(i,6),switches(i,7),strdesc);
            end
        end
        fprintf(fid,'\n');
    end
