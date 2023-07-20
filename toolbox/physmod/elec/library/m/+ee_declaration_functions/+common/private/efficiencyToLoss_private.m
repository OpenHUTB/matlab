function loss=efficiencyToLoss_private(w,T,eff)%#codegen




    coder.allowpcode('plain');


    n_w=numel(w);
    n_T=numel(T);
    dims=size(eff);

    if dims(1)~=n_w||dims(2)~=n_T



        loss=zeros(dims);

    else

        n_wT=n_w*n_T;
        n_d=prod(dims);
        n_page=n_d/n_wT;


        mech_power=w(:)*T(:)';
        idx_13=find(mech_power>0);
        idx_24=find(mech_power<0);


        effByPage=reshape(eff,n_wT,n_page);
        lossByPage=zeros(size(effByPage));


        for i=1:n_page
            effDataThisPage=effByPage(:,i);
            eta=0.01*effDataThisPage;
            lossThisPage=zeros(n_wT,1);
            lossThisPage(idx_13)=mech_power(idx_13).*(1./eta(idx_13)-1);
            lossThisPage(idx_24)=mech_power(idx_24).*(eta(idx_24)-1);
            lossByPage(:,i)=lossThisPage;
        end


        loss=reshape(lossByPage,dims);

    end

end