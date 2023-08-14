function h=propsrc_sl_annotation(varargin)







    persistent RPTGEN_PROPSRC_SL_ANNOTATION

    if isempty(RPTGEN_PROPSRC_SL_ANNOTATION)
        RPTGEN_PROPSRC_SL_ANNOTATION=feval(mfilename('class'));
    end

    h=RPTGEN_PROPSRC_SL_ANNOTATION;