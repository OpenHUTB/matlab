function[A,B,C,D,statescell,x0,x0sw,rlswitch,u,x,y,freq,Asw,Bsw,Csw,Dsw,Hlin,Hswo]=...
    power_statespace_pr(rlc,switches,source,line_dist,yout,y_type,unit,blocs,srcstr,...
    BrancheREF,silent,fid_outfile,freq_sys,ref_node,vary_name,vary_val)%#ok








    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_statespace'));
    end


    commandLine=1;
    nargs=nargin;
    debug_etat=0;

    switch nargs
    case 7
        blocs=[];
        srcstr=[];
        BrancheREF=[];%#ok
        silent=0;
        freq_sys=60;
        ref_node=0;
        vary_name=[];
        vary_val=[];
        nvary=0;
        fid_outfile=0;
    case 12
        freq_sys=60;
        ref_node=0;
        vary_name=[];
        vary_val=[];
        nvary=0;
    case 13
        ref_node=0;
        vary_name=[];
        vary_val=[];
        nvary=0;
    case 14
        vary_name=[];
        vary_val=[];
        nvary=0;
    case 16
        nvary=size(vary_name,1);
    end

    if~isempty(blocs),
        blocs=strrep(blocs,char(10),' ');
    end



    version='5.0';
    if fid_outfile>0,
        fprintf(fid_outfile,'POWER_STATESPACE Version %s\n\n',version);
    end

    if commandLine
        systemInfo.Outputs=[];
        systemInfo.outstr=yout;
        qtyOut=size(yout,1);
    else
        systemInfo.Outputs=yout.Outputs;
        systemInfo.outstr=yout.outstr;
        qtyOut=size(yout.outstr,1);
    end

    omega=freq_sys*2*pi;
    qtySrc=size(source,1);



    [rlc,liste_neu,ind_neu,ind_neusrc,ind_neusw,mat_tr,unit,rlccar]=etapar(rlc,switches,source,qtyOut,ref_node,unit,silent,fid_outfile,blocs,srcstr);%#ok

    if fid_outfile>0
        fprintf(fid_outfile,'Number of outputs: %g\n\n',qtyOut);
    end



    systemInfo.rlc=rlc;
    systemInfo.source=source;
    systemInfo.vary_name=vary_name;
    systemInfo.vary_val=vary_val;
    systemInfo.nvary=nvary;
    systemInfo.unit=unit;
    systemInfo.freq_sys=freq_sys;
    systemInfo.liste_neu=liste_neu;
    systemInfo.ytype=y_type;
    systemInfo.rlcnames=blocs;
    systemInfo.srcstr=srcstr;
    systemInfo.PowerguiInfo.SPID=0;
    systemInfo.yout=systemInfo.outstr;
    systemInfo.freq=freq_sys;

    [sps,statescell,src,out,circ2ssInfo]=psb2sys(systemInfo,commandLine,silent,fid_outfile);

    A=sps.A;
    B=sps.B;
    C=sps.C;
    D=sps.D;

    states=char(statescell);
    qtySvar=size(states,1);
    nbvar1=size(A,1);



    if silent==0,
        valp=eig(A);
        [n,i]=sort(imag(valp));
        valp=valp(i);
        disp('\nOscillatory modes and damping factors:\n');
        for i=1:nbvar1,
            if imag(valp(i))>0,
                fmode=imag(valp(i))/2/pi;
                zeta=-real(valp(i))/abs(valp(i));
                disp(sprintf('F=%gHz zeta=%g\n',fmode,zeta));
            end
        end
    end

    if fid_outfile>0
        fprintf(fid_outfile,'\n');
    end

    if commandLine
        rlcm=circ2ssInfo.rlcm;
        rlc1=circ2ssInfo.rlc1;
        liste_neu=circ2ssInfo.liste_neu;
        L_combi=circ2ssInfo.L_combi;
        C_combi=circ2ssInfo.C_combi;
        Il_relat=circ2ssInfo.Il_relat;
        Uc_relat=circ2ssInfo.Uc_relat;
        nb_ldep=circ2ssInfo.nb_ldep;
        nb_cdep=circ2ssInfo.nb_cdep;
        var_branche=circ2ssInfo.var_branche;
        var_nom=circ2ssInfo.var_nom;%#ok
        c_ligne=circ2ssInfo.c_ligne;
        Cvn=C;Dvn=D;%#ok
        C=zeros(qtyOut,nbvar1);D=zeros(qtyOut,qtySrc);
        vec_c0=zeros(1,nbvar1);vec_d0=zeros(1,qtySrc);%#ok





        if fid_outfile>0
            fprintf(fid_outfile,'Output expressions:\n');

            if nvary>0,fprintf(fid_outfile,'\n');end
        end

        for ivary=1:nvary
            eval([vary_name(ivary,:),'=vary_val(ivary);'])
            if fid_outfile>0
                fprintf(fid_outfile,'%s = %g\n',vary_name(ivary,:),vary_val(ivary));
            end
        end
        for i_sortie=1:qtyOut,
            chaine=yout(i_sortie,:);


            if y_type(i_sortie)==0,
                sortie=['y_u',int2str(i_sortie)];


            elseif y_type(i_sortie)==1,
                sortie=['y_i',int2str(i_sortie)];
            end


            if fid_outfile
                fprintf(fid_outfile,['\n',sortie,' = ',chaine]);
            end

            [expr_c,expr_d,vec_c,vec_d,vec_u]=etacd(chaine,sortie,rlcm,rlc1,...
            source,states,var_branche,nbvar1,liste_neu,L_combi,C_combi,...
            Il_relat,Uc_relat,nb_ldep,nb_cdep,c_ligne,debug_etat);%#ok



            if length(expr_c)>0&&nbvar1>0,
                str=['C(',int2str(i_sortie),',:)=',expr_c,';'];
                eval(str);
            end
            if length(expr_d)>0,
                str=['D(',int2str(i_sortie),',:)=',expr_d,';'];
                eval(str);
            end
        end
    end



    if nbvar1<qtySvar,
        for i=nbvar1+1:qtySvar
            statescell{i}=[statescell{i},'*'];
        end
    end



    if~isempty(switches)
        rlswitch=[switches(:,4),switches(:,5)];
        switch unit
        case 'OMU'
            rlswitch(:,2)=rlswitch(:,2)./1000;
        case 'OHM'
            rlswitch(:,2)=rlswitch(:,2)./omega;
        end
    else
        rlswitch=[];
    end



    psb.A=A;
    psb.B=B;
    psb.C=C;
    psb.D=D;

    if isempty(psb.B),psb.B=zeros(nbvar1,qtySrc);end
    if isempty(psb.C),psb.C=zeros(qtyOut,nbvar1);end
    if isempty(psb.D),psb.D=zeros(qtyOut,qtySrc);end

    if isempty(switches)
        psb.switches=zeros(0,9);
    else
        psb.switches=switches;
    end
    psb.source=source;
    psb.rlswitch=rlswitch;
    psb.unit=unit;
    psb.freq=freq_sys;
    psb.distline=line_dist;
    if isempty(line_dist)
        psb.DistributedParameterLine=[];
    else
        for kk=1:size(line_dist,1)
            psb.DistributedParameterLine{kk}.BlockName='';
            psb.DistributedParameterLine{kk}.WB=0;
            psb.DistributedParameterLine{kk}.WBG=[];
            psb.DistributedParameterLine{kk}.Decoupling=0;
        end
    end
    psb.PowerguiInfo.PhasorFrequency=60;
    psb.PowerguiInfo.SPID=0;

    psb=etass(psb);

    u=psb.uss;
    x=psb.xss;
    y=psb.yss;
    x0=psb.x0;
    x0sw=psb.x0switch;
    Asw=psb.Aswitch;
    Bsw=psb.Bswitch;
    Csw=psb.Cswitch;
    Dsw=psb.Dswitch;
    freq=psb.freq;
    Hlin=psb.Hlin;
    Hswo=psb.Hswo;




    if silent==0,
        for ifreq=1:length(freq)
            disp(sprintf('\nSteady state outputs @ F=%g Hz :\n',freq(ifreq)));
            for i=1:qtyOut
                if y_type(i)==1,
                    str='y_i';
                    unit='Amperes';
                else
                    str='y_u';
                    unit='Volts';
                end
                if freq(ifreq)>0,
                    disp(sprintf([str,sprintf(...
                    ['%g = %.4g ',unit,' < %.4g deg.\n'],...
                    i,abs(y(i,ifreq)),angle(y(i,ifreq))*180/pi)]));
                else
                    disp(sprintf([str,sprintf(...
                    ['%g= %.4g',unit,'\n'],...
                    i,real(y(i,ifreq)))]));
                end
            end
        end
    end

    if isempty(B),B=zeros(nbvar1,qtySrc);end
    if isempty(C),C=zeros(qtyOut,nbvar1);end
    if isempty(D),D=zeros(qtyOut,qtySrc);end
