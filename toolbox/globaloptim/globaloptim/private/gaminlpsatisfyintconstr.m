function x=gaminlpsatisfyintconstr(x,lb,ub,intcon)











    x(intcon)=i_SatisfyIntConstr(x(intcon),lb(intcon),ub(intcon));

    function intvar=i_SatisfyIntConstr(var,varlb,varub)







        var=var(:)';
        varlb=varlb(:)';
        varub=varub(:)';


        nVar=numel(var);


        intvar=zeros(1,nVar);


        idxFloor=rand(1,nVar)<0.5;
        idxCeil=~idxFloor;


        intvar(idxFloor)=i_Floor(var(idxFloor),varlb(idxFloor));
        intvar(idxCeil)=i_Ceil(var(idxCeil),varub(idxCeil));

        function intvar=i_Floor(var,varlb)

            intvar=floor(var);



            idxLowerThanLB=intvar<varlb;
            intvar(idxLowerThanLB)=ceil(var(idxLowerThanLB));

            function intvar=i_Ceil(var,varub)

                intvar=ceil(var);



                idxGreaterThanUB=intvar>varub;
                intvar(idxGreaterThanUB)=floor(var(idxGreaterThanUB));
