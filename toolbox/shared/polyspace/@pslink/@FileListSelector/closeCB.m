function closeCB(hObj,closeAction)




    switch lower(closeAction)

    case 'ok'


        if~isempty(setxor(hObj.AdditionalFileList,hObj.pslinkcc.PSAdditionalFileList))
            hObj.pslinkcc.PSAdditionalFileList=hObj.AdditionalFileList;
            hObj.pslinkccDlg.setWidgetValue('_pslink_ConfigComp_fake_edit_for_dirty_flag_tag','fake value for dirty flag');
        end

    case{'cancel','close'}

    end


