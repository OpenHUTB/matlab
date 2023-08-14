function this=rpt_mdl_loop_options(varargin)







    this=rptgen_sl.rpt_mdl_loop_options;

    if(rem(length(varargin),2)>0)

        connect(this,varargin{1},'up');
        varargin=varargin(2:end);
    end


    set(this,varargin{:});
