function[type,netparameters,z0]=nwa(h,freq)









    ckt=get(h,'OriginalCkt');


    if isa(ckt.AnalyzedResult,'rfdata.data')&&...
        hasp2dreference(ckt.AnalyzedResult)
        type='S_Parameters';
        z0=ckt.AnalyzedResult.Z0;
        netparameters=zeros(2,2,length(freq));
        netparameters(1,1,:)=0;
        netparameters(2,1,:)=1;
        netparameters(1,2,:)=1;
        netparameters(2,2,:)=0;
        return
    end


    [type,sdata,z0]=nwa(ckt,freq);

    set(ckt,'DoAnalysis',true);


    M=length(freq);
    if h.EqualToOriginal==false
        netparameters(1,1,1:M)=deal(0);
        netparameters(2,1,1:M)=sdata(2,1,:);
        netparameters(1,2,:)=deal(0);
        netparameters(2,2,:)=sdata(2,2,:);
    else
        netparameters=sdata;
    end