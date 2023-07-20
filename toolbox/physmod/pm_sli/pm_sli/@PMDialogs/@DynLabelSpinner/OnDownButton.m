function OnDownButton(hThis,hSource,widgetTag)



    tagStr=[hThis.ObjId,'.',hThis.ValueBlkParam,'.Edit'];

    tmpVal=hThis.Value-1;
    if(tmpVal>hThis.MinValue-1)
        hThis.Value=tmpVal;
        hSource.setWidgetValue(tagStr,num2str(hThis.Value))
    end



    hThis.notifyListeners(hSource,'',widgetTag);
