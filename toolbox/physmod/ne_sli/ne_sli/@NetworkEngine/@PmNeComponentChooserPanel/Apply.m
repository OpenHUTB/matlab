function retStatus=Apply(hThis)







    try


        hThis.getDlgSrcObj.ComponentName=hThis.ComponentName;
        retStatus=hThis.applyChildren();

        hSource=hThis.getDlgSrcObj;
        hSource.RequestChooser=false;
        simscape.setBlockComponent(hSource.BlockHandle,hThis.ComponentName);

    catch
        retStatus=false;
    end

end
