function out=eval_to_real_scalar(str,description,varargin)







    disallowInf=1;

    if nargin>2
        disallowInf=varargin{1};
    end

    try
        out=evalin('base',str);
    catch noEvalErr
        out=[];
        errordlg(getString(message('sigbldr_ui:eval_to_real_scalar:CannotEvaluate',description,str,noEvalErr.message)));
        return;
    end

    if any([length(out)>1,abs(imag(out))>0,isnan(out)])||any(isinf(out)*disallowInf)

        errordlg(getString(message('sigbldr_ui:eval_to_real_scalar:NeedRealScalar',description)));
        out=[];
    end
