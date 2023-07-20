function Sobj=sparameters(ckt,freq,varargin)


















































    narginchk(2,3)


    if~isscalar(ckt)
        validateattributes(ckt,{'circuit'},{'scalar'},...
        'sparameters','Circuit',1)
    end


    if~isempty(ckt.Parent)

        error(message('rflib:shared:SParametersCircuitNotTop'))
    end


    if ckt.NumPorts==0

        error(message('rf:rfcircuit:circuit:calc_sparams:NoPorts'))
    end


    rf.internal.checkfreq(freq)
    numfreq=length(freq);


    if nargin==3
        z0=varargin{1};
        rf.internal.checkz0(z0)
    else
        z0=50;
    end


















    flatobj=rf.internal.circuit.Flattener;
    [elems,conn,flatports,numnodes,has0]=flatobj.flattencircuit(ckt);
    numports=numel(flatports);
    portnodes=cell2mat(flatports)+has0;


    elems(end+1:end+numports)=resistor(z0);
    conn=[conn;flatports];
    numelems=numel(elems);









    cI=zeros(2*numelems,1);
    cJ=cI;
    cVal=cI;
    cidx=0;






    gI=zeros(numnodes+5*numelems,1);
    gI(1:numnodes)=1:numnodes;
    gJ=gI;
    gVal=gI;
    gVal(1:numnodes)=-1*eps;
    gidx=numnodes;



    numbranches=0;
    totalNPortBranches=0;
    hasInfLC=false;
    nportinfo=cell(0,4);
    for eidx=1:numelems
        e=elems(eidx);
        if isa(e,'rf.internal.circuit.RLC')
            nodes=conn{eidx}+has0;



            if nodes(1)~=nodes(2)
                numbranches=numbranches+1;
                thisbranch=numnodes+numbranches;



                gidx=gidx+1;
                gI(gidx)=nodes(1);
                gJ(gidx)=thisbranch;
                gVal(gidx)=-1;



                gidx=gidx+1;
                gI(gidx)=nodes(2);
                gJ(gidx)=thisbranch;
                gVal(gidx)=1;


                gidx=gidx+1;
                gI(gidx)=thisbranch;
                switch class(e)
                case 'resistor'
                    Re=e.Resistance;
                    if isinf(Re)

                        gJ(gidx)=thisbranch;
                        gVal(gidx)=1;
                    else

                        gJ(gidx)=thisbranch;
                        gVal(gidx)=Re;

                        gidx=gidx+1;
                        gI(gidx)=thisbranch;
                        gJ(gidx)=nodes(1);
                        gVal(gidx)=-1;

                        gidx=gidx+1;
                        gI(gidx)=thisbranch;
                        gJ(gidx)=nodes(2);
                        gVal(gidx)=1;
                    end
                case 'capacitor'
                    Ce=e.Capacitance;
                    if isinf(Ce)
                        hasInfLC=true;

                        gJ(gidx)=nodes(1);
                        gVal(gidx)=1;

                        gidx=gidx+1;
                        gI(gidx)=thisbranch;
                        gJ(gidx)=nodes(2);
                        gVal(gidx)=-1;
                    else

                        gJ(gidx)=thisbranch;
                        gVal(gidx)=1;

                        cidx=cidx+1;
                        cI(cidx)=thisbranch;
                        cJ(cidx)=nodes(1);
                        cVal(cidx)=-1*Ce;

                        cidx=cidx+1;
                        cI(cidx)=thisbranch;
                        cJ(cidx)=nodes(2);
                        cVal(cidx)=Ce;
                    end
                case 'inductor'
                    Le=e.Inductance;
                    if isinf(Le)
                        hasInfLC=true;

                        gJ(gidx)=thisbranch;
                        gVal(gidx)=1;
                    else

                        gJ(gidx)=nodes(1);
                        gVal(gidx)=-1;

                        gidx=gidx+1;
                        gI(gidx)=thisbranch;
                        gJ(gidx)=nodes(2);
                        gVal(gidx)=1;

                        cidx=cidx+1;
                        cI(cidx)=thisbranch;
                        cJ(cidx)=thisbranch;
                        cVal(cidx)=Le;
                    end
                end
            end
        else










            elemnumports=e.NumPorts;
            nodes=reshape(conn{eidx},elemnumports,2)+has0;
            elems(eidx)=nport(sparameters(e,freq,z0));


            notshort=find(nodes(:,1)~=nodes(:,2)).';
            nportinfo=[nportinfo;...
            {eidx,numbranches+1,nodes,notshort}];%#ok<AGROW>
            numbranches=numbranches+elemnumports;
            totalNPortBranches=totalNPortBranches+elemnumports;
        end
    end

    if hasInfLC&&freq(1)==0

        error(message('rf:rfcircuit:circuit:calc_sparams:InfLCWithFreqZero'))
    end


    uI=zeros(2*numports,1);
    uJ=uI;
    uVal=uI;
    uidx=0;
    for n=1:numports
        nodes=portnodes(n,:);
        if nodes(1)~=nodes(2)
            uidx=uidx+1;
            uI(uidx)=nodes(1);
            uJ(uidx)=n;
            uVal(uidx)=-1/z0;

            uidx=uidx+1;
            uI(uidx)=nodes(2);
            uJ(uidx)=n;
            uVal(uidx)=1/z0;
        end
    end

    numeqn=numnodes+numbranches;
    G=sparse(gI(1:gidx),gJ(1:gidx),gVal(1:gidx),numeqn,numeqn);
    C=sparse(cI(1:cidx),cJ(1:cidx),cVal(1:cidx),numeqn,numeqn);
    U=sparse(uI(1:uidx),uJ(1:uidx),uVal(1:uidx),numeqn,numports);




    npI=zeros(2*totalNPortBranches,1);
    npJ=npI;
    npVal=npI;
    npidx=0;
    for npcntr=1:size(nportinfo,1)
        nodes=nportinfo{npcntr,3};
        branch=numnodes+nportinfo{npcntr,2};


        for nn=nportinfo{npcntr,4}



            npidx=npidx+1;
            npI(npidx)=nodes(nn,1);
            npJ(npidx)=branch;
            npVal(npidx)=-1;



            npidx=npidx+1;
            npI(npidx)=nodes(nn,2);
            npJ(npidx)=branch;
            npVal(npidx)=1;

            branch=branch+1;
        end
    end
    N=sparse(npI(1:npidx),npJ(1:npidx),npVal(1:npidx),numeqn,numeqn);


    Sdata=zeros(numports,numports,numfreq);
    ws=warning;
    warning('off','MATLAB:nearlySingularMatrix')
    warning('off','MATLAB:singularMatrix')
    for fidx=1:numfreq


        Nfidx=N;
        for npcntr=1:size(nportinfo,1)


            e=elems(nportinfo{npcntr,1});
            nodes=nportinfo{npcntr,3};


            elemS=e.NetworkData;
            elemNP=elemS.NumPorts;
            elemdata=elemS.Parameters(:,:,fidx);
            elemZ0=elemS.Impedance;


            branch=nportinfo{npcntr,2};
            brange=numnodes+(branch:(branch+elemNP-1));










            for np1=1:elemNP

                icoeff=elemZ0*elemdata(np1,:);
                icoeff(np1)=icoeff(np1)+elemZ0;
                Nfidx(brange(np1),brange)=icoeff;%#ok<SPRIX>



                for np2=nportinfo{npcntr,4}
                    Nfidx(brange(np1),nodes(np2,:))=...
                    Nfidx(brange(np1),nodes(np2,:))+...
                    (elemdata(np1,np2)-(np1==np2))*[1,-1];%#ok<SPRIX>
                end

                branch=branch+1;
            end
        end





        J=Nfidx+G+1i*2*pi*freq(fidx)*C;

        if isreal(J)&&issymmetric(J(2:end,2:end))&&issparse(J)



            [L,D,P,S,~,rk]=ldl(J(2:end,2:end));
            D=D+blkdiag(sparse(rk,rk),speye(size(J,1)-rk-1));
            x=S*(P*(L'\(D\(L\(P'*(S*U(2:end,:)))))));
        else
            x=J(2:end,2:end)\U(2:end,:);
        end
        X=[zeros(1,numports);full(x)];


        portV=X(portnodes(:,1),:)-X(portnodes(:,2),:);
        Sdata(:,:,fidx)=2*portV-eye(numports);
    end
    warning(ws)


    Sobj=sparameters(Sdata,freq,z0);