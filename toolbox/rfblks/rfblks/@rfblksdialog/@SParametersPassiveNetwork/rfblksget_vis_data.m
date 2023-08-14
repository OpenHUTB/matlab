function[mydata,sourcefreq_entry]=rfblksget_vis_data(this,varargin)




    sourcefreq_entry={sprintf('Same as the %s-Parameters',...
    upper(this.Block.MaskType(1)))};


    Udata=this.Block.UserData;
    if isfield(Udata,'Ckt')&&isa(Udata.Ckt,'rfckt.rfckt')...
        &&isa(Udata.Ckt.AnalyzedResult,'rfdata.data')...
        &&~isempty(Udata.Ckt.AnalyzedResult.S_Parameters)
        mydata=Udata.Ckt.AnalyzedResult;
    else
        mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
    end


