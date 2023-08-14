function cicrate=resolveTBRateStimulus(this)






    cicstage=[];
    for n=1:length(this.Stage)
        if isa(this.Stage(n),'hdlfilter.abstractcic')
            cicstage=[cicstage,n];
        end
    end
    if numel(cicstage)>1
        error(message('HDLShared:hdlfilter:unsupportedcascade'));
    end

    tbratestim=hdlgetparameter('tb_rate_stimulus');
    if~isempty(tbratestim)
        if~(tbratestim<=this.Stage(cicstage).phases&&tbratestim>0)
            error(message('HDLShared:hdlfilter:wrongTbRateStimulus',this.Stage(cicstage).phases));
        else
            cicrate=tbratestim;
        end
    else
        cicrate=this.Stage(cicstage).phases;
    end


