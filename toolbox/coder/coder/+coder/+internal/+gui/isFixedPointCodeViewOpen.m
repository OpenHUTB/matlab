function open=isFixedPointCodeViewOpen()







    try
        open=usejava('swing')&&~isempty(which('coder.internal.mlfb.gui.CodeViewManager'))&&...
        ~isempty(coder.internal.mlfb.gui.CodeViewManager.getActiveCodeView());
    catch me
        open=false;
        coder.internal.gui.asyncDebugPrint(me);
    end
end