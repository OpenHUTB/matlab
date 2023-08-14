
function cval=getBlockDialogValue(this,slbh)%#ok<INUSL>

    rto=get_param(slbh,'RuntimeObject');
    biasloc=0;
    for n=1:rto.NumRuntimePrms
        if strcmp(rto.RuntimePrm(n).Name,'Bias')
            biasloc=n;
            break;
        end
    end
    if biasloc==0
        error(message('hdlcoder:validate:BiasParameterNotFound'));
    end

    cval=rto.RuntimePrm(biasloc).Data;

    if isempty(cval)
        error(message('hdlcoder:validate:BiasParameterEmpty'));
    end
