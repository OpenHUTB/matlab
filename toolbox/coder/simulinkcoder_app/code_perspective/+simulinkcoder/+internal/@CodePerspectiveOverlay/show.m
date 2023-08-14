function dlg=show(obj,varargin)


    if nargin==1
        src=simulinkcoder.internal.util.getSource;
    else
        src=simulinkcoder.internal.util.getSource(varargin{1});
    end
    obj.src=src;

    if~isempty(src.studio)
        src.studio.show;
    end

    dlg=DAStudio.Dialog(obj);
    obj.dlg=dlg;




