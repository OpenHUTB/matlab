function OnChkBoxChange(hThis,dlgSrc,widgetVal,tagVal)





    if(~hThis.ResolveBuddyTags)
        hThis.ResolveBuddyTags=lResolveBuddyTags(hThis,dlgSrc);
    end

    if(isempty(hThis.MyTag))
        tmpTags=lFindWidgetTag(dlgSrc,hThis.ObjId);
        hThis.MyTag=tmpTags{1};
    end
    curVal=dlgSrc.getWidgetValue(hThis.MyTag);
    enableStatus=curVal;

    nBuds=numel(hThis.BuddyItemsTags);
    for idx=1:nBuds
        tagName=hThis.BuddyItemsTags{idx};
        dlgSrc.setEnabled(tagName,enableStatus);
    end


    hThis.notifyListeners(dlgSrc,widgetVal,tagVal);

end

function retVal=lResolveBuddyTags(hThis,hDlgSrc)





    retVal=false;%#ok
    hThis.BuddyItemsTags={};
    nBuds=numel(hThis.BuddyItems);
    for(idx=1:nBuds)
        tagName=hThis.BuddyItems(idx).ObjId;
        lTags=lFindWidgetTag(hDlgSrc,tagName);
        hThis.BuddyItemsTags={hThis.BuddyItemsTags{:},lTags{:}};
    end
    retVal=true;
end

function widgetTag=lFindWidgetTag(hDlgSrc,tagName)




    hInteractiveMethod=DAStudio.imDialog.getIMWidgets(hDlgSrc);
    hToolObj=find(hInteractiveMethod);

    if(isempty(hToolObj))
        pm_abort('Failed to get DAStudio.Tool object handle.');
    end


    tagList=get(hToolObj(2:end),'Tag');


    isFoundLst=strfind(tagList,tagName);


    noMatchState=cellfun('isempty',isFoundLst);


    widgetTag=tagList(find(~noMatchState));
end
