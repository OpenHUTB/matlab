function att2=v1convert_att(this,att1,varargin)







    if strcmpi(att1.ObjectType,'fpblock')
        this.LoopType='fixed-point block';

    else


        this.LoopType=att1.ObjectType;

    end


    att2.TitleType=att1.TitleType(2:end);

    att2.TableTitle=att1.TableTitle;

    summSrc=this.summ_get;
    try
        summSrc.LoopComp=RptgenML.v1convert(att1.([att1.ObjectType,'Component']));
    catch ME
        warning('rptgen:SummaryTableLoopConvert',ME.message);
    end

    summSrc.Properties=att1.([att1.ObjectType,'Parameters']);
    summSrc.Anchor=att1.(['is',att1.ObjectType,'Anchor']);


