
function cval=getBlockDialogValue(this,slbh,propName)

    rto=get_param(slbh,'RuntimeObject');
    loc=0;
    for n=1:rto.NumRuntimePrms
        if strcmp(rto.RuntimePrm(n).Name,propName)
            loc=n;
            break;
        end
    end
    if loc==0
        error(message('hdlcoder:validate:RelayEmptyProp',propName));
    end

    cval=rto.RuntimePrm(loc).Data;

    if isempty(cval)
        error(message('hdlcoder:validate:RelayEmptyProp',propName));
    end
