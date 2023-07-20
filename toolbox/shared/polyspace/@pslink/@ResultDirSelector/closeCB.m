function closeCB(hObj,closeAction)




    switch lower(closeAction)

    case 'ok'


    case{'cancel','close'}

        hObj.selectedItem='';
    end

