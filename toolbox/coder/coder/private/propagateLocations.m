




function[newMessages]=propagateLocations(locations,report)

    fcns=report.inference.Functions;
    scripts=report.inference.Scripts;

    callSites={fcns.CallSites};
    N=numel(fcns);




    ii=[];jj=[];d=[];
    for i=1:N
        fcnCallSites=callSites{i};
        csc=numel(fcnCallSites);
        ii=[ii,1:csc];%#ok<AGROW>
        jj=[jj,repmat(i,1,csc)];%#ok<AGROW>
        d=[d,fcnCallSites.CalledFunctionID];%#ok<AGROW>
    end
    if isempty(ii)
        nrows=0;
    else
        nrows=double(max(ii));
    end
    fcnCallMatrix=sparse(double(ii),double(jj),double(d),nrows,double(N));
    newMessagesMap=containers.Map('KeyType','char','ValueType','any');
    visitedMessages=containers.Map('KeyType','char','ValueType','logical');
    msgCount=0;
    callers=cell(N,1);
    userVisible=cell(N,1);
    for i=1:numel(locations)
        msg=locations(i);
        h=hashFull(msg);
        if visitedMessages.isKey(h)
            continue
        end
        visitedMessages(h)=true;
        [reportable,userVisible]=isReportable(msg.FunctionID,fcns,scripts,userVisible);
        if reportable
            msgCount=msgCount+1;
            h=hash(msg);
            newMessagesMap(h)=msg;
        else
            [userVisibleCallSites,callers,userVisible]=getUserCallSites(msg.FunctionID,fcns,scripts,fcnCallMatrix,callers,userVisible);



            for j=1:size(userVisibleCallSites,1)
                fcnID=userVisibleCallSites(j,1);
                callSiteID=userVisibleCallSites(j,2);

                fcn=fcns(fcnID);
                callSite=callSites{fcnID}(callSiteID);

                newMsg=msg;
                newMsg.FunctionID=fcnID;
                newMsg.ScriptID=fcn.ScriptID;
                newMsg.TextStart=callSite.TextStart;
                newMsg.TextLength=callSite.TextLength;
                h=hash(newMsg);
                if~newMessagesMap.isKey(h)
                    newMessagesMap(h)=newMsg;
                    msgCount=msgCount+1;
                end
            end
        end
    end
    newMessagesCell=newMessagesMap.values;
    newMessages=[newMessagesCell{:}];
end

function h=hash(msg)


    assert(numel(fieldnames(msg))>=4);
    h=char(...
    msg.MsgID+"$"+...
    msg.FunctionID+"$"+...
    msg.TextStart+"$"+...
    msg.TextLength);
end

function h=hashFull(msg)


    fnames=fieldnames(msg);
    h="";
    for k=1:numel(fnames)
        fname=fnames{k};
        h=h+"$"+fname+"$"+msg.(fname);
    end
    h=char(h);
end

function[userVisibleCallSites,callers,userVisible,activeFcnIDs]=getUserCallSites(fcnID,fcns,scripts,fcnCallMatrix,callers,userVisible,activeFcnIDs)
    [userVisibleCallSites,callers,userVisible]=getUserCallSitesImpl(fcnID,fcns,scripts,fcnCallMatrix,callers,userVisible,[],false);
end

function[userVisibleCallSites,callers,userVisible,activeFcnIDs]=getUserCallSitesImpl(fcnID,fcns,scripts,fcnCallMatrix,callers,userVisible,activeFcnIDs,isRecursiveCall)
    userVisibleCallSites=[];

    if any(fcnID==activeFcnIDs)
        return;
    end

    activeFcnIDs(end+1)=fcnID;

    if isempty(callers{fcnID})


        [callerFcnIDs,callSiteIDs]=findCallers(fcnID,fcnCallMatrix);
        callers{fcnID}=[callerFcnIDs,callSiteIDs];
    end

    callersOfFcn=callers{fcnID};
    if~isempty(callersOfFcn)
        callerFcnIDs=callersOfFcn(:,1);
        callSiteIDs=callersOfFcn(:,2);
    else
        callerFcnIDs=[];
        callSiteIDs=[];
    end

    allCallSites=[];

    for i=1:numel(callerFcnIDs)
        callerFcnID=callerFcnIDs(i);
        [reportable,userVisible]=isReportable(callerFcnID,fcns,scripts,userVisible);
        if reportable
            callSites=[callerFcnID,callSiteIDs(i)];
            activeFcnIDs(activeFcnIDs==fcnID)=[];
        else
            [callSites,callers,userVisible,activeFcnIDs]=getUserCallSitesImpl(callerFcnID,fcns,scripts,fcnCallMatrix,callers,userVisible,activeFcnIDs,true);
        end
        allCallSites=[allCallSites;callSites];%#ok<AGROW>
    end

    if isRecursiveCall
        userVisibleCallSites=allCallSites;
    else

        userVisibleCallSites=unique(allCallSites,'rows');
    end
end


function[callerFcnIDs,callSiteIDs]=findCallers(fcnID,fcnCallMatrix)
    [callSiteIDs,callerFcnIDs]=find(fcnCallMatrix==fcnID);
end


function[reportable,userVisible]=isReportable(fcnID,fcns,scripts,userVisible)
    if isempty(userVisible{fcnID})
        userVisible{fcnID}=fcnID>0&&fcnID<=numel(fcns)&&...
        fcns(fcnID).ScriptID>0&&scripts(fcns(fcnID).ScriptID).IsUserVisible;
    end
    reportable=userVisible{fcnID};
end
