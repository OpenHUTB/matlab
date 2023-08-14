function[mydata,sourcefreq_entry]=rfblksget_vis_data(this,varargin)




    sourcefreq_entry={};

    Udata=this.Block.UserData;
    if strcmpi(get_param(bdroot,'BlockDiagramType'),'library')
        mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
    elseif isfield(Udata,'Ckt')&&isa(Udata.Ckt,'rfckt.rfckt')
        try
            myckt=analyze(Udata.Ckt,1e9);
            mydata=myckt.AnalyzedResult;
        catch
            mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
        end
    else
        mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
    end


