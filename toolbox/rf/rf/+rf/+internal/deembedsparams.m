function s2_params=deembedsparams(s_params,s1_params,s3_params)





    CheckNetworkData(s_params,'2N','S_PARAMS');
    CheckNetworkData(s1_params,'2N','S1_PARAMS');
    CheckNetworkData(s3_params,'2N','S3_PARAMS');

    sizeS=size(s_params);
    sizeS1=size(s1_params);
    sizeS3=size(s3_params);

    if any(sizeS~=sizeS1)||any(sizeS~=sizeS3)
        error(message('rf:deembedsparams:SParamNotMatching'))
    end


    s2_params=deembednportsparams(s_params,s1_params,sizeS(1)/2,1);
    s2_params=deembednportsparams(s2_params,s3_params,sizeS(1)/2,2);

    if anynan(s2_params)

        error(message('rf:deembedsparams:ResultIsNaN'))
    end

    function s2_params=deembednportsparams(s_params,s1_params,n,type)


        [p,k,m]=size(s_params);


        s2_params=zeros(k+p-2*n,k+p-2*n,m);


        if type==1
            s1_params=s1_params([k-n+1:k,1:k-n],[k-n+1:k,1:k-n],:);
        end
        I=eye(n);
        for idx=1:m
            S_I_I=s_params(1:n,1:n,idx);
            S_I_II=s_params(1:n,n+1:k,idx);
            S_II_I=s_params(n+1:k,1:n,idx);
            S_II_II=s_params(n+1:k,n+1:k,idx);
            S1=s1_params(1:n,1:n,idx);
            S2=s1_params(1:n,n+1:k,idx);
            S3=s1_params(n+1:k,1:n,idx);
            S4=s1_params(n+1:k,n+1:k,idx);
            if type==1
                S5=(I+S3\(S_I_I-S4)/S2*S1)\(S3\(S_I_I-S4))/S2;
                S6=(S3*(I+S5/(I-S1*S5)*S1))\S_I_II;
                S7=S_II_I/S2*(I-S1*S5);
                S8=S_II_II-S7/(I-S1*S5)*S1*S6;
            else
                temp1=S3\(S_II_II-S4);
                S5=temp1/(S2+S1*temp1);
                S6=(I-S5*S1)/S3*S_II_I;
                S7=S_I_II/(S1/(I-S5*S1)*S5*S2+S2);
                S8=S_I_I-S7*S1/(I-S5*S1)*S6;
            end
            s2_params(:,:,idx)=[S5,S6;S7,S8];
        end
        if type==2
            s2_params=s2_params([k-n+1:k,1:k-n],[k-n+1:k,1:k-n],:);
        end
