function hObj=doloadobj(hObj)







    setappdata(hObj,'RepairUICOnLoad',true)

    hObj.Ruler.doLoadCorrection();
end