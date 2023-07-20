function doDeleteItem(dlgSrc,dialogH)



    if~isempty(dlgSrc.reqItems)


        this_link=dlgSrc.reqItems(dlgSrc.reqIdx);
        if strcmp(this_link.reqsys,'doors')||~this_link.linked
            protectSurrogateLinks=rmi.settings_mgr('get','protectSurrogateLinks');

            if isempty(protectSurrogateLinks)
                dialogTitle=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DeleteDoorsSurrogateItem'));
                dialogMessage={getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:AboutToDeleteSurrogateItem')),...
                [getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:SuchLinksCreatedDuringSync')),' ',...
                getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:PleaseIndicatePreferredAction')),' ',...
                getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:WillNotAskAgain'))],...
                getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:CancelRemainUnset'))};
                reply=questdlg(dialogMessage,dialogTitle,...
                getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:Keep')),...
                getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:Delete')),...
                getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:Cancel')),...
                getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:Keep')));
                if isempty(reply)||strcmp(reply,getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:Cancel')))
                    return
                end
                if strcmp(reply,getString(message('Slvnv:reqmgt:LinkSet:doDeleteItem:Delete')))
                    protectSurrogateLinks=false;
                else
                    protectSurrogateLinks=true;
                end
                rmi.settings_mgr('set','protectSurrogateLinks',protectSurrogateLinks);
            end

            if protectSurrogateLinks
                return
            end
        end

        dlgSrc.reqItems(dlgSrc.reqIdx)=[];
        dlgSrc.typeItems(dlgSrc.reqIdx)=[];
        dlgSrc.reqIdx=dlgSrc.reqIdx-1;

        dialogH.enableApplyButton(true);
    end
    dialogH.refresh();
end
