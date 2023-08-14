function pList=getPropList(smsrc,varargin)






    pList=smsrc.PropSrc.getPropList(varargin{:});
    pList{end+1}='%<SplitDialogParameters>';
