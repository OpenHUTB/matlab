







function clearSelectedObjectsUponDeletion(this,clearObj,forceClear)






    if(nargin<3)
        forceClear=false;
    end

    if forceClear


        this.setSelectedObject(slreq.das.ReqLinkBase.empty());


        this.linkTargetReqObject=slreq.das.ReqLinkBase.empty();


        if~isempty(this.requirementsEditor)
            this.requirementsEditor.clearCurrentObj(clearObj,forceClear);
        end


        if~isempty(this.spreadsheetManager)
            this.spreadsheetManager.clearCurrentObj(clearObj,forceClear);
        end




        if~isempty(this.spreadSheetDataManager)
            this.spreadSheetDataManager.removeReqLinkSetFromSpreadSheetData(clearObj);
        end


        return;
    end


    slreq.utils.assertValid(clearObj);





    reqData=slreq.data.ReqData.getInstance();


    clearObj=reqData.collectDASObjects(clearObj);


    for i=1:length(clearObj)
        obj=clearObj{i};


        if(isempty(this.currentObject)&&isempty(obj))||any(this.currentObject==obj)
            this.setSelectedObject(slreq.das.ReqLinkBase.empty());
        end


        if(isempty(this.linkTargetReqObject)&&isempty(obj))||any(this.linkTargetReqObject==obj)
            this.linkTargetReqObject=slreq.das.ReqLinkBase.empty();
        end


        if~isempty(this.requirementsEditor)
            this.requirementsEditor.clearCurrentObj(obj,forceClear);
        end


        if~isempty(this.spreadsheetManager)
            this.spreadsheetManager.clearCurrentObj(obj,forceClear);
        end



        if~isempty(this.spreadSheetDataManager)
            this.spreadSheetDataManager.removeReqLinkSetFromSpreadSheetData(obj);
        end
    end

end
