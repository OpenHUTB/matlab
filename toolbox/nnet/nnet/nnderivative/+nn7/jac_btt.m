function jx=jac_btt(net,P,PD,BZ,IWZ,LWZ,N,Ac,T,EW,Q,TS,hints)












































































    numLayerDelays=net.numLayerDelays;
    S=hints.totalOutputSize;
    QS=Q*S;

    if(QS*TS==0)
        jx=zeros(hints.xLen,0);
        return
    end


    gE=nndata(nn.output_sizes(net),Q,TS,-1);
    gE=remove_dont_care_errors(gE,T);


    gE=gmultiply(gE,gsqrt(EW));


    gE=nn_performance_fcn.normalize_error(net,gE,hints.perform.param);


    gE=stretch(gE);
    gE=outputs2layersE(hints,gE);


    A=cell(net.numLayers,TS);
    for i=hints.outputInd
        for ts=1:TS
            A{i,ts}=repcolint(Ac{i,numLayerDelays+ts},S);
        end
    end
    gE=nn7.dperf(net,A,gE,QS,hints);


    [gB,gIW,gLW]=nn7.grad_btt(net,P,PD,BZ,IWZ,LWZ,N,Ac,gE,Q,TS,hints,1);


    jx=zeros(hints.xLen,QS*TS);
    for ts=1:TS
        for qq=1:Q
            for ss=1:S
                ind=(ts-1)*QS+(qq-1)*S+ss;
                jx(:,ind)=formwb(net,gB(:,ind),gIW(:,:,ind),gLW(:,:,ind));
            end
        end
    end


    function gE=remove_dont_care_errors(gE,T)

        for i=1:numel(gE)
            gei=gE{i};
            gei(isnan(T{i}))=0;
            gE{i}=gei;
        end


        function gE2=stretch(gE1)


            [N,Q,TS]=nnfast.nnsize(gE1);
            S=sum(N);
            QS=Q*S;
            gE2=cell(length(N),TS);
            inputPos=0;
            for i=1:length(N)
                ni=N(i);
                for ts=1:TS
                    ge1=gE1{i,ts};
                    ge2=zeros(ni,QS);
                    for q=1:Q
                        ge2(:,(q-1)*S+inputPos+(1:ni))=diag(ge1(:,q));
                    end
                    gE2{i,ts}=ge2;
                end
                inputPos=inputPos+ni;
            end


            function e2=outputs2layersE(hints,e1)
                e2=cell(hints.numLayers,size(e1,2));
                e2(hints.outputInd,:)=e1;


                function m=repcolint(m,n)


                    mcols=size(m,2);
                    m=m(:,floor((0:(mcols*n-1))/n)+1);


