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


    set(ckt,'DoAnalysis',true);
    [type,sdata,z0]=nwa(ckt,freq);
    data=getdata(ckt);


    set(data,'S_Parameters',sdata,'Freq',freq,'Z0',z0);
    set(ckt,'DoAnalysis',false);


    M=length(freq);
    s11=sdata(1,1,:);
    s11(s11==1)=1-eps;
    netparameters(1,1,:)=s11;
    netparameters(2,1,:)=deal(1);
    netparameters(1,2,1:M)=deal(0);
    netparameters(2,2,1:M)=deal(0);
