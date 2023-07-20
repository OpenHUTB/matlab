function out=evalJS(obj,js)


    out=[];
    dlg=obj.Dlg;
    if isa(dlg,'DAStudio.Dialog')
        tag=obj.Tag;
        jsstr=sprintf('JSON.stringify(%s)',js);
        obj.startTransaction();
        json=dlg.evalBrowserJS(tag,jsstr);
        out=jsondecode(json);
        dlg.evalBrowserJS(tag,'qe.done()');
    end