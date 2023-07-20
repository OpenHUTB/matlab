function[bookMark,bookMarkIdx,bookMarkEntries]=getBookMarkEntries(h)



    persistent LocationTypesChars LocIdxTbl LocCnt;

    if isempty(LocationTypesChars)
        LocationTypesChars=linktypes.rmiLocationTypes();
        LocCnt=size(LocationTypesChars,1);
        locCharAsci=strcat(LocationTypesChars{:,1})+0;
        LocIdxTbl=zeros(max(locCharAsci),1);
        LocIdxTbl(locCharAsci)=1:LocCnt;
    end

    bookMarkIdx=0;
    bookMark='';
    linkTypes=rmi.linktype_mgr('all');

    if h.reqIdx==0||isempty(h.typeItems)||h.typeItems(h.reqIdx)==0
        bookMarkEntries=LocationTypesChars(:,2)';
    else


        typeIdx=h.typeItems(h.reqIdx);
        linkType=linkTypes(typeIdx);
        locationId=h.reqItems(h.reqIdx).id;

        if~isempty(locationId)&&~isempty(linkType.ItemIdFcn)

            try
                bookMark=feval(linkType.ItemIdFcn,h.reqItems(h.reqIdx).doc,locationId,false);
            catch Mex


                warning(Mex.identifier,'%s',Mex.message);
                bookMark=locationId;
            end
        else

            bookMark=locationId;
        end

        if(~isempty(bookMark))
            firstChar=bookMark(1);
            charIdx=find(firstChar==linkType.LocDelimiters);
            if~isempty(charIdx)
                bookMarkIdx=charIdx-1;
                bookMark=bookMark(2:end);
            end
        end

        if~isempty(h.reqItems)&&~h.reqItems(h.reqIdx).linked

            bookMarkEntries={};
        else
            locIdc=LocIdxTbl(linkType.LocDelimiters+0);
            locIdc(locIdc==0)=[];
            bookMarkEntries=LocationTypesChars(locIdc,2)';
        end
    end
end
