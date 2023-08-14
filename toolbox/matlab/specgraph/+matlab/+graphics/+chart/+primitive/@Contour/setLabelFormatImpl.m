function newFormat=setLabelFormatImpl(hObj,newFormat)





    levelList=getLevelListImpl(hObj);



    oldLabelCache=hObj.LabelCache;
    hObj.LabelCache=struct();

    try


        createLabelStrings(hObj,levelList,newFormat);
    catch err
        hObj.LabelCache=oldLabelCache;
        throwAsCaller(err);
    end
