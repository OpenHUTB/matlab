function h=analyze(h,freq)








    ckt=get(h,'RFckt');


    if nargin<2
        freq=frequency(h);
    end


    if(isa(ckt,'rfckt.network')&&~isempty(get(ckt,'Ckts')))||...
        (~isa(ckt,'rfckt.network')&&~isempty(ckt))
        analyze(ckt,freq,ckt.AnalyzedResult.Zl,ckt.AnalyzedResult.Zs,...
        ckt.AnalyzedResult.Z0);
    end


    if(isa(ckt,'rfckt.network')&&isempty(get(ckt,'Ckts')))
        set(ckt.AnalyzedResult,'Freq',[],'S_Parameters',[],...
        'GroupDelay',[],'NF',0,'OIP3',inf);
    end


    if isa(ckt,'rfckt.rfckt')
        data=get(ckt,'AnalyzedResult');
        if isa(data,'rfbbequiv.data')
            [resp,delay]=response(h,data.transfunc);
            set(h,'ImpulseResp',resp,'Delay',delay);
        end
    end