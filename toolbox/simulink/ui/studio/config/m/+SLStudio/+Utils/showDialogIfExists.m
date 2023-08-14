function found=showDialogIfExists(tag,varargin)



    obj=[];
    if nargin>1
        obj=varargin{1};
    end

    tr=DAStudio.ToolRoot;
    openDlgs=tr.getOpenDialogs;
    dlgs=openDlgs.find('DialogTag',tag);
    found=false;
    for i=1:length(dlgs)
        if isempty(obj)||(dlgs(i).getSource==obj)
            if dlgs(i).isStandAlone
                dlgs(i).show;
                found=true;
                break
            end
        end
    end
end

