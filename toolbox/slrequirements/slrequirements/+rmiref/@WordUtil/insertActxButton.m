function insertActxButton(thisDoc,thisSelection,actxId,bitmap,navcmd,dispstr)
    newShape=thisDoc.InlineShapes.AddOLEControl(actxId,thisSelection.Range);
    newShape.Height=15;
    newShape.Width=15;
    slrefobj=newShape.OLEFormat.object;
    slrefobj.ToolTipString=dispstr;
    slrefobj.MLEvalString=navcmd;

    if~isempty(bitmap)
        rmiref.actx_picture(slrefobj,bitmap);
    end
end
