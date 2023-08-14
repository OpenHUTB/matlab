function[sps,Multimeter,NewNode]=PISectionLineBlock(nl,sps,Multimeter,NewNode)






    idx=nl.filter_type('Pi Section Line');

    for i=1:length(idx)

        block=nl.elements(idx(i));
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        [Phases,F,Resistance,Inductance,Capacitance,Conductance,long,nbr,SpecifyConductance]=getSPSmaskvalues(block,{'Phases','Frequency','Resistance','Inductance','Capacitance','Conductance','Length','PiSections','SpecifyConductance'});

        if Phases>1
            measure=get_param(block,'Measurements2');
        else
            measure=get_param(block,'Measurements');
        end


        Phases=round(Phases);
        long=long/nbr;
        blocinit(block,{Phases,F,Resistance,Inductance,Capacitance,long,nbr});

        if~SpecifyConductance
            Conductance=zeros(Phases,Phases);
        end

        w=2*pi*F;
        z=Resistance+1i*Inductance*w;
        y=Conductance+1i*Capacitance*w;


        [Ti,vpI]=eig(y*z);
        [Tv,vpV]=eig(z*y);




        [~,indexI]=sort(abs(diag(vpI)));
        [~,indexV]=sort(abs(diag(vpV)));
        Ti=Ti(:,indexI);
        Tv=Tv(:,indexV);

        zmode=inv(Tv)*z*Ti;
        ymode=inv(Ti)*y*Tv;





        k_mode=sum(abs(zmode),1)./max(abs(zmode),[],1);
        if any(k_mode>1.00001)
            zmodeIsDiagonal=0;
        else
            zmodeIsDiagonal=1;
        end
        k_mode=sum(abs(ymode),1)./max(abs(ymode),[],1);
        if any(k_mode>1.00001)
            ymodeIsDiagonal=0;
        else
            ymodeIsDiagonal=1;
        end

        if~(zmodeIsDiagonal&&ymodeIsDiagonal)




            k=0;
            for i=1:Phases
                for j=i+1:Phases
                    k=k+1;
                    Capacitance(i,j)=Capacitance(i,j)*(1+1e-5*k);
                    Capacitance(j,i)=Capacitance(i,j);
                end
            end

            y=Conductance+1i*Capacitance*w;
            [Ti,vpI]=eig(y*z);
            [Tv,vpV]=eig(z*y);
            [~,indexI]=sort(abs(diag(vpI)));
            [~,indexV]=sort(abs(diag(vpV)));
            Ti=Ti(:,indexI);
            Tv=Tv(:,indexV);

            zmode=inv(Tv)*z*Ti;
            ymode=inv(Ti)*y*Tv;
        end


        gammalmode=sqrt(diag(zmode).*diag(ymode))*long;

        Zmode=diag(zmode)*long;
        Ymode=diag(ymode)*long;
        Ymode_2=Ymode/2;


        Zmode_cor=Zmode.*sinh(gammalmode)./gammalmode;
        Ymode_2_cor=Ymode_2.*tanh(gammalmode/2)./(gammalmode/2);


        Z_cor=Tv*diag(Zmode_cor)*inv(Ti);
        Y_2_cor=Ti*diag(Ymode_2_cor)*inv(Tv);
        Y_cor=Y_2_cor*2;


        Z_cor_sym=Z_cor;
        for ii=1:Phases
            Z_cor_sym(ii,ii)=0;
        end
        Z_cor_sym=(Z_cor_sym+Z_cor_sym.')/2;
        for ii=1:Phases
            Z_cor_sym(ii,ii)=Z_cor(ii,ii);
        end
        Z_cor=Z_cor_sym;

        ResistanceMatrix=real(Z_cor);
        InductanceMatrix=imag(Z_cor)/w;
        GMatrix=real(Y_cor);
        CapacitanceMatrix=imag(Y_cor)/w;



        Z_cor_LF=Z_cor;
        Y_2_cor_LF=Y_2_cor;

        if nbr>1
            long=long*nbr;
            blocinit(block,{Phases,F,Resistance,Inductance,Capacitance,long,nbr});


            gammalmode=sqrt(diag(zmode).*diag(ymode))*long;

            Zmode=diag(zmode)*long;
            Ymode=diag(ymode)*long;
            Ymode_2=Ymode/2;


            Zmode_cor=Zmode.*sinh(gammalmode)./gammalmode;
            Ymode_2_cor=Ymode_2.*tanh(gammalmode/2)./(gammalmode/2);


            Z_cor=Tv*diag(Zmode_cor)*inv(Ti);
            Y_2_cor=Ti*diag(Ymode_2_cor)*inv(Tv);


            Z_cor_sym=Z_cor;
            for ii=1:Phases
                Z_cor_sym(ii,ii)=0;
            end
            Z_cor_sym=(Z_cor_sym+Z_cor_sym.')/2;
            for ii=1:Phases
                Z_cor_sym(ii,ii)=Z_cor(ii,ii);
            end
            Z_cor=Z_cor_sym;

            Z_cor_LF=Z_cor;
            Y_2_cor_LF=Y_2_cor;
        end



        nodes=nl.block_nodes(block);


        IOV=strcmp('Input and output voltages',measure);
        AVC=strcmp('All voltages and currents',measure);
        IOC=strcmp('Input and output currents',measure);
        API=strcmp('All pi-section voltages and currents',measure);
        NWW=strcmp('Phase-to-ground voltages',measure);

        for Section=1:nbr




            if Section==1
                NLeft=nodes(1:Phases);
            else
                NLeft=NRight;
            end
            if Section==nbr
                NRight=nodes(Phases+1:2*Phases);
            else
                NRight=(1:Phases)+NewNode;
                NewNode=NewNode+Phases+1;
            end


            if any(any(ResistanceMatrix<0))
                message=['A negative resistance has been computed for the ''',BlockNom,''' block. Please review the R L G C parameters you specified for this block or increase the number of pi sections.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
            if any(any(InductanceMatrix<0))
                message=['A negative inductance has been computed for the ''',BlockNom,''' block. Please review the R L G C parameters you specified for this block or increase the number of pi sections.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end


            if Phases>1
                [sps,NewNode]=AddMutualInductance(BlockNom,Phases,ResistanceMatrix,InductanceMatrix,NLeft,NRight,NewNode,sps,Section);
            else


                sps.rlc(end+1,1:6)=[NLeft,NRight,0,ResistanceMatrix,InductanceMatrix*1e3,0];
                sps.rlcnames{end+1}=['section ',num2str(Section),': ',BlockNom];

                if IOC||API||AVC
                    x=size(sps.rlc,1);
                    Multimeter.Yi{end+1,1}=[x+2,x+1,x];
                    if Section==1
                        Multimeter.I{end+1}=['Is: ',BlockNom];
                    else
                        Multimeter.I{end+1}=['Isection_',num2str(Section),': ',BlockNom];
                    end
                end

            end

            for p=1:Phases


                Cshunt=sum(CapacitanceMatrix(:,p))*1e6;





                if Section==1
                    sps.rlc(end+1,1:6)=[NLeft(p),0,0,0,0,Cshunt/2];
                    if Phases==1
                        rlcname='input: ';
                    else
                        rlcname=['sCshunt phase_',num2str(p),' section_1: '];
                    end
                    sps.rlcnames{end+1}=[rlcname,BlockNom];

                    if IOV||API||AVC

                        Multimeter.Yu(end+1,1:2)=[NLeft(p),0];
                        Multimeter.V{end+1}=['Us: ',BlockNom];
                    end
                    if NWW

                        Multimeter.Yu(end+1,1:2)=[NLeft(p),0];
                        Multimeter.V{end+1}=['Us phase_',num2str(p),': ',BlockNom];
                    end

                    Rshunt=1/sum(GMatrix(:,p)/2);
                    sps.rlc(end+1,1:6)=[NLeft(p),0,0,Rshunt,0,0];

                    if Phases==1
                        rlcname=['sRshunt section_1: '];
                    else
                        rlcname=['sRshunt phase_',num2str(p),' section_1: '];
                    end
                    sps.rlcnames{end+1}=[rlcname,BlockNom];

                end


                if Section>1

                    sps.rlc(end+1,1:6)=[NLeft(p),0,0,0,0,Cshunt];
                    if Phases==1
                        rlcname=['section_',num2str(Section),': '];
                    else
                        rlcname=['Cshunt phase_',num2str(p),' section_',num2str(Section),': '];
                    end

                    sps.rlcnames{end+1}=[rlcname,BlockNom];

                    if API

                        Multimeter.Yu(end+1,1:2)=[NLeft(p),0];
                        Multimeter.V{end+1}=['Usection_',num2str(Section),': ',BlockNom];
                    end

                    Rshunt=1/sum(GMatrix(:,p));
                    sps.rlc(end+1,1:6)=[NLeft(p),0,0,Rshunt,0,0];
                    if Phases==1
                        rlcname=['Rshunt section_',num2str(Section),': '];
                    else
                        rlcname=['Rshunt phase_',num2str(p),' section_',num2str(Section),': '];
                    end
                    sps.rlcnames{end+1}=[rlcname,BlockNom];

                end


                if Section==nbr

                    sps.rlc(end+1,1:6)=[NRight(p),0,0,0,0,Cshunt/2];
                    if Phases==1
                        rlcname='output: ';
                    else
                        rlcname=['rCshunt phase_',num2str(p),' section_',num2str(Section),': '];
                    end
                    sps.rlcnames{end+1}=[rlcname,BlockNom];

                    if IOV||API||AVC

                        Multimeter.Yu(end+1,1:2)=sps.rlc(end,1:2);
                        Multimeter.V{end+1}=['Ur: ',BlockNom];
                    end

                    if NWW

                        Multimeter.Yu(end+1,1:2)=[NRight(p),0];
                        Multimeter.V{end+1}=['Ur phase_',num2str(p),': ',BlockNom];
                    end

                    Rshunt=1/sum(GMatrix(:,p)/2);
                    sps.rlc(end+1,1:6)=[NRight(p),0,0,Rshunt,0,0];

                    if Phases==1
                        rlcname=['rRshunt section_',num2str(Section),': '];
                    else
                        rlcname=['rRshunt phase_',num2str(p),' section_',num2str(Section),': '];
                    end
                    sps.rlcnames{end+1}=[rlcname,BlockNom];

                end


                for k=p+1:Phases


                    Cphase=-CapacitanceMatrix(p,k)*1e6;
                    if Section==1
                        sps.rlc(end+1,1:6)=[NLeft(p),NLeft(k),0,0,0,Cphase/2];
                        rlcname=['Cs phase_',num2str(p),'_to_',num2str(k),' section_1: '];
                        sps.rlcnames{end+1}=[rlcname,BlockNom];
                    else

                        sps.rlc(end+1,1:6)=[NLeft(p),NLeft(k),0,0,0,Cphase];
                        rlcname=['C phase_',num2str(p),'_to_',num2str(k),' section_',num2str(Section),': '];
                        sps.rlcnames{end+1}=[rlcname,BlockNom];
                    end

                    if Section==nbr

                        Cphase=Cphase/2;
                        sps.rlc(end+1,1:6)=[NRight(p),NRight(k),0,0,0,Cphase];
                        rlcname=['Cr phase_',num2str(p),'_to_',num2str(k),' section_',num2str(Section),': '];
                        sps.rlcnames{end+1}=[rlcname,BlockNom];
                    end


                    if Section==1
                        Rphase=-1/(GMatrix(p,k)/2);
                        sps.rlc(end+1,1:6)=[NLeft(p),NLeft(k),0,Rphase,0,0];
                        rlcname=['Rs phase_',num2str(p),'_to_',num2str(k),' section_1: '];
                        sps.rlcnames{end+1}=[rlcname,BlockNom];
                    else


                        Rphase=-1/(GMatrix(p,k));
                        sps.rlc(end+1,1:6)=[NLeft(p),NLeft(k),0,Rphase,0,0];
                        rlcname=['R phase_',num2str(p),'_to_',num2str(k),' section_',num2str(Section),': '];
                        sps.rlcnames{end+1}=[rlcname,BlockNom];
                    end

                    if Section==nbr
                        Rphase=-1/(GMatrix(p,k)/2);
                        sps.rlc(end+1,1:6)=[NRight(p),NRight(k),0,Rphase,0,0];
                        rlcname=['Rr phase_',num2str(p),'_to_',num2str(k),' section_',num2str(Section),': '];
                        sps.rlcnames{end+1}=[rlcname,BlockNom];
                    end

                end

            end

        end

        if IOC||API||AVC

            x=size(sps.rlc,1);
            Multimeter.Yi{end+1,1}=[x-2,-(x-1),-x];
            Multimeter.I{end+1}=['Ir: ',BlockNom];
        end

        if isfield(sps,'LoadFlow')&&Phases==3
            sps.LoadFlow.Lines.handle{end+1}=block;
            sps.LoadFlow.Lines.r{end+1}=Resistance;
            sps.LoadFlow.Lines.l{end+1}=Inductance;
            sps.LoadFlow.Lines.c{end+1}=Capacitance;
            sps.LoadFlow.Lines.Zmatrix{end+1}=Z_cor_LF;
            sps.LoadFlow.Lines.Ymatrix{end+1}=Y_2_cor_LF;
            sps.LoadFlow.Lines.long{end+1}=long;
            sps.LoadFlow.Lines.freq{end+1}=F;
            sps.LoadFlow.Lines.leftnodes{end+1}=nodes(1:Phases);
            sps.LoadFlow.Lines.rightnodes{end+1}=nodes(Phases+1:2*Phases);
            sps.LoadFlow.Lines.LeftbusNumber{end+1}=[];
            sps.LoadFlow.Lines.RightbusNumber{end+1}=[];
            sps.LoadFlow.Lines.isPI{end+1}=1;
        end



        if isfield(sps,'UnbalancedLoadFlow')

            sps.UnbalancedLoadFlow.Lines.handle{end+1}=block;
            sps.UnbalancedLoadFlow.Lines.r{end+1}=Resistance;
            sps.UnbalancedLoadFlow.Lines.l{end+1}=Inductance;
            sps.UnbalancedLoadFlow.Lines.c{end+1}=Capacitance;
            sps.UnbalancedLoadFlow.Lines.Zmatrix{end+1}=Z_cor_LF;
            sps.UnbalancedLoadFlow.Lines.Ymatrix{end+1}=Y_2_cor_LF;
            sps.UnbalancedLoadFlow.Lines.long{end+1}=long;
            sps.UnbalancedLoadFlow.Lines.freq{end+1}=F;
            sps.UnbalancedLoadFlow.Lines.leftnodes{end+1}=nodes(1:Phases);
            sps.UnbalancedLoadFlow.Lines.rightnodes{end+1}=nodes(Phases+1:2*Phases);
            sps.UnbalancedLoadFlow.Lines.LeftbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.RightbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.isPI{end+1}=1;
            sps.UnbalancedLoadFlow.Lines.BlockType{end+1}=['PI ',num2str(Phases),'ph'];

        end

    end


    function[sps,NewNode]=AddMutualInductance(BlockNom,Phases,ResistanceMatrix,InductanceMatrix,NLeft,NRight,NewNode,sps,Section)

        RLCTEMP=[];
        RLCTEMPnames={};

        for p=1:Phases


            R=ResistanceMatrix(p,p);
            L=InductanceMatrix(p,p)*1e3;

            sps.rlc(end+1,1:6)=[NLeft(p),NRight(p),4,R,L,0];
            sps.rlcnames{end+1}=['seriesRL phase_',num2str(p),' section_',num2str(Section),': ',BlockNom];


            for k=p+1:Phases


                R=ResistanceMatrix(p,k);
                L=InductanceMatrix(p,k)*1e3;

                RLCTEMP(end+1,1:6)=[NewNode,NRight(p),444,R,L,0];%#ok  type 444 will be reset to 0 later in psbsort.
                RLCTEMPnames{end+1}=['mutual phase_',num2str(p),'_to_',num2str(k),' section_',num2str(Section),': ',BlockNom];%#ok

                NewNode=NewNode+1;

            end

        end


        sps.rlc=[sps.rlc;RLCTEMP];
        sps.rlcnames=[sps.rlcnames,RLCTEMPnames];
