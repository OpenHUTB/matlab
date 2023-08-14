
function detach(this)









    currentView=this.view.getCurrentView();
    if~isempty(currentView)
        currentView.setSelectedObject(this);
    end


    reqDisconnectFromDataReq(this,false);



    function reqDisconnectFromDataReq(thisObj,deleteSelf)

        objChildren=thisObj.children;
        for n=length(objChildren):-1:1

            reqDisconnectFromDataReq(objChildren(n),true);


        end

        thisObj.children=[];

        if deleteSelf


            markups=thisObj.Markups;
            for n=length(markups):-1:1
                markups(n).delete;
            end


            thisObj.detachDataObj();
            thisObj.delete;
        end
    end
end
