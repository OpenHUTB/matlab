function ShowHideBtnCb(this,dialog)




    switch(dialog.isVisible(this.dmsgTag))
    case false
        dialog.setVisible(this.showBtnTag,false);
        dialog.setVisible(this.hideBtnTag,true);
        dialog.setVisible(this.dmsgTag,true);
    case true
        dialog.setVisible(this.showBtnTag,true);
        dialog.setVisible(this.hideBtnTag,false);
        dialog.setVisible(this.dmsgTag,false);
    end
    dialog.resetSize(true);
end
