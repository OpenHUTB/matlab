function openDialogs=getOpenDialogs(this,hModel)




    openDialogs=struct('Source',{},'Dialog',{},'Block',{});




    hOpenDlgs=DAStudio.ToolRoot.getOpenDialogs();

    for idx=1:numel(hOpenDlgs)

        hDlgItem=hOpenDlgs(idx);
        hDlgSrc=hDlgItem.getSource();








        if(isa(hDlgSrc,'PMDialogs.DynDlgSource')||...
            isa(hDlgSrc,'MECH.DialogSource')||...
            isa(hDlgSrc,'PMDialogs.PMDefaultMaskDlg'))&&...
            ~isa(hDlgSrc,'NetworkEngine.DynNeUtilDlgSource')

            thisBlock=hDlgSrc.getBlock();




            if isequal(bdroot(thisBlock.Handle),hModel.Handle)

                thisDialog.Source=hDlgSrc;
                thisDialog.Dialog=hDlgItem;
                thisDialog.Block=thisBlock;

                openDialogs(end+1)=thisDialog;

            end

        end

    end
