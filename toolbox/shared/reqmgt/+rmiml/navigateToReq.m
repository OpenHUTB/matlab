function navigateToReq(index,varargin)




    switch length(varargin)
    case 2
        fPath=varargin{1};
        id=varargin{2};
    case 1
        [fPath,remainder]=strtok(varargin{1},'|');
        id=remainder(2:end);
    case 0

        [fPath,id]=rmiml.getBookmark();
    otherwise
        error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
    end

    if isempty(id)
        error(message('Slvnv:rmiml:NoLinksForLocation',fPath));
    end

    if rmisl.isSidString(fPath)


        if rmisl.isComponentHarness(fPath)
            fPath=rmiml.harnessToModelRemap(fPath);
        end



        [isFromLib,inLibSID]=rmisl.isActiveLibRefSID(fPath);
        if isFromLib
            fPath=inLibSID;
        end
    end
    reqs=rmiml.getReqs(fPath,id);

    if index>length(reqs)
        error(message('Slvnv:rmiml:ReqIndexOutOfBounds',id,fPath,length(reqs)));
    else
        req=reqs(index);

        matchedRange=slreq.idToRange(fPath,id);
        if isempty(matchedRange)||matchedRange(end)==0


        else
            rmiut.RangeUtils.setSelection(fPath,matchedRange);
        end

        rmi.navigate(req.reqsys,req.doc,req.id,fPath);
    end
end

