function cicrate=resolveTBRateStimulus(this)






    tbratestim=hdlgetparameter('tb_rate_stimulus');
    if~isempty(tbratestim)
        if~(tbratestim<=this.phases&&tbratestim>0)
            error(message('HDLShared:hdlfilter:wrongTbRateStimulus',this.phases));
        else
            cicrate=tbratestim;
        end
    else
        cicrate=this.phases;
    end


