function SPS=getMgen(in,mod_in,qty,idx,Q,YY,PP,SPS,Lmut)























































































    Erreur.identifier='SpecializedPowerSystems:Compiler:StateSpace';


    rlcnames=SPS.rlcnames;
    sourcenames=SPS.srcstr;
    switchnames=SPS.SwitchNames;
    outnames=SPS.outstr;






    b=qty.edges;
    n=qty.branches;
    nRLC=length(rlcnames);
    nSrc=length(sourcenames);
    [nline,ncol]=size(mod_in);




    nnames=length(rlcnames);

    for iline=1:nline
        k=idx.orgEdges(iline);
        if k>0&k<=nnames
            EdgeNames{iline}=char(rlcnames{k});
        elseif k<0
            EdgeNames{iline}=char(sourcenames{abs(k)});
        else
            EdgeNames{iline}='Risol';
        end
    end



    QEC=Q.EC;if qty.E==0|qty.Cl==0,QEC=[];end
    QER=Q.ER;if qty.E==0|qty.Rl==0,QER=[];end
    QEL=Q.EL;if qty.E==0|qty.Lll==0,QEL=[];end
    QEJ=Q.EJ;if qty.E==0|qty.J==0,QEJ=[];end

    QCC=Q.CC;if qty.Ct==0|qty.Cl==0,QCC=[];end
    QCR=Q.CR;if qty.Ct==0|qty.Rl==0,QCR=[];end
    QCL=Q.CL;if qty.Ct==0|qty.Lll==0,QCL=[];end
    QCJ=Q.CJ;if qty.Ct==0|qty.J==0,QCJ=[];end

    QRR=Q.RR;if qty.Rt==0|qty.Rl==0,QRR=[];end
    QRL=Q.RL;if qty.Rt==0|qty.Lll==0,QRL=[];end
    QRJ=Q.RJ;if qty.Rt==0|qty.J==0,QRJ=[];end

    QLL=Q.LL;if qty.Ltt==0|qty.Lll==0,QLL=[];end
    QLJ=Q.LJ;if qty.Ltt==0|qty.J==0,QLJ=[];end

    QRtCl=zeros(qty.Rt,qty.Cl);
    if qty.Rt==0||qty.Cl==0
        QRtCl=[];
    end
    QLttCl=zeros(qty.Ltt,qty.Cl);
    if qty.Ltt==0||qty.Cl==0
        QLttCl=[];
    end
    QLttRl=zeros(qty.Ltt,qty.Rl);
    if qty.Ltt==0||qty.Rl==0
        QLttRl=[];
    end



    Ql=[QEC,QER,QEL,QEJ
    QCC,QCR,QCL,QCJ
    QRtCl,QRR,QRL,QRJ
    QLttCl,QLttRl,QLL,QLJ];














    Mi=[eye(n),Ql];


    Ct=mod_in(idx.Ct:idx.Ct+qty.Ct-1,5)';

    Cl=mod_in(idx.Cl:idx.Cl+qty.Cl-1,5)';

    row=qty.E+1:qty.E+qty.Ct;
    col=qty.E+1:qty.E+qty.Ct;
    Mi(row,col)=diag(Ct);

    if~isempty([QEC;QCC])
        MCl=[];
        for i=1:qty.E+qty.Ct;
            MCl=[MCl;Cl];
        end
        row=1:qty.E+qty.Ct;
        col=n+1:n+qty.Cl;
        Mi(row,col)=[QEC;QCC].*MCl;
    end















    Qv=[-Ql',eye(b-n)];

    Mv=Qv;


    Lt=mod_in(idx.Ltt:idx.Ltt+qty.Ltt-1,5)';

    Ll=mod_in(idx.Lll:idx.Lll+qty.Lll-1,5)';

    if~isempty([QLL';QLJ'])
        MLt=[];
        for i=1:qty.Lll+qty.J
            MLt=[MLt;Lt];
        end
        row=qty.Cl+qty.Rl+1:b-n;
        col=n-qty.Ltt+1:n;
        Mv(row,col)=[-QLL';-QLJ'].*MLt;
    end

    row=qty.Cl+qty.Rl+1:qty.Cl+qty.Rl+qty.Lll;
    col=n+qty.Cl+qty.Rl+1:n+qty.Cl+qty.Rl+qty.Lll;
    Mv(row,col)=diag(Ll);


    Mg1=zeros(b,2*b);








    Mg1(1:n,1:b)=Mi;
    Mg1(n+1:b,b+1:2*b)=Mv;


    nMutualInductances=size(Lmut,2);
    Mg1init=Mg1;
    LmutEdgeRL=[];
    for i=1:nMutualInductances;



        idxWindings=find(mod_in(:,6)==i&in(mod_in(:,1),2)==10);


        for idxSelf=idxWindings'
            iSelf=find(idx.Ltt==idxSelf);

            idxCoupledWindings=idxWindings(find(idxWindings~=idxSelf));

            if~isempty(iSelf)

                icol_Self=b+qty.E+qty.Ct+qty.Rt+iSelf;
            else

                iSelf=find(idx.Lll==idxSelf);
                icol_Self=b+n+qty.Cl+qty.Rl+iSelf;
            end
            icol_Mut=[];
            Rm=[];
            Lm=[];
            if isempty(Lmut(i).mag)


                nn=findstr(EdgeNames{idxSelf},'_');
                iself=str2num(EdgeNames{idxSelf}(nn(1)+1:nn(2)-1));
            end
            for idxMut=idxCoupledWindings'
                iMut=find(idx.Ltt==idxMut);
                if~isempty(iMut)

                    icol_Mut=[icol_Mut,b+qty.E+qty.Ct+qty.Rt+iMut];
                else

                    iMut=find(idx.Lll==idxMut);
                    icol_Mut=[icol_Mut,b+n+qty.Cl+qty.Rl+iMut];
                end

                if isempty(Lmut(i).mag)

                    nn=findstr(EdgeNames{idxMut},'_');
                    imut=str2num(EdgeNames{idxMut}(nn(1)+1:nn(2)-1));
                    Rm=[Rm,Lmut(i).R(iself,imut)];
                    Lm=[Lm,Lmut(i).L(iself,imut)];
                else

                    Rm=[Rm,Lmut(i).mag(3)];
                    Lm=[Lm,Lmut(i).mag(4)];
                end
            end
            LineMg1ToModify=n+find(Qv(:,icol_Self-b)~=0);





            LmutEdgeRL{idxSelf}.EdgeNum=idxCoupledWindings;
            LmutEdgeRL{idxSelf}.Rm=Rm;
            LmutEdgeRL{idxSelf}.Lm=Lm;

            if~isempty(LineMg1ToModify)
                for iline=LineMg1ToModify'
                    if~isempty(Lm)

                        Mg1(iline,icol_Mut)=Mg1(iline,icol_Mut)+Lm*Qv(iline-n,icol_Self-b);
                    end
                    if~isempty(Rm)

                        Mg1(iline,icol_Mut-b)=Mg1(iline,icol_Mut-b)+Rm*Qv(iline-n,icol_Self-b);
                    end
                end
            end
        end
    end






    nTransformers=max(mod_in(:,7));
    for i=1:nTransformers
        Mg1_lineaddI=zeros(1,2*b);

        idxPrimaryWinding=find(mod_in(:,7)==i&mod_in(:,8)==0);

        iTr=find(idx.Rt==idxPrimaryWinding);
        if~isempty(iTr)

            icol_Iprim=qty.E+qty.Ct+iTr;
            icol_Vprim=b+icol_Iprim;
        else

            iTr=find(idx.Rl==idxPrimaryWinding);
            icol_Iprim=n+qty.Cl+iTr;
            icol_Vprim=b+icol_Iprim;
        end
        Mg1_lineaddI(icol_Iprim)=1;

        idxSecWindings=find(mod_in(:,7)==i&mod_in(:,8)~=0);
        for iWinding=idxSecWindings'
            iTr=find(idx.Rt==iWinding);
            WindingRatio=mod_in(iWinding,8);
            Mg1_lineaddV=zeros(1,2*b);
            Mg1_lineaddV(icol_Vprim)=1;
            if~isempty(iTr)

                icol_Isec=qty.E+qty.Ct+iTr;
                icol_Vsec=b+icol_Isec;
            else

                iTr=find(idx.Rl==iWinding);
                icol_Isec=n+qty.Cl+iTr;
                icol_Vsec=b+icol_Isec;
            end

            Mg1_lineaddI(icol_Isec)=WindingRatio;

            Mg1_lineaddV(icol_Vsec)=-1/WindingRatio;
            Mg1=[Mg1;Mg1_lineaddV];
        end



        Mg1=[Mg1;Mg1_lineaddI];
    end























    [Mg,idxMg,MgColNames,MgEdgeIndexV,MgEdgeIndexI]=SortMgData(mod_in,idx,qty,Mg1,EdgeNames);

    nResistances=length(idxMg.viResistances);
    nviTransformers=length(idxMg.viTransformers);
    nSwitches=length(idxMg.viSwitches)/2;
    nStates=length(idxMg.States);
    nSources=length(idxMg.Sources);

    [nline,ncol]=size(Mg);



    if SPS.PowerguiInfo.DisplayEquations
        fprintf('getMgen: Original KCL and KVL equations:\n')
        for i=1:nline
            str=sprintf('(%2d) : ',i);
            for j=1:ncol
                if Mg(i,j)~=0
                    str1=sprintf('+(%g)*%s  ',Mg(i,j),char(MgColNames(j)));
                    str=[str,str1];
                end
            end
            str=[str,' = 0'];
            fprintf('%s\n',str)
        end
        fprintf('\n')
    end









    nequations=nResistances+nviTransformers+nSources;

    if SPS.PowerguiInfo.DisplayEquations
        fprintf('\nGenerating circuit equations ....\n');
    end

    if nequations



        [A,jb,RowIndexes]=rref_mod(Mg(:,1:nequations));

        LineSelect=RowIndexes(1:nequations);
        if rank(Mg(LineSelect,1:nequations))~=nequations
            Erreur.message=sprintf(['Specialized Power Systems cannot solve this circuit. ',...
            'Please check for one the following two possibilities :\n',...
            '1) The circuit solution is undetermined. ',...
            'This problem arises when transformers with no magnetization branch (Rm=inf; Lm=inf) are connected together.\n',...
            '--> Specify a magnetizing branch with finite Rm and/or Lm parameter values.\n',...
            '2) Circuit solution is inuccurate due to a badly scaled circuit. ',...
            'This is usually caused by a too wide range of resistance values (ex 1e-6 ohm and 1e6 ohm in the same circuit).\n',...
            '--> Try to reduce range of resistance values. For example, reduce snubber resistances.']);
            psberror(Erreur);
        end




        Mg2=[eye(nequations),inv(Mg(LineSelect,1:nequations))*Mg(LineSelect,nequations+1:ncol)];

        Mg2EdgeIndexV=MgEdgeIndexV;
        Mg2EdgeIndexI=MgEdgeIndexI;




        if SPS.PowerguiInfo.DisplayEquations
            for i=1:nequations
                str=[];
                for j=1:ncol
                    if j==(nequations+1),str=[str,' = '];end
                    if Mg2(i,j)~=0
                        if j<=nequations
                            coef=Mg2(i,j);
                        else
                            coef=-Mg2(i,j);
                        end
                        if coef==1,
                            str1=sprintf('+%s  ',char(MgColNames(j)));
                        elseif coef==-1
                            str1=sprintf('-%s  ',char(MgColNames(j)));
                        elseif coef>0
                            str1=sprintf('+%g*%s  ',coef,char(MgColNames(j)));
                        else
                            str1=sprintf('-%g*%s  ',abs(coef),char(MgColNames(j)));
                        end
                        str=[str,str1];
                    end
                end
                fprintf('%s\n',str)
            end
            fprintf('\n')
        end




        for i=1:nequations
            idxline=find(Mg(:,i)~=0)';
            for iline=idxline
                Mg(iline,:)=Mg(iline,:)-Mg(iline,i)*Mg2(i,:);
            end
        end



        if SPS.PowerguiInfo.DisplayEquations
            fprintf('getMgen: KCL and KVL equations after substitution:\n')
            for i=1:b
                str=sprintf('(%2d) : ',i);
                for j=1:ncol
                    if Mg(i,j)~=0
                        str1=sprintf('+(%g)*%s  ',Mg(i,j),char(MgColNames(j)));
                        str=[str,str1];
                    end
                end
                str=[str,' = 0'];
                fprintf('%s\n',str)
            end
            fprintf('\n')
        end











        Error=sum(abs(Mg),2);
        [Error,index]=sort(Error);
        nEquationsToDelete=nline-(nStates+nSwitches);
        if SPS.PowerguiInfo.DisplayEquations&nEquationsToDelete<nline
            fprintf('getMgen: nEquationsToKeep=%d nEquationsToDelete=%d: SumCoef(%d)=%g SumCoef(%d)=%g\n',...
            nline-nEquationsToDelete,nEquationsToDelete,...
            nEquationsToDelete,Error(nEquationsToDelete),...
            nEquationsToDelete+1,Error(nEquationsToDelete+1));
        end
        LineSelect=sort(index(nEquationsToDelete+1:end))';
    else
        LineSelect=1:nline;
    end


    Mg=Mg(LineSelect,[idxMg.derivatives,idxMg.viSwitches,idxMg.States,idxMg.Sources]);
    MgColNames=MgColNames([idxMg.derivatives,idxMg.viSwitches,idxMg.States,idxMg.Sources]);
    [nline,ncol]=size(Mg);



    if nline~=(nStates+nSwitches)
        str=sprintf('For this circuit containing %d states and %d switches, %d equations are expected\n',...
        nStates,nSwitches,nStates+nSwitches);
        Erreur.message=[str,sprintf('However %d equations have been found',nline)];
        psberror(Erreur);
    end

    if SPS.PowerguiInfo.DisplayEquations
        fprintf('%d states (independent + dependent) + %d switches --> %d equations\n',nStates,nSwitches,nline)
    end









    MgEdgeIndexV=MgEdgeIndexV([idxMg.derivatives,idxMg.viSwitches,idxMg.States,idxMg.Sources]);
    MgEdgeIndexI=MgEdgeIndexI([idxMg.derivatives,idxMg.viSwitches,idxMg.States,idxMg.Sources]);

    if nequations
        Mg2=-Mg2(:,[idxMg.derivatives,idxMg.viSwitches,idxMg.States,idxMg.Sources]);
        Mg2EdgeIndexV=Mg2EdgeIndexV(1:nequations);
        Mg2EdgeIndexI=Mg2EdgeIndexI(1:nequations);
    else
        Mg2=[];
        Mg2EdgeIndexV=[];
        Mg2EdgeIndexI=[];
    end




    MgOutputs=getMgenOutputs(qty,idx,in,mod_in,YY,PP,Mg,Mg2,...
    MgEdgeIndexV,MgEdgeIndexI,Mg2EdgeIndexV,Mg2EdgeIndexI,LmutEdgeRL,nStates,nSwitches);

    [nOutputs,ncol]=size(MgOutputs);






    Index=[strmatch('U',outnames);strmatch('I',outnames)];
    [n,Index]=sort(Index);
    MgOutputs=MgOutputs(Index,:);



    if SPS.PowerguiInfo.DisplayEquations
        for ioutput=1:nOutputs
            str=[char(outnames{ioutput}),' = '];
            for icol=1:ncol
                coef=MgOutputs(ioutput,icol);
                if coef==1,
                    str1=sprintf('+%s  ',char(MgColNames(icol)));
                elseif coef==-1
                    str1=sprintf('-%s  ',char(MgColNames(icol)));
                elseif coef>0
                    str1=sprintf('+%g*%s  ',coef,char(MgColNames(icol)));
                elseif coef<0
                    str1=sprintf('-%g*%s  ',abs(coef),char(MgColNames(icol)));
                else
                    str1=[];
                end
                str=[str,str1];
            end
            fprintf('%s\n',str)
        end
        fprintf('\n')
    end



    SwitchIndex=zeros(1,nSwitches);

    for i=1:nSwitches
        SwitchName=char(MgColNames{nStates+2*i-1}(10:end));
        k=strmatch(SwitchName,switchnames,'exact');
        if~isempty(k)



            if length(k)>1
                ii=1;
                while length(switchnames{k(ii)})~=length(SwitchName)
                    ii=ii+1;
                end
                k=k(ii);
            end
            SwitchIndex(i)=k;
        else
            Erreur.message=sprintf('Switch named %s has not been found in SPS.SwitchNames',SwitchName);
            psberror(Erreur);
        end
    end


    MgColNames(nStates+2*SwitchIndex-1)=MgColNames(nStates+(1:2:2*nSwitches-1));
    Mg(:,nStates+2*SwitchIndex-1)=Mg(:,nStates+(1:2:2*nSwitches-1));
    MgOutputs(:,nStates+2*SwitchIndex-1)=MgOutputs(:,nStates+(1:2:2*nSwitches-1));


    MgColNames(nStates+2*SwitchIndex)=MgColNames(nStates+(2:2:2*nSwitches));
    Mg(:,nStates+2*SwitchIndex)=Mg(:,nStates+(2:2:2*nSwitches));
    MgOutputs(:,nStates+2*SwitchIndex)=MgOutputs(:,nStates+(2:2:2*nSwitches));



    SourceIndex=zeros(1,nSources);

    for i=1:nSources
        SourceName=char(MgColNames{2*nStates+2*nSwitches+i}(4:end));
        k=strmatch(SourceName,sourcenames,'exact');
        if~isempty(k)



            if length(k)>1
                ii=1;
                while length(sourcenames{k(ii)})~=length(SourceName)
                    ii=ii+1;
                end
                k=k(ii);
            end
            SourceIndex(i)=k;
        else
            Erreur.message=sprintf('Source named %s has not been found in SPS.srcstr',SourceName);
            psberror(Erreur);
        end
    end


    MgColNames(2*nStates+2*nSwitches+SourceIndex)=MgColNames(2*nStates+2*nSwitches+(1:nSources));
    Mg(:,2*nStates+2*nSwitches+SourceIndex)=Mg(:,2*nStates+2*nSwitches+(1:nSources));
    MgOutputs(:,2*nStates+2*nSwitches+SourceIndex)=MgOutputs(:,2*nStates+2*nSwitches+(1:nSources));





    Mg=[Mg(:,1:nStates),zeros(nline,nOutputs),Mg(:,nStates+1:nStates+2*nSwitches),-Mg(:,nStates+2*nSwitches+1:ncol)];



    Mg=[Mg;zeros(nOutputs,ncol+nOutputs)];
    lineout=nline+1:nline+nOutputs;
    Mg(lineout,1:nStates)=-MgOutputs(:,1:nStates);
    Mg(lineout,nStates+1:nStates+nOutputs)=eye(nOutputs);
    Mg(lineout,nStates+nOutputs+1:nStates+nOutputs+2*nSwitches)=...
    -MgOutputs(:,nStates+1:nStates+2*nSwitches);
    Mg(lineout,nStates+nOutputs+2*nSwitches+1:end)=...
    MgOutputs(:,nStates+2*nSwitches+1:end);

    MgColNames(nStates+nOutputs+1:ncol+nOutputs)=MgColNames(nStates+1:ncol);

    for i=1:nOutputs
        if outnames{i}(1)=='U'
            MgColNames{nStates+i}=['yv',outnames{i}(2:end)];
        else
            MgColNames{nStates+i}=['yi',outnames{i}(2:end)];
        end
    end

    ncol=ncol+nOutputs;
    nline=nline+nOutputs;



    if SPS.PowerguiInfo.DisplayEquations
        fprintf('getMgen: Final circuit KCL and KVL equations:\n')
        fprintf('(Number of equations = nStates+nSwitches= %d+%d = %d\n',nStates,nSwitches,nStates+nSwitches)
        for i=1:nline
            str=[];streq=0;
            if i==nStates+nSwitches+1;fprintf('\n');end
            for j=1:ncol
                if j==(nStates+2*nSwitches+nOutputs+1)&~isempty(str),
                    str=[str,'= '];
                    streq=1;
                end
                if Mg(i,j)~=0
                    coef=Mg(i,j);
                    if coef==1,
                        str1=sprintf('+%s  ',char(MgColNames(j)));
                    elseif coef==-1
                        str1=sprintf('-%s  ',char(MgColNames(j)));
                    elseif coef>0
                        str1=sprintf('+%g*%s  ',coef,char(MgColNames(j)));
                    else
                        str1=sprintf('-%g*%s  ',abs(coef),char(MgColNames(j)));
                    end
                    str=[str,str1];
                end
            end
            if~streq,str=[str,'= 0'];;end
            if strcmp(str(end-1:end),'= '),str=[str,' 0'];;end
            fprintf('%s\n',str)
        end
        fprintf('\n')
    end



    Mg_nb.x=nStates;
    Mg_nb.y=nOutputs;
    Mg_nb.s=nSwitches;
    Mg_nb.u=nSources;


    SPS.MgNotRed=Mg;
    SPS.MgColNamesNotRed=MgColNames;
    SPS.Mg_nbNotRed=Mg_nb;










    function[Mg,idxMg,MgColNames,MgEdgeIndexV,MgEdgeIndexI]=SortMgData(mod_in,idx,qty,Mg1,EdgeNames)

        b=qty.edges;
        n=qty.branches;

        Mg=[];
        MgColNames=[];
        MgColNumber=0;
        MgEdgeIndexV=zeros(1,2*b);
        MgEdgeIndexI=zeros(1,2*b);






        nResistances=0;
        Resistances=[];
        for ii=1:length(idx.Rt)
            idxR=idx.Rt(ii);
            nameEdge=char(EdgeNames{idxR});
            if isempty(strfind(nameEdge,'SPID'))&mod_in(idxR,7)==0
                Mg1Col=qty.E+qty.Ct+ii;

                Mg=[Mg,Mg1(:,Mg1Col+b)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['vR_',nameEdge];
                MgEdgeIndexV(MgColNumber)=idxR;

                Mg=[Mg,Mg1(:,Mg1Col)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['iR_',nameEdge];
                MgEdgeIndexI(MgColNumber)=idxR;

                nResistances=nResistances+1;
                Resistances(nResistances)=mod_in(idxR,5);
            end
        end
        for ii=1:length(idx.Rl)
            idxR=idx.Rl(ii);
            nameEdge=char(EdgeNames{idxR});
            if isempty(strfind(nameEdge,'SPID'))&mod_in(idxR,7)==0
                Mg1Col=n+qty.Cl+ii;

                Mg=[Mg,Mg1(:,Mg1Col+b)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['vR_',nameEdge];
                MgEdgeIndexV(MgColNumber)=-idxR;

                Mg=[Mg,Mg1(:,Mg1Col)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['iR_',nameEdge];
                MgEdgeIndexI(MgColNumber)=-idxR;

                nResistances=nResistances+1;
                Resistances(nResistances)=mod_in(idxR,5);
            end
        end

        idxMg.viResistances=1:MgColNumber;





        nviTransformers=MgColNumber;
        for ii=1:length(idx.Rt)
            idxR=idx.Rt(ii);
            nameEdge=char(EdgeNames{idxR});
            if mod_in(idxR,7)~=0
                Mg1Col=qty.E+qty.Ct+ii;

                Mg=[Mg,Mg1(:,Mg1Col+b)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['vW_',nameEdge];
                MgEdgeIndexV(MgColNumber)=idxR;


                Mg=[Mg,Mg1(:,Mg1Col)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['iW_',nameEdge];
                MgEdgeIndexI(MgColNumber)=idxR;
            end
        end
        for ii=1:length(idx.Rl)
            idxR=idx.Rl(ii);
            nameEdge=char(EdgeNames{idxR});
            if mod_in(idxR,7)~=0
                Mg1Col=n+qty.Cl+ii;


                Mg=[Mg,Mg1(:,Mg1Col+b)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['vW_',nameEdge];
                MgEdgeIndexV(MgColNumber)=-idxR;


                Mg=[Mg,Mg1(:,Mg1Col)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['iW_',nameEdge];
                MgEdgeIndexI(MgColNumber)=-idxR;
            end
        end
        nviTransformers=MgColNumber-nviTransformers;
        idxMg.viTransformers=2*nResistances+1:MgColNumber;




        FirstCol=2*b-qty.J+1;
        LastCol=2*b;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.J'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['vJ_',nameEdge];
            MgEdgeIndexV(MgColNumber)=-i;
        end


        FirstCol=1;
        LastCol=FirstCol-1+qty.E;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.E'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['iE_',nameEdge];
            MgEdgeIndexI(MgColNumber)=i;
        end

        idxMg.viSources=2*nResistances+nviTransformers+1:MgColNumber;
        nSources=length(idxMg.viSources);








        row_mod_in_Sw=[];
        isw=0;
        for i=1:length(EdgeNames)
            nn=findstr(EdgeNames{i},'SPID');
            if~isempty(nn)



                isw=isw+1;
                row_mod_in_Sw=[row_mod_in_Sw,i];
            end
        end

        for row_mod_in=row_mod_in_Sw
            idxRswitch=find(idx.Rt==row_mod_in);
            if~isempty(idxRswitch)
                nameEdge=char(EdgeNames{idx.Rt(idxRswitch)});


                FirstCol=qty.E+qty.Ct+idxRswitch+b;
                Mg=[Mg,Mg1(:,FirstCol)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['vSW_',nameEdge];
                MgEdgeIndexV(MgColNumber)=idx.Rt(idxRswitch);


                FirstCol=qty.E+qty.Ct+idxRswitch;
                Mg=[Mg,Mg1(:,FirstCol)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['iSW_',nameEdge];
                MgEdgeIndexI(MgColNumber)=idx.Rt(idxRswitch);
            else
                idxRswitch=find(idx.Rl==row_mod_in);
                nameEdge=char(EdgeNames{idx.Rl(idxRswitch)});


                FirstCol=n+qty.Cl+idxRswitch+b;
                Mg=[Mg,Mg1(:,FirstCol)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['vSW_',nameEdge];
                MgEdgeIndexV(MgColNumber)=-idx.Rl(idxRswitch);


                FirstCol=n+qty.Cl+idxRswitch;
                Mg=[Mg,Mg1(:,FirstCol)];
                MgColNumber=MgColNumber+1;
                MgColNames{MgColNumber}=['iSW_',nameEdge];
                MgEdgeIndexI(MgColNumber)=-idx.Rl(idxRswitch);
            end
        end
        idxMg.viSwitches=2*nResistances+nviTransformers+nSources+1:MgColNumber;
        nSwitches=length(idxMg.viSwitches)/2;





        FirstCol=b+n-qty.Ltt+1;
        LastCol=FirstCol-1+qty.Ltt;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.Ltt'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['dIl_',nameEdge];
            MgEdgeIndexV(MgColNumber)=i;
        end


        FirstCol=b+n+qty.Cl+qty.Rl+1;
        LastCol=FirstCol-1+qty.Lll;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.Lll'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['dIl_',nameEdge];
            MgEdgeIndexV(MgColNumber)=-i;
        end


        FirstCol=qty.E+1;
        LastCol=FirstCol-1+qty.Ct;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.Ct'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['dUc_',nameEdge];
            MgEdgeIndexI(MgColNumber)=i;
        end


        FirstCol=n+1;
        LastCol=FirstCol-1+qty.Cl;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.Cl'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['dUc_',nameEdge];
            MgEdgeIndexI(MgColNumber)=-i;
        end

        idxMg.derivatives=2*nResistances+nviTransformers+nSources+2*nSwitches+1:MgColNumber;
        nStates=length(idxMg.derivatives);




        FirstCol=qty.E+qty.Ct+qty.Rt+1;
        LastCol=FirstCol-1+qty.Ltt;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.Ltt'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['Il_',nameEdge];
            MgEdgeIndexI(MgColNumber)=i;
        end


        FirstCol=n+qty.Cl+qty.Rl+1;
        LastCol=FirstCol-1+qty.Lll;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.Lll'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['Il_',nameEdge];
            MgEdgeIndexI(MgColNumber)=-i;
        end


        FirstCol=b+qty.E+1;
        LastCol=FirstCol-1+qty.Ct;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.Ct'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['Uc_',nameEdge];
            MgEdgeIndexV(MgColNumber)=i;
        end


        FirstCol=b+n+1;
        LastCol=FirstCol-1+qty.Cl;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.Cl'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['Uc_',nameEdge];
            MgEdgeIndexV(MgColNumber)=-i;
        end

        idxMg.States=2*nResistances+nviTransformers+nSources+2*nSwitches+nStates+1:MgColNumber;




        FirstCol=b+1;
        LastCol=FirstCol-1+qty.E;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.E'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['vE_',nameEdge];
            MgEdgeIndexV(MgColNumber)=i;
        end


        FirstCol=b-qty.J+1;
        LastCol=b;
        Mg=[Mg,Mg1(:,FirstCol:LastCol)];
        for i=idx.J'
            nameEdge=char(EdgeNames{i});
            MgColNumber=MgColNumber+1;
            MgColNames{MgColNumber}=['iJ_',nameEdge];
            MgEdgeIndexI(MgColNumber)=-i;
        end

        idxMg.Sources=2*nResistances+nviTransformers+nSources+2*nSwitches+2*nStates+1:MgColNumber;





        [nline,ncol]=size(Mg);
        for ires=1:nResistances
            icol=2*(ires-1)+1;
            for i=1:nline

                if Mg(i,icol)~=0
                    Mg(i,icol+1)=Mg(i,icol)*Resistances(ires);
                    Mg(i,icol)=0;
                end
            end
        end


        Mg=Mg(:,[2:2:2*nResistances,2*nResistances+1:ncol]);
        MgColNames=MgColNames([2:2:2*nResistances,2*nResistances+1:ncol]);
        MgEdgeIndexV=MgEdgeIndexV([2:2:2*nResistances,2*nResistances+1:ncol]);
        MgEdgeIndexI=MgEdgeIndexI([2:2:2*nResistances,2*nResistances+1:ncol]);
        [nline,ncol]=size(Mg);

        idxMg.viResistances=idxMg.viResistances(1:nResistances);
        idxMg.viTransformers=idxMg.viTransformers-nResistances;
        idxMg.viSources=idxMg.viSources-nResistances;
        idxMg.viSwitches=idxMg.viSwitches-nResistances;
        idxMg.derivatives=idxMg.derivatives-nResistances;
        idxMg.States=idxMg.States-nResistances;
        idxMg.Sources=idxMg.Sources-nResistances;





        function[YY2]=getCurrentMeasInfo(qty,idx,mod_in,YY)

















            if isstruct(YY)
                qty.ib=size(YY.ib,1);
            else
                qty.ib=0;
            end

            idx.ibTypes=zeros(1,7);

            if qty.ib>0
                ib_types=[];
                for k=1:qty.ib


                    idx1=find(~YY.ib{k}(3,:));
                    columnsToRemove=[];
                    for m=idx1
                        thisBr=find(idx.orgEdges==YY.ib{k}(2,m));
                        thisBr=mod_in(thisBr,:);

                        types=(thisBr(:,9)==1&thisBr(:,2)==3)*2+...
                        (thisBr(:,9)==0&thisBr(:,2)==4)*3+...
                        (thisBr(:,9)==0&thisBr(:,2)==2)*4+...
                        (thisBr(:,9)==1&thisBr(:,2)==1)*5+...
                        (thisBr(:,9)==0&thisBr(:,2)==3)*6+...
                        (thisBr(:,9)==1&thisBr(:,2)==2)*7;

                        switch YY.ib{k}(5,m)
                        case 1
                            nbEdges=size(YY.ib{k},2);
                            nbNewEdges=length(types);
                            count=1;
                            for kk=nbEdges+1:nbEdges+nbNewEdges
                                YY.ib{k}(1,kk)=YY.ib{k}(1,m);
                                YY.ib{k}(2,kk)=thisBr(count,1);
                                YY.ib{k}(3,kk)=types(count);
                                count=count+1;
                            end

                            columnsToRemove=[columnsToRemove,m];
                        case 0
                            [idx2,idx3]=min(types);
                            thisBr=thisBr(idx3,:);
                            YY.ib{k}(2,m)=thisBr(1);
                            YY.ib{k}(3,m)=idx2;
                        case 2



                            idx2=find(thisBr(:,5));
                            if~isempty(idx2)
                                idx2=idx2(1);
                                thisBr=thisBr(idx2,:);
                                YY.ib{k}(2,m)=thisBr(1);
                                YY.ib{k}(3,m)=types(idx2);
                            else
                                YY.ib{k}(2,m)=thisBr(1);
                                YY.ib{k}(3,m)=types(1);
                            end
                        case 3



                            idx2=find(thisBr(:,5));
                            if~isempty(idx2)
                                idx2=idx2(1);
                                thisBr=thisBr(idx2,:);
                                YY.ib{k}(2,m)=thisBr(1);
                                YY.ib{k}(3,m)=types(idx2);
                            else
                                YY.ib{k}(2,m)=thisBr(1);
                                YY.ib{k}(3,m)=types(1);
                            end



                        case 4



                            idx2=find(thisBr(:,5));
                            if~isempty(idx2)
                                idx2=idx2(1);
                                thisBr=thisBr(idx2,:);
                                YY.ib{k}(2,m)=thisBr(1);
                                YY.ib{k}(3,m)=types(idx2);
                            else
                                YY.ib{k}(2,m)=thisBr(1);
                                YY.ib{k}(3,m)=types(1);
                            end

                        end
                    end
                    if size(YY.ib{k},1)>4
                        YY.ib{k}(5,:)=[];
                    end
                    if~isempty(columnsToRemove)
                        YY.ib{k}(:,columnsToRemove)=[];
                    end
                end

                for k=1:qty.ib
                    idx1=find(YY.ib{k}(3,:)>1);
                    for m=idx1

                        switch YY.ib{k}(3,m)
                        case 2
                            idx3=idx.Lll;
                        case 3
                            idx3=idx.Ltt;
                        case 4
                            idx3=idx.Ct;
                        case 5
                            idx3=idx.Cl;
                        case 6
                            idx3=idx.Rt;
                        case 7
                            idx3=idx.Rl;
                        end
                        YY.ib{k}(4,m)=find(mod_in(idx3,1)==YY.ib{k}(2,m));
                        if isempty(YY.ib{k}(4,m))
                            fprintf('\n\nCan''t find a component in branch current ');
                            fprintf('computations.\n');
                            fprintf('Processing interrupted.\n\n');
                            return;
                        end
                        ib_types=[ib_types,YY.ib{k}(3,m)];
                    end
                end
                ib_types=unique(ib_types);
                idx.ibTypes(ib_types)=1;
            end







            YY2=YY;
            nOutputI=length(YY.ib);
            for iOutput=1:nOutputI
                [nn,nEdge]=size(YY2.ib{iOutput});
                for iEdge=1:nEdge
                    if YY2.ib{iOutput}(3,iEdge)==1

                        idxEdge=find(idx.orgEdges==-YY2.ib{iOutput}(2,iEdge));
                        YY2.ib{iOutput}(2,iEdge)=idxEdge;
                    else

                        idxEdge=find(mod_in(:,1)==YY2.ib{iOutput}(2,iEdge));
                        YY2.ib{iOutput}(2,iEdge)=idxEdge;
                    end
                end
                YY2.ib{iOutput}=YY2.ib{iOutput}(1:2,:);
            end




            function[MgOutputs]=getMgenOutputs(qty,idx,in,mod_in,YY,PP,Mg,Mg2,...
                MgEdgeIndexV,MgEdgeIndexI,Mg2EdgeIndexV,Mg2EdgeIndexI,LmutEdgeRL,nStates,nSwitches)
















                Erreur.identifier='SpecializedPowerSystems:Compiler:StateSpace';

                [nline,ncol]=size(Mg);
                [nOutputV,nn]=size(YY.vnn);
                [nOutputI,nn]=size(YY.ib);
                MgOutputs=zeros(nOutputV+nOutputI,ncol);
                nOutputs=0;









                EdgeIndexV.MgCol=zeros(1,qty.branches);
                EdgeIndexV.Mg2Line=zeros(1,qty.branches);
                for ibranch=1:qty.branches
                    icol=find(MgEdgeIndexV==ibranch);
                    if~isempty(icol)
                        EdgeIndexV.MgCol(ibranch)=icol;
                    else
                        iline=find(Mg2EdgeIndexV==ibranch);
                        if isempty(iline)
                            iline=find(Mg2EdgeIndexI==ibranch);
                        end
                        EdgeIndexV.Mg2Line(ibranch)=iline;
                    end
                end

                for ioutput=1:nOutputV
                    nOutputs=nOutputs+1;
                    node1=YY.vnn(ioutput,1);
                    node2=YY.vnn(ioutput,2);
                    if node1==node2continue;end
                    kSign=1;
                    for node=[node1,node2]
                        for ibranch=1:qty.branches
                            if node==0,break;end
                            if PP(node,ibranch)~=0
                                EdgeType=in(mod_in(ibranch,1),2);
                                icol=EdgeIndexV.MgCol(ibranch);
                                if icol>0



                                    switch(EdgeType)
                                    case 1
                                        MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)-kSign*PP(node,ibranch);
                                    case 2
                                        MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)-kSign*PP(node,ibranch);
                                    case 4
                                        MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)-kSign*PP(node,ibranch);
                                    case 8

                                        MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)-kSign*PP(node,ibranch)*mod_in(ibranch,5);
                                    case 10

                                        MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)-kSign*PP(node,ibranch)*mod_in(ibranch,5);

                                        for i=1:length(LmutEdgeRL{ibranch}.EdgeNum)

                                            icol_Mut=find(abs(MgEdgeIndexV)==LmutEdgeRL{ibranch}.EdgeNum(i));
                                            Lm=LmutEdgeRL{ibranch}.Lm(i);
                                            MgOutputs(nOutputs,icol_Mut)=MgOutputs(nOutputs,icol_Mut)-kSign*PP(node,ibranch)*Lm;

                                            icol_Mut=icol_Mut+nStates+2*nSwitches;
                                            Rm=LmutEdgeRL{ibranch}.Rm(i);
                                            MgOutputs(nOutputs,icol_Mut)=MgOutputs(nOutputs,icol_Mut)-kSign*PP(node,ibranch)*Rm;
                                        end
                                    otherwise
                                        Erreur.message=sprintf('Unexpected element type (%d)when building equation of voltage at node %d',...
                                        EdgeType,node);
                                        psberror(Erreur);
                                    end
                                else

                                    iline=EdgeIndexV.Mg2Line(ibranch);
                                    switch(EdgeType)
                                    case 3
                                        MgOutputs(nOutputs,:)=MgOutputs(nOutputs,:)-kSign*PP(node,ibranch)*Mg2(iline,:);

                                    case{4,7}

                                        MgOutputs(nOutputs,:)=MgOutputs(nOutputs,:)-kSign*PP(node,ibranch)*Mg2(iline,:)*mod_in(ibranch,5);
                                    case 11
                                        MgOutputs(nOutputs,:)=MgOutputs(nOutputs,:)-kSign*PP(node,ibranch)*Mg2(iline,:);
                                    otherwise
                                        Erreur.message=sprintf('Unexpected element type (%d)when building equation of voltage at node %d',...
                                        EdgeType,node);
                                        psberror(Erreur);
                                    end
                                end
                            end
                        end
                        kSign=-1;
                    end
                end


                [YY]=getCurrentMeasInfo(qty,idx,mod_in,YY);











                EdgeIndexI.MgCol=zeros(1,qty.edges);
                EdgeIndexI.Mg2Line=zeros(1,qty.edges);

                for ibranch=1:qty.edges
                    icol=find(abs(MgEdgeIndexI)==ibranch);
                    if~isempty(icol)
                        EdgeIndexI.MgCol(ibranch)=icol;
                    else
                        iline=find(abs(Mg2EdgeIndexI)==ibranch);
                        EdgeIndexI.Mg2Line(ibranch)=iline;
                    end
                end

                for ioutput=1:nOutputI
                    nOutputs=nOutputs+1;
                    [nn,nEdges]=size(YY.ib{ioutput});
                    for iEdge=1:nEdges
                        edge=YY.ib{ioutput}(2,iEdge);
                        kSign=YY.ib{ioutput}(1,iEdge);
                        icol=EdgeIndexI.MgCol(edge);
                        EdgeType=in(mod_in(edge,1),2);
                        if icol>0

                            switch(EdgeType)
                            case 2
                                MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)+kSign*mod_in(edge,5);
                            case 4
                                MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)+kSign;
                            case 8
                                MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)+kSign;
                            case 10
                                MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)+kSign;
                            case 12
                                MgOutputs(nOutputs,icol)=MgOutputs(nOutputs,icol)+kSign;
                            otherwise
                                Erreur.message=sprintf('Unexpected element type (%d)when building equation of current for edge %d',...
                                EdgeType,edge);
                                psberror(Erreur);
                            end
                        else

                            iline=EdgeIndexI.Mg2Line(edge);
                            switch(EdgeType)
                            case 1
                                MgOutputs(nOutputs,:)=MgOutputs(nOutputs,:)+kSign*Mg2(iline,:);
                            case 3
                                MgOutputs(nOutputs,:)=MgOutputs(nOutputs,:)+kSign*Mg2(iline,:);

                            case{4,7}
                                MgOutputs(nOutputs,:)=MgOutputs(nOutputs,:)+kSign*Mg2(iline,:);
                            case 11
                                MgOutputs(nOutputs,:)=MgOutputs(nOutputs,:)+kSign*Mg2(iline,:);
                            otherwise
                                Erreur.message=sprintf('Unexpected element type (%d)when building equation of current for edge %d',...
                                EdgeType,edge);
                                psberror(Erreur);
                            end
                        end
                    end
                end


