function spurdata=calcemixspur(h,spurdata,zl,zs,z0,cktindex,addnewspur)






    narginchk(6,7);
    if nargin==6
        addnewspur=true;
    end


    ckts=get(h,'Ckts');
    nckts=length(ckts);
    if nckts==0
        return
    end
    checkproperty(h);
    temp_ckt1=rfckt.cascade;
    temp_ckt2=rfckt.cascade;
    simdata=rfdata.network;


    fin=spurdata.Fin;
    fin(fin==0.0)=eps;
    pin=spurdata.Pin;
    for k=1:nckts
        idxin=spurdata.Idxin;
        ckts1={};ckts2={};
        for k1=1:k
            ckts1{k1}=ckts{k1};%#ok<AGROW>
        end
        set(temp_ckt1,'Ckts',ckts1);
        for k2=1:(nckts-k)
            ckts2{k2}=ckts{k+k2};%#ok<AGROW>
        end
        set(temp_ckt2,'Ckts',ckts2);
        if~isempty(ckts2)
            [ckt_type2,ckt_params2,ckt_z02]=...
            spurnwa(temp_ckt2,convertfreq(temp_ckt1,fin,'isSpurCalc',true));
            sparams2=convertmatrix(simdata,ckt_params2,ckt_type2,'S_Parameters',ckt_z02,z0);
            Zl=gamma2z(gammain(sparams2,z0,zl),z0);
        else
            Zl=50;
        end
        [pl,freq]=calcpout(temp_ckt1,pin,fin,Zl,zs,z0,'isSpurCalc',true);
        if isempty(spurdata.Pout{k+cktindex})
            psignal=max(pl);
        else
            psignal=spurdata.Pout{k+cktindex}(1);
        end
        idx=find(pl>(psignal-99));
        if~isempty(idx)
            freq=freq(idx);
            pl=pl(idx);
            idxin=idxin(idx);
            n=length(spurdata.Freq{k+cktindex});
            spurdata.Freq{k+cktindex}=[spurdata.Freq{k+cktindex};freq];
            spurdata.Pout{k+cktindex}=[spurdata.Pout{k+cktindex};pl];
            nfreq=length(freq);
            for ii=1:nfreq
                spurdata.Indexes{k+cktindex}{n+ii,1}=idxin{ii};
            end
        end
    end


    if addnewspur
        for k=1:nckts
            ckts2={};
            if isa(ckts{k},'rfckt.mixer')&&isa(ckts{k}.MixerSpurData,'rfdata.mixerspur')
                for k2=1:(nckts-k)
                    ckts2{k2}=ckts{k+k2};%#ok<AGROW>
                end
                set(temp_ckt2,'Ckts',ckts2);
                if~isempty(ckts2)
                    [ckt_type2,ckt_params2,ckt_z02]=...
                    spurnwa(temp_ckt2,spurdata.Freq{k+1}(1),'isSpurCalc',true);
                    sparams2=convertmatrix(simdata,ckt_params2,ckt_type2,'S_Parameters',ckt_z02,z0);
                    Zl=gamma2z(gammain(sparams2,z0,zl),z0);
                else
                    Zl=z0;
                end
                spurdata.NMixers=spurdata.NMixers+1;
                spurdata.Fin=spurdata.Freq{k+1}(1);
                spurdata.Pin=spurdata.Pout{k+1}(1);
                spurdata=addmixspur(ckts{k},spurdata,Zl,zs,z0,k);
                spurdata=calcemixspur(temp_ckt2,spurdata,zl,zs,z0,k+1,false);
            end
        end
    end