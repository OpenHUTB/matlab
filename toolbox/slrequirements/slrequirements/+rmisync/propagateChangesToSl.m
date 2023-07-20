function newReqs=propagateChangesToSl(origReqs,syncObj,surrId,surrlinksInfo)






    surrReq=syncObj.makeSrgReq(surrId);


    surrlinksInfo=rmiut.filterChars(surrlinksInfo,false,true);
    if isempty(surrlinksInfo)||strncmp(surrlinksInfo,'{}',2)
        reqsysReqs=[];
    else
        reqsysReqs=syncObj.linkinfoToReqs(surrlinksInfo);
    end

    if isempty(origReqs)

        newReqs=[surrReq;reqsysReqs];

    else

        slIsSurr=strcmp(syncObj.srgSys,{origReqs.reqsys});
        slIsThisReqsys=strcmp(syncObj.reqSys,{origReqs.reqsys});

        if syncObj.purgeSimulink


            if isempty(reqsysReqs)

                newReqs=[surrReq;origReqs(~slIsSurr&~slIsThisReqsys)];

            else

                newReqs=[surrReq;reqsysReqs;origReqs(~slIsSurr&~slIsThisReqsys)];
            end

        else


            if isempty(reqsysReqs)

                newReqs=[surrReq;origReqs(~slIsSurr)];

            elseif~any(slIsThisReqsys)

                newReqs=[surrReq;reqsysReqs;origReqs(~slIsSurr)];

            else







                [uniqueModules,~,modIdx]=unique({reqsysReqs.doc});
                docsInSl=strtok({origReqs.doc});
                surrItemsMatchedInSl=false(1,length(reqsysReqs));

                for i=1:length(uniqueModules)
                    thisModule=uniqueModules(i);
                    isThisModule=(modIdx==i);
                    idsInSurrogate={reqsysReqs(isThisModule).id};

                    isSameModuleInSl=slIsThisReqsys&strcmp(thisModule,docsInSl);
                    idsInSl={origReqs(isSameModuleInSl).id};


                    [~,matchedSurrIndicesForThisModule,~]=intersect(idsInSurrogate,idsInSl);
                    matchedForThisModule=false(1,length(idsInSurrogate));
                    matchedForThisModule(matchedSurrIndicesForThisModule)=true;
                    surrItemsMatchedInSl(find(isThisModule))=matchedForThisModule;%#ok
                end


                newReqs=[surrReq;origReqs(slIsThisReqsys);...
                reqsysReqs(~surrItemsMatchedInSl);origReqs(~slIsSurr&~slIsThisReqsys)];
            end
        end
    end
end
