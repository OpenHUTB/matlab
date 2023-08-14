function s_params=cascadesparams(sparamdata,nconn)










    narginchk(2,2)

    numsparams=numel(sparamdata);
    s_params=sparamdata{1};
    [~,numports,numfreq]=size(s_params);

    if isequal(nconn,'default')
        checkdefaultportsizes(numports,numports)
        nconn=(numports/2)*ones(numsparams-1,1);

        for ii=2:numsparams

            sj_params=sparamdata{ii};
            [~,np,nf]=size(sj_params);



            checksparamsamples(numfreq,nf)


            checkdefaultportsizes(numports,np)
        end
    else

        if isscalar(nconn)
            nconn=nconn*ones(numsparams-1,1);
        end


        checkConnectionVector(nconn,numsparams)


        num_external_ports=0;
        for ii=1:numsparams-1


            sj_params=sparamdata{ii+1};
            [~,np,nf]=size(sj_params);
            n=nconn(ii);



            checksparamsamples(numfreq,nf)



            checkgeneralportsizes(n,numports,np)


            num_external_ports=num_external_ports+(numports-n);



            numports=np-n;
        end



        num_external_ports=num_external_ports+numports;


        checkNumExternalPorts(num_external_ports)
    end



    for ii=1:numsparams-1

        s_params=cascadenportsparams(s_params,sparamdata{ii+1},nconn(ii));
    end

    function checkConnectionVector(nconn,nsparams)
        if any(nconn~=floor(nconn))||any(nconn<1)||length(nconn)~=nsparams-1

            error(message('rf:cascadesparams:NotvalidN'))
        end

        function checkNumExternalPorts(num_external_ports)
            if num_external_ports==0

                error(message('rf:cascadesparams:NoExternalPorts'))
            end

            function checksparamsamples(nfreq1,nfreq2)
                if(nfreq1~=nfreq2)

                    error(message('rf:cascadesparams:SParamNumSamplesNotMatching'))
                end

                function checkdefaultportsizes(k,p)
                    if(k~=p)||(ceil(p/2)~=floor(p/2))

                        error(message('rf:cascadesparams:SParamNotMatching'))
                    end

                    function checkgeneralportsizes(n,k,p)
                        if(k<n)||(p<n)



                            error(message('rf:cascadesparams:WrongNetworkForGeneralCascade'))
                        end

                        function s_params=cascadenportsparams(s1_params,s2_params,n)


                            [~,k,m]=size(s1_params);
                            p=size(s2_params,1);
                            s1_params=s1_params([k-n+1:k,1:k-n],[k-n+1:k,1:k-n],:);


                            s_params=zeros(k+p-2*n,k+p-2*n,m);


                            I=eye(n);
                            for idx=1:m
                                if k>n
                                    S1=s1_params(1:n,1:n,idx);
                                    S2=s1_params(1:n,n+1:k,idx);
                                    S3=s1_params(n+1:k,1:n,idx);
                                    S4=s1_params(n+1:k,n+1:k,idx);
                                    if p>n
                                        S5=s2_params(1:n,1:n,idx);
                                        S6=s2_params(1:n,n+1:p,idx);
                                        S7=s2_params(n+1:p,1:n,idx);
                                        S8=s2_params(n+1:p,n+1:p,idx);
                                        temp1=(I-S1*S5);
                                        temp2=S3*S5/temp1;
                                        temp3=S7/temp1;
                                        temp4=S1*S6;
                                        S_I_I=temp2*S2+S4;
                                        S_I_II=temp2*temp4+S3*S6;
                                        S_II_I=temp3*S2;
                                        S_II_II=temp3*temp4+S8;
                                        s_params(:,:,idx)=[S_I_I,S_I_II
                                        S_II_I,S_II_II];
                                    else
                                        S5=s2_params(1:n,1:n,idx);
                                        s_params(:,:,idx)=S3*S5/(I-S1*S5)*S2+S4;
                                    end
                                else
                                    S1=s1_params(1:n,1:n,idx);
                                    S5=s2_params(1:n,1:n,idx);
                                    S6=s2_params(1:n,n+1:p,idx);
                                    S7=s2_params(n+1:p,1:n,idx);
                                    S8=s2_params(n+1:p,n+1:p,idx);
                                    s_params(:,:,idx)=S7/(I-S1*S5)*S1*S6+S8;
                                end
                            end