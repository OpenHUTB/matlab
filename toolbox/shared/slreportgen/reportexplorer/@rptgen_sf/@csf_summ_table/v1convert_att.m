function att2=v1convert_att(this,att1,varargin)







    this.LoopType=att1.ObjectType;


    att2.TitleType=att1.TitleType(2:end);
    att2.TableTitle=att1.TableTitle;

    summSrc=this.summ_get;

    try




        switch(lower(this.LoopType))
        case 'chart'

            v1LoopComp=att1.([att1.ObjectType,'Component']);
            summSrc.LoopComp=RptgenML.v1convert(v1LoopComp);
        case 'machine'


        otherwise



            try
                summSrc.LoopComp.Depth='deep';
            catch ME %#ok 

            end
        end
    catch ME
        warning('rptgen:SummaryTableLoopConvert',ME.message);
    end

    summSrc.Properties=att1.([att1.ObjectType,'Parameters']);
    summSrc.Anchor=att1.(['is',att1.ObjectType,'Anchor']);



