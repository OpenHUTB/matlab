function[expr_c,expr_d,vec_c,vec_d,vec_u]=etacd(chaine,sortie,rlcm,rlc1,...
    source,var_nom,var_branche,nbvar1,liste_neu,L_combi,C_combi,Il_relat,...
    Uc_relat,nb_ldep,nb_cdep,c_ligne,debug_etat)






























































    Erreur.identifier='SpecializedPowerSystems:Compiler:StateSpace';

    [nbr,n]=size(rlcm);
    [nbr_src,n]=size(source);
    [nbvar,n]=size(var_nom);
    nb_lcombi=length(L_combi);
    nb_ccombi=length(C_combi);
    nbneu=length(liste_neu);
    vec_c=zeros(nbvar,nbvar1);
    vec_d=zeros(nbvar,nbr_src);
    vec_u=zeros(nbr_src,nbr_src);

    clear var_index var_type var_neu;
    long_chaine=length(chaine);





    i=0;n=0;
    while i<long_chaine-3,
        i=i+1;
        if strcmp(chaine(i:i+2),'I_b'),

            i1=i;
            i=i+3;
            str1=[];
            while i<=long_chaine&(chaine(i)>='0'&chaine(i)<='9'),
                str1=[str1,chaine(i)];
                i=i+1;
                if i>long_chaine,
                    break;
                end
            end
            i2=i;
            ib=str2num(str1);


            if~any(rlcm(ib,3:size(rlcm,2)))

                Erreur.message=['It is not possible to output mutual inductance magnetizing ',...
                'branch current (output request ''',deblank(chaine),''').'];
                psberror(Erreur);

            end

            if ib<=0|ib>nbr,
                Erreur.message=sprintf('Branch %g does not exist!',ib);
                psberror(Erreur);
            end

            neu1=rlcm(ib,1);neu2=rlcm(ib,2);
            n=n+1;
            str='(';



            if rlcm(ib,3)<0,
                if i+2>long_chaine,
                    Erreur.message=sprintf('Line current (branch %g); expected format : I_b%g_nxx',ib,ib);
                    psberror(Erreur);
                end
                if strcmp(chaine(i:i+1),'_n'),
                    i=i+2;
                    str1=[];
                    while i<=long_chaine&((chaine(i)>='0'&chaine(i)<='9')|...
                        chaine(i)=='.'),
                        str1=[str1,chaine(i)];
                        i=i+1;
                        if i>long_chaine,
                            break;
                        end
                    end
                    i2=i;
                    neu1=str2num(str1);
                    if rlcm(ib,1)==neu1,
                        str_signe='+';
                        ib1=rlcm(ib,9);
                    elseif rlcm(ib,2)==neu1;
                        str_signe='-';
                        ib1=rlcm(ib,10);
                    else
                        Erreur.message=sprintf('Line current I_b%g_n%g : branch %g is not connected to node %g',ib,neu1,ib,neu1);
                        psberror(Erreur);
                    end
                    str=[str,'+','Il_b',num2str(ib),str_signe,sprintf('%.8g',c_ligne(ib)),'*dUc_b',num2str(ib1)];
                else
                    Erreur.message=sprintf('Line current (branch %g); expected format: I_b%g_nxx',ib,ib);
                    psberror(Erreur);
                end



            elseif rlcm(ib,3)==0,


                if rlc1(ib,2)==0&rlc1(ib,3)==0,
                    str=[str,'U_n',num2str(neu1),'_',num2str(neu2),'/',...
                    sprintf('%.8g',rlc1(ib,1))];


                elseif rlc1(ib,2)~=0,
                    str=[str,'Il_b',num2str(ib)];


                else,
                    str=[str,sprintf('%.8g',rlc1(ib,3)),'*dUc_b',num2str(ib)];
                end



            else,
                if rlc1(ib,1)~=0,
                    str=[str,'U_n',num2str(neu1),'_',num2str(neu2),'/',...
                    sprintf('%.8g',rlc1(ib,1))];
                end

                if rlc1(ib,2)~=0,str=[str,'+','Il_b',num2str(ib)];end

                if rlc1(ib,3)~=0,
                    str=[str,'+',sprintf('%.8g',rlc1(ib,3)),'*dUc_b',num2str(ib)];
                end
            end

            str=[str,')'];
            chaine=[chaine(1:i1-1),str,chaine(i2:length(chaine))];
            i=i+length(str)-(i2-i1);
            long_chaine=length(chaine);
        end
    end

    if n>0&debug_etat,
        disp(sprintf([sortie,'=',chaine,'\n']));
    end

    nvary=0;i=0;
    str='  ';
    while i<long_chaine-1,


        i=i+1;
        str=chaine(i:i+1);
        if strcmp(str,'Il')|strcmp(str,'Uc')|...
            ((str(1)=='U'|str(1)=='I')&(str(2)>='0'&str(2)<='9')|...
            strcmp(str,'U_')),
            nvary=nvary+1;
            var_index(nvary,1)=i;
            var_type(nvary)=0;
            if i>1,
                if chaine(i-1)=='d',var_type(nvary)=-1;end
            end

            if str(2)~='c'&str(2)~='l'&str(2)~='_',


                i=i+1;
                i1=i;
                while i~=long_chaine&(chaine(i)>='0'&chaine(i)<='9'),
                    i=i+1;
                end
                if i==long_chaine&(chaine(i)>='0'&chaine(i)<='9'),
                    i2=i;
                else
                    i2=i-1;
                end
                var_type(nvary)=eval(chaine(i1:i2));
                var_index(nvary,2)=i2;

            elseif str(2)=='c'|str(2)=='l',


                while i~=long_chaine-1&~strcmp(str,'_b'),
                    i=i+1;
                    str=chaine(i:i+1);
                end
                if str~='_b',
                    Erreur.message=['Format error in the string :',chaine(var_index(nvary,1):i),'...'];
                    psberror(Erreur);

                end
                i=i+2;
                while i~=long_chaine&((chaine(i)>='0'&chaine(i)<='9')...
                    |chaine(i)=='_'|chaine(i)=='n'),
                    i=i+1;
                end
                if i==long_chaine&(chaine(i)>='0'&chaine(i)<='9'),
                    var_index(nvary,2)=i;
                else
                    var_index(nvary,2)=i-1;
                end

            else,


                if strcmp(chaine(i:i+2),'U_n'),

                    i=i+3;
                    str1=[];str2=[];
                    while i<=long_chaine&((chaine(i)>='0'&chaine(i)<='9')|...
                        chaine(i)=='.'),
                        str1=[str1,chaine(i)];
                        i=i+1;
                    end
                    i=i+1;
                    while i<=long_chaine&((chaine(i)>='0'&chaine(i)<='9')|...
                        chaine(i)=='.'),
                        str2=[str2,chaine(i)];
                        i=i+1;
                        if i>long_chaine,
                            break;
                        end
                    end

                    var_neu(nvary,1)=str2num(str1);
                    var_neu(nvary,2)=str2num(str2);
                    var_index(nvary,2)=i-1;
                else
                    Erreur.message=['Format error in the string:',chaine(i:i+2),'...'];
                    psberror(Erreur);

                end
            end
        end
    end




    expr_c=[];expr_d=[];
    i=1;
    for ivary=1:nvary,
        i1=var_index(ivary,1);i2=var_index(ivary,2);
        var_existe=0;
        str=chaine(i1:i2);
        ncar=length(str);


        n=find(str=='_');if length(n)==3,ncar=n(2)-1;end

        if var_type(ivary)>0,


            isrc=var_type(ivary);
            if isrc>nbr_src
                Erreur.message=['Source named ',str,' does not exist!'];
                psberror(Erreur);

            end
            if(source(isrc,3)==0&chaine(i1)~='U')|...
                (source(isrc,3)==1&chaine(i1)~='I'),
                Erreur.message=['Source named ',str,' does not exist!'];
                psberror(Erreur);

            end
            eval(['vec_u(',int2str(isrc),',',int2str(isrc),')=1;'])
            str2=['vec_u(',int2str(isrc),',:)'];
            i3=i1-1;
            expr_c=[expr_c,chaine(i:i3),'vec_c0'];
            expr_d=[expr_d,chaine(i:i3),str2];



        elseif var_type(ivary)==0&strcmp(str(1:3),'U_n'),

            neu1=var_neu(ivary,1);
            neu2=var_neu(ivary,2);

            str1='(';str2='(';
            ineu=find(liste_neu==neu1);
            if isempty(ineu)
                [idx1,scrap]=find(rlcm(:,1:2)==neu1);
                if~any(rlcm(idx1,3:end))
                    Erreur.message=['It is not possible to output voltage related to mutual '...
                    ,'inductance magnetizing branch (output request ''',...
                    deblank(chaine),''').'];
                    psberror(Erreur);

                else
                    Erreur.message='Connection error: A Voltage Measurement block has one input terminal not connected';
                    psberror(Erreur);
                end
            end
            if ineu<nbneu,
                if nbvar1>0,
                    str1=[str1,'Cvn(',num2str(ineu),',:)'];
                end
                str2=[str2,'Dvn(',int2str(ineu),',:)'];
            end

            ineu=find(liste_neu==neu2);
            if isempty(ineu)
                [idx1,scrap]=find(rlcm(:,1:2)==neu2);
                if~any(rlcm(idx1,3:end))
                    Erreur.message=['It is not possible to output voltage related to mutual '...
                    ,'inductance magnetizing branch (output request ''',...
                    deblank(chaine),''').'];
                    psberror(Erreur);

                else
                    Erreur.message='Connection error: A Voltage Measurement block has one input terminal not connected';
                    psberror(Erreur);

                end
            end
            if ineu<nbneu,
                if nbvar1>0,
                    str1=[str1,'-Cvn(',num2str(ineu),',:)'];
                end
                str2=[str2,'-Dvn(',int2str(ineu),',:)'];
            end


            if neu1==neu2,
                str1=['(vec_c0'];
                str2=['(vec_d0'];
            end

            str1=[str1,')'];str2=[str2,')'];
            i3=i1-1;
            expr_c=[expr_c,chaine(i:i3),str1];
            expr_d=[expr_d,chaine(i:i3),str2];

        else




            if strcmp(str(1:4),'Il_b')
                temp=strrep(str,'Il_b','');
                branchNum=str2num(strtok(strrep(temp,'_',' ')));
                if~any(rlcm(branchNum,3:size(rlcm,2)))

                    Erreur.message=['It is not possible to output mutual inductance magnetizing ',...
                    'branch current (output request ''',deblank(chaine),''').'];
                    psberror(Erreur);

                end
            end

            for ivar=1:nbvar
                if strcmp(str(1:ncar),var_nom(ivar,1:ncar))&...
                    var_nom(ivar,ncar+1)=='_',
                    if var_branche(ivar,2)~=0,

                        ib1=var_branche(ivar,2);
                        if var_nom(ivar,1)=='I',
                            nobr=-L_combi.*sign(Il_relat(ib1,:));
                            n=find(nobr(1:nb_lcombi-nb_ldep)~=0);nobr=nobr(n);
                            if length(find(Il_relat(ib1,:)~=0))==1,
                                n=[];nobr=[];novar=[];
                            end
                        else,
                            nobr=-C_combi.*sign(Uc_relat(ib1,:));
                            n=find(nobr(1:nb_ccombi-nb_cdep)~=0);nobr=nobr(n);
                        end
                        str_signe=[];novar=[];
                        for ib=1:length(nobr),
                            ib1=abs(nobr(ib));
                            novar(ib)=find(var_branche(:,1)==abs(ib1)&...
                            var_nom(:,1)==var_nom(ivar,1));
                            if sign(nobr(ib))>0,
                                str_signe(ib)='+';
                            else
                                str_signe(ib)='-';
                            end
                        end
                    else,
                        novar=ivar;
                        str_signe=' ';
                        nobr=+1;
                    end


                    if var_type(ivary)==-1,
                        i3=i1-2;
                        str1='(';str2='(';
                        if isempty(novar),
                            str1=[str1,'vec_c0'];
                            str2=[str2,'vec_d0'];
                        end
                        for n=1:length(novar),
                            str1=[str1,str_signe(n),'A(',int2str(novar(n)),',:)'];
                            str2=[str2,str_signe(n),'B(',int2str(novar(n)),',:)'];
                        end
                        str1=[str1,')'];str2=[str2,')'];


                    else,


                        i3=i1-1;
                        vecc=zeros(1,nbvar1);
                        for n=1:length(novar),
                            vecc(novar(n))=sign(nobr(n));
                            vecd(novar(n))=sign(nobr(n));
                        end
                        eval(['vec_c(',int2str(ivar),',:)=vecc;']);
                        str1=['vec_c(',int2str(ivar),',:)'];
                        if nbr_src,
                            eval(['vec_d(',int2str(ivar),',:)=zeros(1,nbr_src);']);
                            str2=['vec_d(',int2str(ivar),',:)'];
                        else
                            str2='';
                        end
                    end

                    expr_c=[expr_c,chaine(i:i3),str1];
                    expr_d=[expr_d,chaine(i:i3),str2];
                    var_existe=1;
                end
            end
            if~var_existe,
                Erreur.message=['Expression: ',chaine,'; Variable ',str,' does not exist'];
                psberror(Erreur);
            end
        end
        i=i2+1;
    end

    if i<=long_chaine,
        expr_c=[expr_c,chaine(i:long_chaine)];
    end
    if i<=long_chaine,
        expr_d=[expr_d,chaine(i:long_chaine)];
    end
    if nbr_src==0,
        expr_d=[];
    end

    if debug_etat,
        disp(sprintf(['expr_c=',expr_c,'\n']));
        disp(sprintf(['expr_d=',expr_d,'\n']));
    end
