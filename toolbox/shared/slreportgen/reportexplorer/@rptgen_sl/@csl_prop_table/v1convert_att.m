function att=v1convert_att(this,att,varargin)





    att=this.v1convert_table(att,varargin{:});

    switch varargin{1}
    case 'csl_mdl_proptable'
        att.ObjectType='Model';
    case 'csl_sys_proptable'
        att.ObjectType='System';
    case 'csl_blk_proptable'
        att.ObjectType='Block';
    case 'csl_sig_proptable'
        att.ObjectType='Signal';
    end
