function varargout=hdlblockdialog(blkName)









    if nargin<1
        blkName='';
    end

    if isempty(blkName)
        return;
    end

    x=slprops.hdlblkdlg(blkName);
    dlg=DAStudio.Dialog(x);

    if nargout>0
        varargout{1}=dlg;
    end
