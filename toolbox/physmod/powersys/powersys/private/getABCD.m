function[SPS,svar,src,out,qty,circ2ssInfo,EquivalentCircuit]=getABCD(in,YY,...
    names,srcnames,outnames,orgEdgeNbrs,idxSrc,idxOut,commandLine,...
    silent,SPS,circ2ssInfo,Lmut,fid_outfile)













































    qty=struct('E',[],'Ct',[],'Rt',[],'Rt2',[],'Ltt',[],'Cl',[],'Rl',[],...
    'Rl2',[],'Lll',[],'J',[],'States',[],'In',[],'Out',[],'nodes',[],...
    'edges',[],'branches',[],'links',[],'isolNet',[],'Sw',[],'Trfmr',[],...
    'Mut',size(Lmut,2),'Vnn',[],'ib',[]);

    idx=struct('E',[],'Ct',[],'Rt',[],'Rt2',[],'Ltt',[],'Cl',[],'Rl',[],...
    'Rl2',[],'Lll',[],'J',[],'Sw',[],'ST',[],'VW',[],'LmMut',[],...
    'LlMut',[],'orgEdges',[],'ibTypes',[],'Svars',[],'Src',idxSrc,...
    'Out',idxOut);

    idx.orgEdges=orgEdgeNbrs;


    [mod_in,idx1]=sortrows(in,2);
    idx.orgEdges=idx.orgEdges(idx1);


    idx1=find(mod_in(:,2)==2);
    [newOrgEdges,idx2]=sort(idx.orgEdges(idx1));
    idx.orgEdges(idx1)=newOrgEdges;
    mod_in(idx1,:)=mod_in(idx1(idx2),:);








    nodes=unique([mod_in(:,3)',mod_in(:,4)']);
    qty.nodes=length(nodes);
    qty.edges=size(mod_in,1);
    qty.isolNet=length(find(nodes<1));



    [mod_in,branches,qty,idx,EquivalentCircuit]=getTree(mod_in,qty,idx,srcnames,names,SPS,silent);



    [mod_in,branches,idx,qty,QQ,Q,PP,Lmut,invAtAl]=getAPQ(mod_in,branches,...
    qty,idx,names,srcnames,Lmut,silent,SPS);

    nbvar=qty.Ct+qty.Cl+qty.Ltt+qty.Lll;
    power_printf(fid_outfile,'Total number of inductances and capacitors: %g\n',nbvar);



    if SPS.PowerguiInfo.SPID

        SPS=getMgen(in,mod_in,qty,idx,Q,YY,PP,SPS,Lmut);






        [SPS,StateVarNames,src,out]=getABCDspid(SPS);
        svar=StateVarNames';


        return

    else

        SPS.MgNotRed=[];
        SPS.MgColNamesNotRed=[];
        SPS.Mg_nbNotRed=[];
        SPS.Mg=[];
        SPS.MgColNames=[];
        SPS.Mg_nb=[];
        SPS.MatStateDependency=[];

    end



    [Bcmp,Fcmp,qty,M]=compMatr(mod_in,idx,qty,QQ,Q,Lmut);






    [Ac,Bc,Cc,Dc,vnn_ca,qty,idx]=statMatr(mod_in,PP,qty,idx,Bcmp,Fcmp,YY,...
    branches,Q,QQ,invAtAl,idxSrc,M,circ2ssInfo,commandLine);
    SPS.A=Ac;SPS.B=Bc;SPS.C=Cc;SPS.D=Dc;



    if(commandLine||(fid_outfile~=0))
        circ2ssInfo=circ2ssDepend(qty,idx,Q,circ2ssInfo,SPS,...
        fid_outfile,commandLine);
        svar=circ2ssInfo.var_nom;
        src=[];
        out=[];
    end



    if~commandLine
        [svar,src,out]=getLists(qty,idx,Q,QQ,Bcmp,Fcmp,vnn_ca,mod_in,YY,...
        names,srcnames,outnames);
    end











    function[mod_in,branches,qty,idx,EquivalentCircuit]=getTree(mod_in,qty,idx,srcnames,...
        names,SPS,silent)


        EquivalentCircuit=1;

        S=cell(ceil(qty.edges/2),1);
        sets=zeros(ceil(qty.edges/2),1);
        nextEmptySet=1;
        qty.branches=0;
        br=0;
        k=1;






        branches=zeros(2,qty.nodes-qty.isolNet);







        UniqueNodes=unique(mod_in(:,3:4));
        if all(size(UniqueNodes)==[1,2])
            UniqueNodes=UniqueNodes';
        end
        nodesInSet=[UniqueNodes,zeros(qty.nodes,1)];





        adjust=abs(min(nodesInSet(:,1)))+1;

        while(br<(qty.nodes-qty.isolNet))
            p=mod_in(k,3);
            q=mod_in(k,4);








            x=nodesInSet(p+adjust,2);
            y=nodesInSet(q+adjust,2);









            case1=((x==0&y==0)*1+(x~=0&y==0)*2+(x==0&y~=0)*3+...
            (x~=0&y~=0&x~=y)*4+(x~=0&y~=0&x==y)*5);













            switch(case1)
            case{1}
                checkForIllegalBranches(mod_in(k,2));
                S{nextEmptySet}=[S{nextEmptySet},p,q];
                sets(nextEmptySet)=1;
                br=br+1;
                branches(:,br)=[mod_in(k,1);k];
                nodesInSet([p+adjust,q+adjust],2)=nextEmptySet;
            case{2}
                checkForIllegalBranches(mod_in(k,2));
                S{x}=[S{x},q];
                br=br+1;
                branches(:,br)=[mod_in(k,1);k];
                sets(x)=1;
                nodesInSet(q+adjust,2)=x;
            case{3}
                checkForIllegalBranches(mod_in(k,2));
                S{y}=[S{y},p];
                br=br+1;
                branches(:,br)=[mod_in(k,1);k];
                sets(y)=1;
                nodesInSet(p+adjust,2)=y;
            case{4}
                checkForIllegalBranches(mod_in(k,2));
                if x<y
                    S{x}=[S{x},S{y}];
                    nodesInSet(S{y}+adjust,2)=x;
                    S{y}=[];
                    sets(y)=0;
                else
                    S{y}=[S{y},S{x}];
                    nodesInSet(S{x}+adjust,2)=y;
                    S{x}=[];
                    sets(x)=0;
                end
                br=br+1;
                branches(:,br)=[mod_in(k,1);k];
            otherwise


                switch mod_in(k,2)
                case 1



                    if~isempty(srcnames)
                        Vname=strrep(srcnames{idx.Src(k)},'U_','');
                    else
                        Vname=sprintf('U_n%g_%g',SPS.source(-idx.orgEdges(k),1:2));
                    end
                    message=['The Voltage Source block ''',Vname,''' cannot be connected in parallel with another voltage source.'];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:getABCD:BlockConnectionIssue';
                    psberror(Erreur);
                case 3




                    if~isempty(names)
                        TrfName=names{idx.orgEdges(k)};
                    else
                        TrfName=sprintf('Trf_n%g_%g',SPS.rlc(idx.orgEdges(k),1:2));
                    end
                    [windingName,r]=strtok(TrfName,':');
                    blockName=strtrim(strrep(r,':',''));
                    message=['The ideal secondary winding ''',windingName,...
                    ''' of transformer block ''',blockName,...
                    ''' forms a loop with either:',newline,...
                    '     - another transformer ideal secondary winding;',newline,...
                    '     - an ideal voltage source;',newline,...
                    '     - a capacitor;',newline,...
                    '     - any combination of the above.',newline,...
                    'You must add a small impedance (resistance or inductance) in this loop, ',...
                    'either in the transformer winding or in series with one of the ',...
                    'other elements in the loop.'];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:getABCD:BlockConnectionIssue';
                    psberror(Erreur);
                end
            end
            k=k+1;
            emptySets=find(~sets);
            if~isempty(emptySets)
                nextEmptySet=emptySets(1);
            end
        end
        idx1=find(branches(1,:));
        branches=branches(:,idx1);
        qty.branches=size(branches,2);
        qty.links=qty.edges-qty.branches;


        if qty.links==0
            blocksInList=[names;srcnames];


            if~silent
                fprintf(['\n... The circuit containing the block ''',blocksInList{1},''' has no electrical loops.\n... This portion of your model will be ignored during simulation.\n']);
            end






            EquivalentCircuit=0;

        end





        mod_in(:,9)=ones(qty.edges,1);
        mod_in(branches(2,:),9)=0;

        [mod_in,idx1]=sortrows(mod_in,9);
        idx.orgEdges=idx.orgEdges(idx1);










        function[]=checkForIllegalBranches(edgeType)

            if(edgeType==11)

                Erreur.identifier='SpecializedPowerSystems:getABCD:BlockConnectionIssue';
                Erreur.message=sprintf(['Simscape Electrical Specialized Power Systems cannot solve this ',...
                'circuit. The circuit solution is undetermined. This problem ',...
                'arises when transformers with no magnetization branch (',...
                'Rm=inf; Lm=inf) are connected together.\n',...
                '--> Specify a magnetizing branch with finite Rm and/or Lm ',...
                'parameter values.']);
                psberror(Erreur);
            end








            function[mod_in,branches,idx,qty,QQ,Q,PP,Lmut,invAtAl]=...
                getAPQ(mod_in,branches,qty,idx,names,srcnames,Lmut,silent,SPS)%#ok



                bt=mod_in(:,2).*~mod_in(:,9);
                if qty.links>0
                    lt=mod_in(:,2).*mod_in(:,9);
                else
                    lt=[];
                end


                k=find(bt==2);
                if~isempty(k)
                    mod_in(k,2)=2;
                end
                k=[find(bt>2&bt<8);find(bt==11)];
                if~isempty(k)
                    mod_in(k,2)=3;
                end
                k=find(bt>7&bt<11);
                if~isempty(k)
                    mod_in(k,2)=4;
                end

                if qty.links>0

                    k=find(lt==2);
                    if~isempty(k)
                        mod_in(k,2)=1;
                    end

                    idx.Rl2=find(lt>3&lt<8);
                    qty.Rl2=length(idx.Rl2);
                    k=[find(lt>2&lt<8);find(lt==11)];
                    if~isempty(k)
                        mod_in(k,2)=2;
                    end
                    k=find(lt>7&lt<11);
                    if~isempty(k)
                        mod_in(k,2)=3;
                    end
                    k=find(lt==12);
                    if~isempty(k)
                        mod_in(k,2)=4;
                    end
                end
                branches(3,:)=mod_in(1:qty.branches,2)';


                [mod_in,idx1]=sortrows(mod_in,[9,2,6,7,8]);
                idx.orgEdges=idx.orgEdges(idx1);
                branches=branches(:,idx1(1:qty.branches));
                bt=mod_in(:,2).*~mod_in(:,9);
                if qty.links>0
                    lt=mod_in(:,2).*mod_in(:,9);
                end

                A=sparse(qty.branches,qty.edges);
                idx1=find(mod_in(:,3)>0);
                idx3=find(mod_in(:,4)>0);
                if~isempty(idx1)
                    idx2=mod_in(idx1,3);
                    A(idx2+(idx1-1)*qty.branches)=-1;
                end
                if~isempty(idx3)
                    idx4=mod_in(idx3,4);
                    A(idx4+(idx3-1)*qty.branches)=1;
                end
                At=A(:,1:qty.branches);
                Al=A(:,qty.branches+1:qty.edges);
                invAtAl=inv(At)*Al;
                PP=(inv(A(:,1:qty.nodes-qty.isolNet)))';
                Q2=gaussjor(A);
                Qt=Q2(:,1:qty.branches);

                if(nnz(Qt-eye(qty.branches))>0)
                    fprintf('Qt is not identity matrix !!!! Processing interrupted.\n\n');
                    return;
                end
                Ql=Q2(:,qty.branches+1:qty.edges);
                Bft=-Ql';






                list_bt=unique(unique(mod_in(find(bt~=0),2))');
                if qty.links>0
                    list_lt=unique(unique(mod_in(find(lt~=0),2))');
                end
                QQ=zeros(4,4);
                if qty.links>0
                    for k=list_bt
                        for m=list_lt
                            QQ(k,m)=1;
                        end
                    end
                end

                idx.E=find(bt==1);
                idx.Ct=find(bt==2);
                idx.Rt=find(bt==3);
                idx.Ltt=find(bt==4);




                if(~isempty(idx.Ltt)&&~QQ(4,3))




                    QQ(4,3)=1;
                end

                if qty.links>0
                    idx.Cl=find(lt==1);
                    idx.Rl=find(lt==2);
                    idx.Lll=find(lt==3);
                    idx.J=find(lt==4);
                else
                    idx.Cl=[];
                    idx.Rl=[];
                    idx.Lll=[];
                    idx.J=[];
                end



                if~isempty(idx.J)

                    idxJshc=find(mod_in(idx.J,3)==mod_in(idx.J,4));
                    if~isempty(idxJshc)
                        Q2(:,idx.J(idxJshc))=zeros(size(Q2,1),length(idxJshc));
                    end
                end

                if any(mod_in(:,2)==12)

                    idx.J=[idx.J;find(mod_in(:,2)==12)];
                end

                qty.Rt=length(idx.Rt);
                qty.Ct=length(idx.Ct);
                qty.Ltt=length(idx.Ltt);
                qty.Rl=length(idx.Rl);
                qty.Cl=length(idx.Cl);
                qty.Lll=length(idx.Lll);
                qty.E=length(idx.E);
                qty.J=length(idx.J);
                qty.States=qty.Ct+qty.Lll;
                qty.In=qty.J+qty.E;
                qty.Out=length(idx.Out);

                if qty.States+qty.In==0
                    message=['The model ''',gcs,''' can''t be solved, since it contains no state variables and no inputs.'];
                    Erreur.message=message;
                    Erreur.identifier=['SpecializedPowerSystems:getABCD:StateSpaceModelIssue',mfilename];
                    psberror(Erreur);
                end


                idx.Rt2=find((mod_in(1:qty.branches,2)==3)&...
                (mod_in(1:qty.branches,7)==0));
                qty.Rt2=length(idx.Rt2);
















                for k=1:qty.Mut
                    for m=1:Lmut(k).qtyWdgs
                        Lmut(k).LinTree(m)=-1;
                        if qty.Ltt>0
                            idx1=find(idx.orgEdges(idx.Ltt)==Lmut(k).wdgs(m,5));
                        else
                            idx1=[];
                        end

                        if~isempty(idx1)
                            Lmut(k).LinTree(m)=1;

                            Lmut(k).wdgs(m,1)=idx1;
                        else
                            if qty.Lll>0
                                idx1=find(idx.orgEdges(idx.Lll,1)==Lmut(k).wdgs(m,5));
                            else
                                idx1=[];
                            end
                            if~isempty(idx1)
                                Lmut(k).LinTree(m)=0;

                                Lmut(k).wdgs(m,1)=idx1;
                            else

                            end
                        end

                        Lmut(k).RinTree(m)=-1;
                        if qty.Rt>0
                            idx1=find(idx.orgEdges(idx.Rt)==Lmut(k).wdgs(m,5));
                        else
                            idx1=[];
                        end

                        if~isempty(idx1)
                            Lmut(k).RinTree(m)=1;

                            Lmut(k).wdgs(m,2)=idx1;
                        else
                            idx1=find(idx.orgEdges(idx.Rl)==Lmut(k).wdgs(m,5));
                            if~isempty(idx1)
                                Lmut(k).RinTree(m)=0;

                                Lmut(k).wdgs(m,2)=idx1;
                            else


                            end
                        end
                    end
                end

                Q=struct('EC',[],'ER',[],'EL',[],'EJ',[],'CC',[],'CR',[],'CL',[],'CJ',...
                [],'RR',[],'RL',[],'RJ',[],'LL',[]);
                if QQ(1,1)
                    Q.EC=Q2(idx.E,idx.Cl);
                else
                    Q.EC=0;
                end
                if QQ(1,2)
                    Q.ER=Q2(idx.E,idx.Rl);
                else
                    Q.ER=0;
                end
                if QQ(1,3)
                    Q.EL=Q2(idx.E,idx.Lll);
                else
                    Q.EL=0;
                end
                if QQ(1,4)
                    Q.EJ=Q2(idx.E,idx.J);
                else
                    Q.EJ=0;
                end
                if QQ(2,1)
                    Q.CC=Q2(idx.Ct,idx.Cl);
                else
                    Q.CC=0;
                end
                if QQ(2,2)
                    Q.CR=Q2(idx.Ct,idx.Rl);
                else
                    Q.CR=0;
                end
                if QQ(2,3)
                    Q.CL=Q2(idx.Ct,idx.Lll);
                else
                    Q.CL=0;
                end
                if QQ(2,4)
                    Q.CJ=Q2(idx.Ct,idx.J);
                else
                    Q.CJ=0;
                end
                if QQ(3,2)
                    Q.RR=Q2(idx.Rt,idx.Rl);
                else
                    Q.RR=0;
                end
                if QQ(3,3)
                    Q.RL=Q2(idx.Rt,idx.Lll);
                else
                    Q.RL=0;
                end
                if QQ(3,4)
                    Q.RJ=Q2(idx.Rt,idx.J);
                else
                    Q.RJ=0;
                end
                if QQ(4,3)
                    Q.LL=Q2(idx.Ltt,idx.Lll);
                else
                    Q.LL=0;
                end
                if QQ(4,4)
                    Q.LJ=Q2(idx.Ltt,idx.J);
                else
                    Q.LJ=0;
                end

                TexteSnubber='You can avoid the use of the snubber by selecting the ''Continuous'' simulation type in the Solver tab of the Powergui and deselecting the ''Disable ideal switching'' option in the Preferences tab of Powergui block.';



                idx1=find(mod_in(:,2)==12&mod_in(:,9)==0);
                if~isempty(idx1)
                    idx1=idx1(1);
                    nodes=mod_in(idx1,3:4);
                    nodes1=[];
                    if any(idx.J==idx1)
                        idx.J(find(idx.J==idx1))=[];
                    end
                    nodes2=mod_in(idx.J,3:4);
                    for k=1:size(nodes2,1)
                        nodes1=[nodes1;nodes];
                    end
                    FirstCurrentSource=-idx.orgEdges(idx1);
                    Jbranch1=strrep(srcnames{FirstCurrentSource},'I_','');



                    if~isempty(nodes2)

                        [idx2,~]=find(nodes1==nodes2);
                        if isempty(idx2)
                            [idx2,~]=find(nodes1==nodes2(:,[2,1]));
                        end
                        if~isempty(idx2)



                            SecondCurrentSource=-idx.orgEdges(idx.J(idx2(1)));

                            CheckIfPMSMBlock(FirstCurrentSource,SecondCurrentSource,SPS.sourcenames,nodes1,nodes2);

                            [YesitIs,BlockName,RCsnubber]=CheckIfUniversalBridgeBlock(FirstCurrentSource,...
                            SecondCurrentSource,SPS.sourcenames);
                            if YesitIs







                                texte1=['Due to a modeling constraint in Simscape Electrical Specialized Power Systems, you need to define ',...
                                'snubbers in parallel with the power electronic devices in the Universal Bridge block named:'];
                                if RCsnubber
                                    texte2=['If you are using a continuous solver, specifying purely resistive snubbers ',...
                                    'with a large resistance (i.e. Rs=1e5 and Cs=Inf) will resolve this constraint ',...
                                    'and make the snubbers virtually negligible in comparison with the rest of your model.'];
                                    texte3=['If your model is discretized, you need specifying RC snubbers. ',...
                                    'See the Universal Bridge documentation for selection of appropriate Rs and Cs values.'];
                                    message=[texte1,...
                                    newline,newline,...
                                    '  ',strrep(BlockName,newline,' '),...
                                    newline,newline,...
                                    texte2,...
                                    newline,newline,...
                                    texte3,...
                                    TexteSnubber];
                                else
                                    texte2=['Specifying purely resistive snubbers with a large resistance ',...
                                    '(i.e. Rs=1e5 and Cs=Inf) will resolve this constraint and make the snubbers virtually negligible ',...
                                    'in comparison with the rest of your model.'];
                                    message=[texte1,...
                                    newline,newline,...
                                    '  ',strrep(BlockName,newline,' '),...
                                    newline,newline,...
                                    texte2,...
                                    TexteSnubber];
                                end

                            else
                                Jbranch2=strrep(srcnames{SecondCurrentSource},'I_','');
                                message=['The following two blocks cannot be connected in series because they are modeled as current sources:',...
                                newline,newline,'Block 1: ',Jbranch1,newline,'Block 2: ',Jbranch2,newline,newline,...
                                'Add a high-value resistance in parallel with one of the two block.',newline,...
                                'You can also specify high-value resistive snubbers if the blocks have a snubber device.',...
                                TexteSnubber];
                            end
                        else

                            message=['The ''',Jbranch1,''' block cannot be left open-circuit because it is modeled as a current source.',...
                            newline,...
                            'You should try to resolve the open-circuit topology or delete this block from your model.'];
                        end
                    else

                        message=['The ''',Jbranch1,''' block cannot be left open-circuit because it is modeled as a current source.',...
                        newline,...
                        'You should try to resolve the open-circuit topology or delete this block from your model.'];
                    end
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:getABCD:BlockConnectionIssue';
                    psberror(Erreur);
                end



                [idx1,idx2]=find(Q.LJ);
                if~isempty(idx1)
                    idx1=idx1(1);
                    idx2=idx2(1);
                    idx3=idx.Src(qty.E+1:qty.In);
                    Lbranch=names{idx.orgEdges(idx.Ltt(idx1))};
                    Jbranch=strrep(srcnames{idx3(idx2)},'I_','');

                    message=['The following two blocks cannot be connected in series:',...
                    newline,newline,'Block 1: ''',Jbranch,'''',newline,'Block 2: ''',Lbranch,'''',newline,newline,...
                    'The first block, modeled as a current source, cannot be connected in series with the inductive element of the second block.',newline,...
                    'Add a high-value resistance in parallel with one of the two block.',newline,'You can also specify high-value resistive snubbers if the blocks have a snubber device.',...
                    TexteSnubber];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:getABCD:BlockConnectionIssue';
                    psberror(Erreur);
                end


                B_CE=Bft(1:qty.Cl,1:qty.E);
                errorFlag=0;

                if~isempty(B_CE)

                    [idx1,idx2]=find(B_CE);
                    if~isempty(idx1)
                        idx1=idx1(1);
                        idx2=idx2(1);
                        ClName=names{idx.orgEdges(idx.Cl(idx1))};
                        Ename=srcnames{idx.Src(idx2)};

                        message=['The voltage source block ''',Ename(3:end),''' ',...
                        'cannot be connected in parallel with the capacitive',newline,'element defined in the block ''',...
                        ClName,'''.',newline...
                        ,'Add a small resistor in series with the voltage source block, or with the capacitive element.'];

                        Erreur.message=message;
                        Erreur.identifier='SpecializedPowerSystems:getABCD:BlockConnectionIssue';
                        psberror(Erreur);
                    end
                end












                function[A]=gaussjor(A)

                    nb_rows=size(A,1);
                    col=1;

                    while(col<=nb_rows)

                        nonzeros=find(A(:,col));
                        if~isempty(nonzeros)

                            row=nonzeros(nonzeros>=col);
                            row=row(1);
                            if(A(row,col)==-1)
                                A(row,:)=-A(row,:);
                            end

                            if(row~=col)
                                A([row,col],:)=A([col,row],:);
                                row=col;
                            end
                            x=find(A(:,col));
                            x=x(x~=col);
                            if~isempty(x)
                                A(x,:)=A(x,:)-A(x,col)*A(row,:);
                            end
                        end
                        col=col+1;
                    end





                    function[Bcmp,Fcmp,qty,M]=compMatr(mod_in,idx,qty,QQ,Q,Lmut)

                        Bcmp=struct('Gtt',[],'Gll',[],'Glt',[],'Gtl',[],'Ct',[],'Cl',[],...
                        'Ltt',[],'Lll',[]);
                        if~isempty(idx.Rt)
                            Bcmp.Gtt=sparse(diag(mod_in(idx.Rt,5)));
                        else
                            Bcmp.Gtt=0;
                        end
                        if~isempty(idx.Ct)
                            Bcmp.Ct=sparse(diag(mod_in(idx.Ct,5)));
                        else
                            Bcmp.Ct=0;
                        end
                        if~isempty(idx.Rl)
                            Bcmp.Gll=sparse(qty.Rl,qty.Rl);
                            for k=1:qty.Rl
                                thisRl=mod_in(idx.Rl(k),5);
                                if thisRl~=0
                                    Bcmp.Gll(k,k)=1/thisRl;
                                end
                            end
                        else
                            Bcmp.Gll=0;
                        end
                        if~isempty(idx.Cl)
                            Bcmp.Cl=sparse(diag(mod_in(idx.Cl,5)));
                        else
                            Bcmp.Cl=0;
                        end
                        if~isempty(idx.Ltt)
                            Bcmp.Ltt=sparse(diag(mod_in(idx.Ltt,5)));
                        else
                            Bcmp.Ltt=0;
                        end
                        if~isempty(idx.Lll)
                            Bcmp.Lll=sparse(diag(mod_in(idx.Lll,5)));
                        else
                            Bcmp.Lll=0;
                        end



                        Bcmp.Ltl=sparse(qty.Ltt,qty.Lll);
                        Bcmp.Gtl=sparse(qty.Rt,qty.Rl);
                        Bcmp.Glt=sparse(qty.Rl,qty.Rt);

                        for k=1:qty.Mut
                            qtyWdgs=Lmut(k).qtyWdgs;
                            vecL=Lmut(k).LinTree;
                            vecR=Lmut(k).RinTree;


                            for m=1:qtyWdgs
                                i1=Lmut(k).wdgs(m,1);
                                cond1=(vecL(m)==1);
                                for n=m+1:qtyWdgs
                                    if isempty(Lmut(k).mag)

                                        Lm=Lmut(k).L(m,n);
                                    else

                                        Lm=Lmut(k).mag(4);
                                    end

                                    if(Lm~=0)
                                        cond2=(vecL(n)==1);
                                        i2=Lmut(k).wdgs(n,1);

                                        state=(~cond1&~cond2)+(cond1&~cond2)*2+...
                                        (~cond1&cond2)*3+(cond1&cond2)*4;

                                        switch state
                                        case 1
                                            Bcmp.Lll(i1,i2)=Lm;
                                            Bcmp.Lll(i2,i1)=Lm;
                                        case 2
                                            Bcmp.Ltl(i1,i2)=Lm;
                                        case 3
                                            Bcmp.Ltl(i2,i1)=Lm;
                                        case 4
                                            Bcmp.Ltt(i1,i2)=Lm;
                                            Bcmp.Ltt(i2,i1)=Lm;
                                        end
                                    end
                                end
                            end


                            for m=1:qtyWdgs
                                i1=Lmut(k).wdgs(m,2);
                                cond1=(vecR(m)==1);
                                for n=m+1:qtyWdgs
                                    if isempty(Lmut(k).mag)

                                        Rm=Lmut(k).R(m,n);
                                    else

                                        Rm=Lmut(k).mag(3);
                                    end

                                    if(Rm~=0)
                                        cond2=(vecR(n)==1);
                                        i2=Lmut(k).wdgs(n,2);
                                        state=(~cond1&~cond2)+(cond1&~cond2)*2+(~cond1&cond2)*3+...
                                        (cond1&cond2)*4;
                                        switch state
                                        case 1
                                            Bcmp.Gll(i1,i2)=Rm;
                                            Bcmp.Gll(i2,i1)=Rm;
                                        case 2
                                            Bcmp.Gtl(i1,i2)=Rm;
                                            Bcmp.Glt(i2,i1)=Rm;
                                        case 3
                                            Bcmp.Gtl(i2,i1)=Rm;
                                            Bcmp.Glt(i1,i2)=Rm;
                                        case 4
                                            Bcmp.Gtt(i1,i2)=Rm;
                                            Bcmp.Gtt(i2,i1)=Rm;
                                        end
                                    end
                                end
                            end
                        end
                        Bcmp.Llt=Bcmp.Ltl';

                        Fcmp=struct('invL',[],'invC',[],'F',[],'G',[],'H',[],'Y',[],'Fhat',[],...
                        'Ghat',[],'Hhat',[],'Yhat',[]);
                        C=Bcmp.Ct;
                        if QQ(2,1)
                            C=C+Q.CC*Bcmp.Cl*Q.CC';
                        end
                        L=Bcmp.Lll;
                        if QQ(4,3)
                            L=L-Bcmp.Llt*Q.LL-Q.LL'*Bcmp.Ltl+Q.LL'*Bcmp.Ltt*Q.LL;
                        end



                        if((qty.Lll>0)&&(rank(full(L))<size(L,1)))
                            message=['A singularity has been detected in the inductance ',...
                            'matrix. This situation typically arises when there is a ',...
                            'mutual inductance block whose inductance parameters lead to ',...
                            'a singular inductance matrix for that block. You must change ',...
                            'some of the inductance values within such blocks until the ',...
                            'singularity has been removed (e.g., this error message no ',...
                            'longer appears).',newline,'Alternatively, you ',...
                            'can use the ''Continuous'' simuation type of the powergui, with the ''Disable ideal switching'' option deselected'];
                            Erreur.message=message;
                            Erreur.identifier='SpecializedPowerSystems:getABCD:SingularInductanceMatrix';
                            psberror(Erreur);
                        end

                        if qty.Ct>0
                            Fcmp.invC=inv(C);
                        end
                        if qty.Lll>0
                            Fcmp.invL=inv(L);
                        end








                        qty.Trfmr=length(unique(mod_in(find(mod_in(:,7)),7)));
                        if((qty.Trfmr>0)||(qty.Mut>0&&QQ(3,2)))


                            if(qty.Trfmr>0)


                                temp1=mod_in(idx.Rt,7);
                                temp2=mod_in(idx.Rl,7);
                                for k=1:qty.Trfmr
                                    idx1=find(temp1==k);
                                    idx2=find(temp2==k);
                                    for m=1:length(idx1)
                                        Bcmp.Gtl(idx1(m),idx2)=mod_in(idx.Rt(idx1(m)),8);
                                        Bcmp.Glt(idx2,idx1(m))=-Bcmp.Gtl(idx1(m),idx2);
                                    end
                                end
                            end

                            U1=speye(qty.Rl);
                            U2=speye(qty.Rt);
                            if qty.Rt>0
                                M1=U1+Bcmp.Glt*Q.RR;
                            else
                                M1=0;
                            end
                            if qty.Rl>0
                                M2=U2-Bcmp.Gtl*Q.RR';
                            else
                                M2=0;
                            end
                            if QQ(3,2)
                                M3=Bcmp.Gtt*Q.RR*inv(M1);
                                M7=Bcmp.Gll*Q.RR'*inv(M2);
                                invD1=inv(M2+M3*Bcmp.Gll*Q.RR');
                                invD2=inv(M1+M7*Bcmp.Gtt*Q.RR);
                                M11=invD1*(-M3*Bcmp.Gll+Bcmp.Gtl);
                                M12=invD1*(M3*Bcmp.Glt-Bcmp.Gtt);
                                M13=invD2*(M7*Bcmp.Gtl+Bcmp.Gll);
                                M14=invD2*(-M7*Bcmp.Gtt-Bcmp.Glt);
                            else
                                M3=0;
                                M7=0;
                                M11=0;
                                M12=0;
                                M13=0;
                                M14=0;
                            end
                            if(QQ(3,2)&&QQ(3,3))
                                M4=Q.RL'*inv(M2+M3*Bcmp.Gll*Q.RR');
                                M5=-M4*(M3*Bcmp.Gll-Bcmp.Gtl);
                                M6=-M4*(M3*Bcmp.Glt-Bcmp.Gtt);
                                Fcmp.F=M6*Q.RL;
                            else
                                M4=0;
                                M5=0;
                                M6=0;
                                Fcmp.F=sparse(qty.Lll,qty.Lll);
                            end
                            if QQ(3,2)&&QQ(2,2)
                                M8=Q.CR*inv(M1+M7*Bcmp.Gtt*Q.RR);
                                M9=-M8*(M7*Bcmp.Gtl+Bcmp.Gll);
                                M10=M8*(M7*Bcmp.Gtt+Bcmp.Glt);
                                Fcmp.Y=-M9*Q.CR';
                            else
                                M8=0;
                                M9=0;
                                M10=0;
                                Fcmp.Y=sparse(qty.Ct,qty.Ct);
                            end
                            if QQ(2,3)
                                Fcmp.G=Q.CL';
                                Fcmp.H=-Q.CL;
                                if QQ(3,2)
                                    Fcmp.G=Fcmp.G+M5*Q.CR';
                                    Fcmp.H=Fcmp.H+M10*Q.RL;
                                end
                            else
                                Fcmp.G=sparse(qty.Lll,qty.Ct);
                                Fcmp.H=sparse(qty.Ct,qty.Lll);
                            end
                            if QQ(1,3)
                                Fcmp.Ghat=Q.EL';
                                if QQ(3,2)
                                    Fcmp.Ghat=Fcmp.Ghat+M5*Q.ER';
                                end
                            else
                                Fcmp.Ghat=sparse(qty.Lll,qty.E);
                            end
                            if QQ(3,3)&&QQ(3,4)
                                Fcmp.Fhat=M6*Q.RJ;
                            else
                                Fcmp.Fhat=sparse(qty.Lll,qty.J);
                            end
                            if QQ(2,2)&&QQ(1,2)
                                Fcmp.Yhat=-M9*Q.ER';
                            else
                                Fcmp.Yhat=sparse(qty.Ct,qty.E);
                            end
                            if QQ(2,4)
                                Fcmp.Hhat=-Q.CJ;
                                if QQ(3,2)
                                    Fcmp.Hhat=Fcmp.Hhat+M10*Q.RJ;
                                end
                            else
                                Fcmp.Hhat=sparse(qty.Ct,qty.J);
                            end
                        else

                            Gl=Bcmp.Gll;
                            if qty.Rl>0
                                Rl=inv(Gl);
                            else
                                Rl=0;
                            end
                            Rt=Bcmp.Gtt;
                            if qty.Rt>0
                                Gt=inv(Rt);
                            else
                                Gt=0;
                            end
                            R=Rl;
                            G=Gt;
                            if QQ(3,2)
                                R=R+Q.RR'*Rt*Q.RR;
                                G=G+Q.RR*Gl*Q.RR';
                            end
                            if qty.Rl>0
                                invR=inv(R);
                            else
                                invR=0;
                            end
                            if qty.Rt>0
                                invG=inv(G);
                            else
                                invG=0;
                            end



                            if QQ(2,2)
                                Fcmp.Y=Q.CR*invR*Q.CR';
                            else
                                Fcmp.Y=sparse(qty.Ct,qty.Ct);
                            end
                            if QQ(3,3)
                                Fcmp.F=Q.RL'*invG*Q.RL;
                            else
                                Fcmp.F=sparse(qty.Lll,qty.Lll);
                            end
                            if QQ(2,3)
                                Fcmp.G=Q.CL';
                                Fcmp.H=-Q.CL;
                                if QQ(3,2)
                                    Fcmp.G=Fcmp.G-Q.RL'*invG*Q.RR*Gl*Q.CR';
                                    Fcmp.H=Fcmp.H+Q.CR*invR*Q.RR'*Rt*Q.RL;
                                end
                            else
                                Fcmp.G=sparse(qty.Lll,qty.Ct);
                                Fcmp.H=sparse(qty.Ct,qty.Lll);
                            end
                            if(QQ(2,2)&&QQ(1,2))
                                Fcmp.Yhat=Q.CR*invR*Q.ER';
                            else
                                Fcmp.Yhat=sparse(qty.Ct,qty.E);
                            end
                            if(QQ(3,3)&&QQ(3,4))
                                Fcmp.Fhat=Q.RL'*invG*Q.RJ;
                            else
                                Fcmp.Fhat=sparse(qty.Lll,qty.J);
                            end
                            if QQ(1,3)
                                Fcmp.Ghat=Q.EL';
                                if QQ(3,2)
                                    Fcmp.Ghat=Fcmp.Ghat-Q.RL'*invG*Q.RR*Gl*Q.ER';
                                end
                            else
                                Fcmp.Ghat=sparse(qty.Lll,qty.E);
                            end
                            if QQ(2,4)
                                Fcmp.Hhat=-Q.CJ;
                                if QQ(3,2)
                                    Fcmp.Hhat=Fcmp.Hhat+Q.CR*invR*Q.RR'*Rt*Q.RJ;
                                end
                            else
                                Fcmp.Hhat=sparse(qty.Ct,qty.J);
                            end
                            M11=[];
                            M12=[];
                            M13=[];
                            M14=[];
                        end
                        M.M11=M11;
                        M.M12=M12;
                        M.M13=M13;
                        M.M14=M14;





                        function[Ac,Bc,Cc,Dc,vnn_ca,qty,idx]=statMatr(mod_in,PP,qty,idx,Bcmp,...
                            Fcmp,YY,branches,Q,QQ,invAtAl,idxSrc,M,circ2ssInfo,commandLine)

                            if qty.Ct>0
                                A11=Fcmp.invC*-Fcmp.Y;
                            else
                                A11=zeros(qty.Ct);
                            end
                            if qty.Lll>0
                                A22=Fcmp.invL*(-Fcmp.F);
                            else
                                A22=zeros(qty.Lll);
                            end
                            if QQ(2,3)
                                A12=Fcmp.invC*Fcmp.H;
                                A21=Fcmp.invL*Fcmp.G;
                            else
                                A12=zeros(qty.Ct,qty.Lll);
                                A21=zeros(qty.Lll,qty.Ct);
                            end
                            Ac=[A11,A12;A21,A22];

                            if qty.E>0
                                if qty.Ct>0
                                    B11=-Fcmp.invC*Fcmp.Yhat;
                                else
                                    B11=[];
                                end
                                if qty.Lll>0
                                    B21=Fcmp.invL*Fcmp.Ghat;
                                else
                                    B21=[];
                                end
                            else
                                B11=[];
                                B21=[];
                            end
                            if qty.J>0
                                if qty.Ct>0
                                    B12=Fcmp.invC*Fcmp.Hhat;
                                else
                                    B12=[];
                                end
                                if qty.Lll>0
                                    B22=-Fcmp.invL*Fcmp.Fhat;
                                else
                                    B22=[];
                                end;
                            else
                                B12=[];
                                B22=[];
                            end

                            Bc=[B11,B12;B21,B22];

                            if isstruct(YY)
                                qty.Vnn=size(YY.vnn,1);
                                qty.ib=size(YY.ib,1);
                            else
                                qty.Vnn=0;
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

                            if qty.Out>0
                                Cc=sparse(qty.Out,qty.States);
                                Dc=sparse(qty.Out,qty.In);
                            else

                                Cc=zeros(0,qty.States);
                                Dc=zeros(0,qty.In);
                            end

                            vnnNeedsTrf=0;

                            if qty.Vnn>0
                                if commandLine

                                    idxPath=idx.orgEdges([idx.E',idx.Ct',idx.Rt',idx.Ltt']);
                                    if~isempty(circ2ssInfo.rlcm)
                                        idxShorts=find(circ2ssInfo.rlcm(:,1)==circ2ssInfo.rlcm(:,2));
                                        if~isempty(idxShorts)
                                            for k=1:length(idxShorts)
                                                idx1=find(idxPath==idxShorts(k));
                                                PP(idx1,:)=zeros(length(idx1),size(PP,2));
                                            end
                                        end
                                    end
                                end

                                vnn_ca=cell(qty.Vnn,1);
                                idx.ST=zeros(1,qty.Rt2);
                                idx.VW=zeros(1,qty.Ltt);
                                for k=1:qty.Vnn
                                    node1=YY.vnn(k,2);
                                    node2=YY.vnn(k,1);
                                    if(node1>0&&node2>0)
                                        temp=PP(node1,:)-PP(node2,:);
                                    elseif(node1>0)
                                        temp=PP(node1,:);
                                    elseif(node2>0)
                                        temp=-PP(node2,:);
                                    else
                                        temp=zeros(1,qty.branches);
                                    end
                                    n=find(temp);






                                    vnn_ca{k}=[full(temp(n));branches([1,3],n)];
                                    z=length(n);
                                    vnn_ca{k}(:,1:z)=vnn_ca{k}(:,z:-1:1);
                                    for m=1:length(n)
                                        switch vnn_ca{k}(3,m)
                                        case 1

                                            idx2=find(mod_in(idx.E,1)==vnn_ca{k}(2,m));
                                            vnn_ca{k}(4,m)=idx2;
                                        case 2

                                            idx2=find(mod_in(idx.Ct,1)==vnn_ca{k}(2,m));
                                            vnn_ca{k}(4,m)=idx2;
                                        case 3

                                            idx2=find(mod_in(idx.Rt,1)==vnn_ca{k}(2,m));
                                            if idx2>qty.Rt2
                                                vnnNeedsTrf=vnnNeedsTrf+1;
                                            end
                                            vnn_ca{k}(4,m)=idx2;
                                            idx.ST(idx2)=1;
                                        case 4,

                                            idx2=find(mod_in(idx.Ltt,1)==vnn_ca{k}(2,m));
                                            vnn_ca{k}(4,m)=idx2;
                                            idx.VW(idx2)=1;
                                        end
                                    end
                                end
                                for k=1:qty.Vnn
                                    if~isempty(vnn_ca{k})
                                        vnn_ca{k}=sortrows(vnn_ca{k}',[3,4])';
                                    end
                                end
                                idx.ST=find(idx.ST);
                                idx.VW=find(idx.VW);
                            end



                            if(~isempty(idx.ST)||(~isempty(idx.ibTypes)&&(idx.ibTypes(6)||...
                                idx.ibTypes(7))))


                                if qty.Trfmr==0

                                    if qty.Rt2>0
                                        x=1:qty.Rt2;
                                        Rt=Bcmp.Gtt(x,x);
                                        Gt=inv(Rt);
                                    else
                                        Gt=[];
                                        Rt=[];
                                        x=[];
                                    end
                                    if qty.Rl2>0
                                        y=1:qty.Rl2;
                                        Gl=Bcmp.Gll(y,y);
                                        Rl=inv(Gl);
                                    else
                                        Gl=[];
                                        Rl=[];
                                        y=[];
                                    end
                                    if QQ(3,2)
                                        Q.RR=Q.RR(x,y);
                                    end
                                    if QQ(2,2)
                                        Q.CR=Q.CR(:,y);
                                    end
                                    if QQ(3,3)
                                        Q.RL=Q.RL(x,:);
                                    end
                                    if QQ(1,2)
                                        Q.ER=Q.ER(:,y);
                                    end
                                    if QQ(3,4)
                                        Q.RJ=Q.RJ(x,:);
                                    end
                                    R=Rl;
                                    G2=Gt;
                                    if QQ(3,2)
                                        R=R+Q.RR'*Rt*Q.RR;
                                        G2=G2+Q.RR*Gl*Q.RR';
                                    end
                                    t1=-inv(Rt*G2)*Rt;
                                    if QQ(2,2)&&QQ(3,2)
                                        S1=t1*Q.RR*Gl*Q.CR';
                                    elseif qty.Ct>0
                                        S1=zeros(qty.Rt,qty.Ct);
                                    else
                                        S1=[];
                                    end
                                    if QQ(3,3)
                                        S1=[S1,t1*Q.RL];
                                    elseif qty.Lll>0
                                        S1=[S1,zeros(qty.Rt,qty.Lll)];
                                    end
                                    if QQ(1,2)&&QQ(3,2)
                                        T1=t1*Q.RR*Gl*Q.ER';
                                    elseif qty.E>0
                                        T1=zeros(qty.Rt,qty.E);
                                    else
                                        T1=[];
                                    end
                                    if QQ(3,4)
                                        T1=[T1,t1*Q.RJ];
                                    elseif qty.J>0
                                        T1=[T1,zeros(qty.Rt,qty.J)];
                                    end
                                    if idx.ibTypes(7)
                                        t2=inv(Gl*R)*Gl;
                                        if QQ(2,2)
                                            S2=t2*Q.CR';
                                        else
                                            S2=zeros(qty.Rl,qty.Ct);
                                        end
                                        if QQ(3,2)&&QQ(3,3)
                                            S2=[S2,-t2*Q.RR'*Rt*Q.RL];
                                        else
                                            S2=[S2,zeros(qty.Rl,qty.Lll)];
                                        end
                                        if QQ(1,2)
                                            T2=t2*Q.ER';
                                        else
                                            T2=zeros(qty.Rl,qty.E);
                                        end
                                        if QQ(3,2)&&QQ(3,4)
                                            T2=[T2,-t2*Q.RR'*Rt*Q.RJ];
                                        else
                                            T2=[T2,zeros(qty.Rl,qty.J)];
                                        end
                                    end
                                else
                                    if QQ(2,2)&&QQ(3,2)
                                        S1=M.M11*Q.CR';
                                    elseif qty.Ct>0
                                        S1=zeros(qty.Rt,qty.Ct);
                                    else
                                        S1=[];
                                    end

                                    if QQ(3,3)
                                        S1=[S1,M.M12*Q.RL];
                                    elseif qty.Lll>0
                                        S1=[S1,zeros(qty.Rt,qty.Lll)];
                                    end
                                    if QQ(1,2)&&QQ(3,2)
                                        T1=M.M11*Q.ER';
                                    elseif qty.E>0
                                        T1=zeros(qty.Rt,qty.E);
                                    else
                                        T1=[];
                                    end
                                    if QQ(3,4)
                                        T1=[T1,M.M12*Q.RJ];
                                    elseif qty.J>0
                                        T1=[T1,zeros(qty.Rt,qty.J)];
                                    end

                                    if idx.ibTypes(6)||idx.ibTypes(7)
                                        if QQ(2,2)
                                            S2=M.M13*Q.CR';
                                        else
                                            S2=zeros(qty.Rl,qty.Ct);
                                        end
                                        if QQ(3,2)&&QQ(3,3)
                                            S2=[S2,M.M14*Q.RL];
                                        else
                                            S2=[S2,zeros(qty.Rl,qty.Lll)];
                                        end
                                        if QQ(1,2)
                                            T2=M.M13*Q.ER';
                                        else
                                            T2=zeros(qty.Rl,qty.E);
                                        end
                                        if QQ(3,2)&&QQ(3,4)
                                            T2=[T2,M.M14*Q.RJ];
                                        else
                                            T2=[T2,zeros(qty.Rl,qty.J)];
                                        end
                                    end
                                end
                            end



                            if~isempty(idx.VW)
                                if qty.Mut>0
                                    t1=Bcmp.Ltl;
                                else
                                    t1=zeros(qty.Ltt,qty.Lll);
                                end



                                if~isempty(t1)
                                    t1=(t1-Bcmp.Ltt*Q.LL)*Fcmp.invL;
                                end
                                if qty.Ct>0
                                    V11=t1*Fcmp.G;
                                else
                                    V11=[];
                                end
                                V12=-t1*Fcmp.F;
                                if qty.E>0
                                    W11=t1*Fcmp.Ghat;
                                else
                                    W11=[];
                                end
                                if qty.J>0
                                    W12=-t1*Fcmp.Fhat;
                                else
                                    W12=[];
                                end
                                V1=[V11,V12];
                                W1=[W11,W12];
                            end

                            if qty.Vnn>0
                                for k=1:qty.Vnn
                                    for m=1:size(vnn_ca{k},2)
                                        n=vnn_ca{k}(4,m);
                                        signe=vnn_ca{k}(1,m);
                                        switch vnn_ca{k}(3,m)
                                        case 1
                                            Dc(k,n)=Dc(k,n)+signe;
                                        case 2
                                            Cc(k,n)=Cc(k,n)+signe;
                                        case 3

                                            if qty.States>0
                                                Cc(k,:)=Cc(k,:)+signe*S1(n,:);
                                            end
                                            if~isempty(T1)
                                                Dc(k,:)=Dc(k,:)+signe*T1(n,:);
                                            end
                                        case 4,
                                            if~isempty(V1)
                                                Cc(k,:)=Cc(k,:)+signe*V1(n,:);
                                            end
                                            if~isempty(W1)
                                                Dc(k,:)=Dc(k,:)+signe*W1(n,:);
                                            end
                                        end
                                    end
                                end
                            else
                                vnn_ca=[];
                            end

                            if qty.ib>0
                                if idx.ibTypes(3)
                                    C_iLtt=[zeros(qty.Ltt,qty.Ct),-Q.LL];
                                end

                                if idx.ibTypes(4)
                                    C_iCt=Bcmp.Ct*[A11,A12];
                                    if qty.In~=0
                                        D_iCt=Bcmp.Ct*[B11,B12];
                                    else
                                        D_iCt=zeros(qty.Ct,0);
                                    end
                                end

                                if idx.ibTypes(5)
                                    temp1=Bcmp.Cl*Q.CC';
                                    C_iCl=temp1*[A11,A12];
                                    if qty.In~=0
                                        D_iCl=temp1*[B11,B12];
                                    else
                                        D_iCl=zeros(size(temp1,1),0);
                                    end
                                end

                                if idx.ibTypes(6)
                                    if qty.Trfmr==0
                                        if qty.States>0
                                            C_iRt=Gt*S1(1:qty.Rt,:);
                                        end
                                        if qty.In>0
                                            D_iRt=Gt*T1(1:qty.Rt,:);
                                        end
                                    else
                                        C_iRt=[];
                                        if qty.States>0
                                            if qty.Ct>0
                                                if QQ(3,2)
                                                    C_iRt=-Q.RR*S2(1:qty.Rl,1:qty.Ct);
                                                else
                                                    C_iRt=zeros(qty.Rt,qty.Ct);
                                                end
                                            end
                                            if qty.Lll>0
                                                if QQ(3,2)
                                                    C_iRt=[C_iRt...
                                                    ,-Q.RR*S2(1:qty.Rl,qty.Ct+1:qty.States)-Q.RL];
                                                else
                                                    C_iRt=[C_iRt,zeros(qty.Rt,qty.Lll)];
                                                end
                                            end
                                        end

                                        D_iRt=[];
                                        if qty.In>0
                                            if qty.E>0
                                                if QQ(3,2)
                                                    D_iRt=-Q.RR*T2(1:qty.Rl,1:qty.E);
                                                else
                                                    D_iRt=zeros(qty.Rt,qty.E);
                                                end
                                            end
                                            if qty.J>0
                                                if QQ(3,2)
                                                    D_iRt=[D_iRt...
                                                    ,-Q.RR*T2(1:qty.Rl,qty.E+1:qty.In)-Q.RJ];
                                                else
                                                    D_iRt=[D_iRt,zeros(qty.Rt,qty.J)];
                                                end
                                            end
                                        end
                                    end
                                end

                                if idx.ibTypes(7)
                                    C_iRl=S2;
                                    D_iRl=T2;
                                end

                                for k=1:qty.ib
                                    l=k+qty.Vnn;
                                    for m=1:size(YY.ib{k},2)
                                        if YY.ib{k}(3,m)>1
                                            n=YY.ib{k}(4,m);
                                        else
                                            n=find(idx.Src==YY.ib{k}(2,m));
                                        end
                                        signe=YY.ib{k}(1,m);
                                        switch YY.ib{k}(3,m)
                                        case 1
                                            Dc(l,n)=Dc(l,n)+signe;
                                        case 2
                                            if qty.States>0
                                                Cc(l,n+qty.Ct)=Cc(l,n+qty.Ct)+signe;
                                            end
                                        case 3
                                            if qty.States>0
                                                Cc(l,:)=Cc(l,:)+signe*C_iLtt(n,:);
                                            end
                                        case 4
                                            if qty.States>0
                                                Cc(l,:)=Cc(l,:)+signe*C_iCt(n,:);
                                            end
                                            if qty.In>0
                                                Dc(l,:)=Dc(l,:)+signe*D_iCt(n,:);
                                            end
                                        case 5
                                            if qty.States>0
                                                Cc(l,:)=Cc(l,:)+signe*C_iCl(n,:);
                                            end
                                            if qty.In>0
                                                Dc(l,:)=Dc(l,:)+signe*D_iCl(n,:);
                                            end
                                        case 6
                                            if qty.States>0
                                                Cc(l,:)=Cc(l,:)+signe*C_iRt(n,:);
                                            end
                                            if qty.In>0
                                                Dc(l,:)=Dc(l,:)+signe*D_iRt(n,:);
                                            end
                                        case 7
                                            if qty.States>0
                                                Cc(l,:)=Cc(l,:)+signe*C_iRl(n,:);
                                            end
                                            if qty.In>0
                                                Dc(l,:)=Dc(l,:)+signe*D_iRl(n,:);
                                            end
                                        end
                                    end
                                end
                            end

                            if qty.States>0

                                idx1=[idx.orgEdges(idx.Lll),zeros(length(idx.Lll),1)];
                                idx2=[idx.orgEdges(idx.Ct),ones(length(idx.Ct),1)];
                                [scrap,idx.Svars]=sortrows([idx2;idx1],[1,2]);


                                Ac=Ac(idx.Svars,idx.Svars);
                                Cc(idx.Out,:)=Cc(:,idx.Svars);
                                if qty.In>0
                                    Bc(:,idx.Src)=Bc(idx.Svars,:);
                                end
                            end

                            if qty.In>0,
                                Dc(idx.Out,idx.Src)=Dc;
                            end








                            function[svar,src,out]=getLists(qty,idx,Q,QQ,Bcmp,Fcmp,vnn_ca,...
                                mod_in,YY,names,srcnames,outnames)


                                svar=cell(qty.States,1);
                                src=cell(qty.In,1);
                                idx1=qty.Ct;
                                idx2=qty.Lll;
                                if qty.Ct>0
                                    k=1:idx1;
                                    svar(k)=strcat('Uc_',names(idx.orgEdges(idx.Ct(k)),1));
                                end
                                if qty.Lll>0
                                    k=idx1+1:idx1+idx2;
                                    svar(k)=strcat('Il_',names(idx.orgEdges(idx.Lll(k-idx1),1)));
                                end
                                svar=svar(idx.Svars);


                                for k=1:qty.Cl
                                    svar(k+qty.States)=strcat('Uc_',names(idx.orgEdges(idx.Cl(k)),1));
                                end


                                for k=1:qty.Ltt
                                    svar(k+qty.States+qty.Cl)=...
                                    strcat('Il_',names(idx.orgEdges(idx.Ltt(k)),1));
                                end


                                idx1=idx.Src(1:qty.E);
                                idx2=idx.Src(qty.E+1:qty.E+qty.J);
                                if qty.E>0
                                    src(idx1)=strcat('U_',srcnames(idx1));
                                end
                                if qty.J>0
                                    src(idx2)=strcat('I_',srcnames(idx2));
                                end


                                out=outnames;








                                function circ2ssInfo=circ2ssDepend(qty,idx,Q,circ2ssInfo,SPS,...
                                    fid_outfile,commandLine)

                                    nb_ldep=qty.Ltt;
                                    Il_relat=[];
                                    L_combi=[];

                                    if nb_ldep>0
                                        [x,y]=find(Q.LL);
                                        x=unique(x);
                                        y=unique(y);
                                        L_combi=[idx.orgEdges(idx.Lll(y))',idx.orgEdges(idx.Ltt)'];
                                        Il_relat=([full(Q.LL(:,y)),eye(qty.Ltt)]);
                                        nb_lcombi=length(L_combi);
                                    end

                                    nb_cdep=qty.Cl;
                                    C_combi=[];
                                    Uc_relat=[];

                                    if nb_cdep>0


                                        Bf_CC=full(-Q.CC');


                                        idx1=find(Bf_CC(nb_cdep,:));
                                        mat1=idx1;
                                        C_combi=idx.orgEdges(idx.Ct(idx1))';

                                        for k=nb_cdep-1:-1:1
                                            idx1=find(Bf_CC(k,:));
                                            for m=1:length(idx1)
                                                if~any(mat1(1,:)==idx1(m))
                                                    mat1=[mat1,idx1(m)];
                                                    C_combi=[C_combi,idx.orgEdges(idx.Ct(idx1(m)))'];
                                                end
                                            end
                                        end
                                        C_combi=[C_combi,idx.orgEdges(idx.Cl(qty.Cl:-1:1))'];
                                        Uc_relat=[full(Bf_CC(qty.Cl:-1:1,mat1)),eye(nb_cdep)];
                                        nb_ccombi=length(C_combi);
                                    end

                                    nbvar=0;
                                    var_branche=[];
                                    states=[];
                                    rlc=SPS.rlc;
                                    rlc1=circ2ssInfo.rlc1;
                                    rlcm=circ2ssInfo.rlcm;

                                    for k=1:size(rlc1,1)
                                        if rlc1(k,2)~=0,
                                            nbvar=nbvar+1;
                                            str=sprintf('Il_b%g_n%g_%g',rlcm(k,7),rlcm(k,1),rlcm(k,2));
                                            states=strvcat(states,str);
                                            var_branche(nbvar,1:2)=[rlcm(k,7),0];
                                        end
                                        if rlc1(k,3)~=0,
                                            nbvar=nbvar+1;
                                            str=sprintf('Uc_b%g_n%g_%g',rlcm(k,7),rlcm(k,1),rlcm(k,2));
                                            states=strvcat(states,str);
                                            var_branche(nbvar,1:2)=[rlcm(k,7),0];
                                        end
                                    end

                                    for i=1:nb_cdep,
                                        ib=C_combi(nb_ccombi-nb_cdep+i);
                                        ivar=find(var_branche(:,1)==ib&states(:,1)=='U');
                                        var_branche(ivar,2)=i;
                                    end
                                    for i=1:nb_ldep,
                                        ib=L_combi(nb_lcombi-nb_ldep+i);
                                        ivar=find(var_branche(:,1)==ib&states(:,1)=='I');
                                        var_branche(ivar,2)=i;
                                    end
                                    if nbvar>0,
                                        [n,indice]=sort(abs(var_branche(:,2)));
                                        var_branche=var_branche(indice,:);
                                        states=states(indice,:);
                                    else
                                        states=[];
                                        var_branche=[];
                                    end
                                    nbvar1=nbvar-nb_ldep-nb_cdep;

                                    circ2ssInfo.L_combi=L_combi;
                                    circ2ssInfo.C_combi=C_combi;
                                    circ2ssInfo.Il_relat=Il_relat;
                                    circ2ssInfo.Uc_relat=Uc_relat;
                                    circ2ssInfo.nb_ldep=nb_ldep;
                                    circ2ssInfo.nb_cdep=nb_cdep;
                                    circ2ssInfo.var_branche=var_branche;
                                    if~isempty(states)
                                        circ2ssInfo.var_nom=cellstr(states);
                                    else
                                        circ2ssInfo.var_nom={};
                                    end



                                    if nb_cdep>0
                                        power_printf(fid_outfile,...
                                        '\nThe following capacitor voltages are dependent: \n');
                                        nb_cind=length(C_combi)-nb_cdep;
                                        for i=1:nb_cdep,
                                            n=C_combi(nb_cind+i);
                                            str=sprintf('Uc_b%g_n%g_%g = ',n,rlc(n,1),rlc(n,2));
                                            for n=1:nb_cind,
                                                if sign(Uc_relat(i,n))>0,
                                                    str1=' - Uc_b';
                                                elseif sign(Uc_relat(i,n))<0,
                                                    str1=' + Uc_b';
                                                end
                                                if Uc_relat(i,n)~=0
                                                    str=[str,str1,int2str(C_combi(n)),'_n',...
                                                    sprintf('%g_%g',rlc(C_combi(n),1),...
                                                    rlc(C_combi(n),2)),' '];
                                                end
                                            end
                                            power_printf(fid_outfile,[str,'\n']);
                                        end
                                    end

                                    if nb_ldep>0,
                                        power_printf(fid_outfile,...
                                        '\nThe following inductor currents are dependent: \n');
                                        nb_lind=length(L_combi)-nb_ldep;
                                        for i=1:nb_ldep,
                                            n=L_combi(nb_lind+i);
                                            str=sprintf('Il_b%g_n%g_%g = ',n,rlc(n,1),rlc(n,2));
                                            if length(find(Il_relat(i,:)~=0))==1,
                                                str=[str,'0'];
                                            else
                                                for n=1:nb_lcombi-nb_ldep,
                                                    if sign(Il_relat(i,n))>0&&abs(Il_relat(i,n))==1
                                                        str1=' - Il_b';
                                                    elseif sign(Il_relat(i,n))>0&&abs(Il_relat(i,n))~=1
                                                        str1=sprintf(' - %g*Il_b',abs(Il_relat(i,n)));
                                                    elseif sign(Il_relat(i,n))<0&&abs(Il_relat(i,n))==1
                                                        str1=' + Il_b';
                                                    elseif sign(Il_relat(i,n))<0&&abs(Il_relat(i,n))~=1
                                                        str1=sprintf(' + %g*Il_b',abs(Il_relat(i,n)));
                                                    end
                                                    if Il_relat(i,n)~=0
                                                        str=[str,str1,int2str(L_combi(n)),'_n',...
                                                        sprintf('%g_%g',rlc(L_combi(n),1),...
                                                        rlc(L_combi(n),2)),' '];
                                                    end
                                                end
                                            end
                                            power_printf(fid_outfile,[str,'\n']);
                                        end
                                    end

                                    if~commandLine
                                        power_printf(fid_outfile,'\nOutput expressions:\n');
                                        for k=1:qty.Out
                                            chaine=strrep(SPS.outstr{k},';','');
                                            y_type=SPS.ytype;


                                            if y_type(k)==0
                                                sortie=['y_u',int2str(k)];


                                            elseif y_type(k)==1
                                                sortie=['y_i',int2str(k)];
                                            end
                                            power_printf(fid_outfile,['\n',sortie,' = ',chaine]);
                                        end
                                    end



                                    function[YesitIs,BlockName,RCsnubber]=CheckIfUniversalBridgeBlock(FirstCurrentSource,SecondCurrentSource,sourcenames)








                                        YesitIs=false;
                                        BlockName='';
                                        RCsnubber=[];
                                        blockhandle_1=sourcenames(FirstCurrentSource);
                                        blockhandle_2=sourcenames(SecondCurrentSource);
                                        if isequal(blockhandle_1,blockhandle_2)
                                            MaskType=get_param(blockhandle_1,'MaskType');
                                            switch MaskType
                                            case 'Universal Bridge'
                                                YesitIs=true;
                                                BlockName=getfullname(blockhandle_1);
                                                Device=get_param(blockhandle_1,'Device');
                                                switch Device
                                                case{'Diodes','Thyristors','Ideal Switches'}
                                                    RCsnubber=1;
                                                case{'GTO / Diodes','MOSFET / Diodes','IGBT / Diodes'}
                                                    RCsnubber=0;
                                                end
                                            otherwise

                                            end
                                        end
                                        return




                                        function CheckIfPMSMBlock(FirstCurrentSource,SecondCurrentSource,sourcenames,nodes1,nodes2)








                                            blockhandle_1=sourcenames(FirstCurrentSource);
                                            blockhandle_2=sourcenames(SecondCurrentSource);

                                            if isequal(blockhandle_1,blockhandle_2)

                                                switch get_param(blockhandle_1,'MaskType')

                                                case 'Permanent Magnet Synchronous Machine'

                                                    if nodes1(1)~=nodes2(1)&&nodes1(2)==nodes2(2)

                                                        message=['The terminals of the ''',getfullname(blockhandle_1),''' block cannot be left open-circuit because they are modeled as current sources.',...
                                                        newline,'You should try to resolve the open-circuit topology or delete this block from your model.'];

                                                        Erreur.message=message;
                                                        Erreur.identifier='SpecializedPowerSystems:getABCD:BlockConnectionIssue';
                                                        psberror(Erreur);

                                                    end
                                                end
                                            end