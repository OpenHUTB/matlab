function[orderMuxcell,muxVal,orderMux1]=getSerialMuxOrder(this,matrix2order,pp,ssi)





    mults=numel(ssi);

    df=size(matrix2order,1);


    rpp=pp;
    rotated_m2o=matrix2order;
    pfl=sum(ssi);



    for n=1:size(rotated_m2o,1);
        phasen=rotated_m2o(n,:);
        phase_wozeros=phasen(rpp(n,:)~=0);
        pp_pushedzeros(n,:)=[phase_wozeros,zeros(1,pfl-length(phase_wozeros))];
    end

    ssi=sort(ssi,'descend');
    refcols=ssi-[ssi(2:end),0];
    refcols=[refcols(end),refcols(end-1:-1:1)];
    orderMux1=[];

    for phase=1:df
        pn=pp_pushedzeros(phase,:)';
        rowstrt=1;
        rowend=mults;
        colstrt=1;
        colend=0;
        cntstrt=1;
        orderMux=zeros(mults,ssi(1));
        for n=1:numel(refcols)
            colend=refcols(n)+colend;
            count=(rowend-rowstrt+1)*refcols(n);
            pnpick=pn(cntstrt:cntstrt+count-1);
            cntstrt=cntstrt+count;
            orderMux(rowstrt:rowend,colstrt:colend)=reshape(pnpick,rowend-rowstrt+1,colend-colstrt+1);
            colstrt=colstrt+refcols(n);
            rowend=rowend-1;
        end
        orderMux1=[orderMux1,orderMux];
    end

    muxVal=cell(mults,1);
    orderMuxcell=cell(mults,1);

    for n=1:mults
        indx_non_zerovals=find(orderMux1(n,:));
        muxVal{n}=mod(indx_non_zerovals,df*ssi(1));
        orderMuxcell{n}=orderMux1(n,indx_non_zerovals);
    end


