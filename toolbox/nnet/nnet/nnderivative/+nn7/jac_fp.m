function jx=jac_fp(net,P,PD,BZ,IWZ,LWZ,N,Ac,T,EW,Q,TS,hints)












































































    numLayerDelays=net.numLayerDelays;
    S=hints.totalOutputSize;
    QS=Q*S;


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


    [gB,gIW,gLW]=nn7.grad_fp(net,P,PD,BZ,IWZ,LWZ,N,Ac,gE,Q,TS,hints,1);


    inputLearn=hints.inputLearn;
    layerLearn=hints.layerLearn;
    biasLearn=hints.biasLearn;
    inputWeightInd=hints.inputWeightInd;
    layerWeightInd=hints.layerWeightInd;
    biasInd=hints.biasInd;


    jx=zeros(hints.xLen,QS*TS);
    for ss=1:S
        for qq=1:Q
            for ts=1:TS
                colInd=(ts-1)*QS+(qq-1)*S+ss;
                for i=1:net.numLayers
                    for j=find(inputLearn(i,:))
                        jx(inputWeightInd{i,j},colInd)=gIW{i,j,colInd}(:);
                    end
                    for j=find(layerLearn(i,:))
                        jx(layerWeightInd{i,j},colInd)=gLW{i,j,colInd}(:);
                    end
                    if biasLearn(i)
                        jx(biasInd{i},colInd)=gB{i,colInd}(:);
                    end
                end
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
                    m=m(:,floor([0:(mcols*n-1)]/n)+1);


