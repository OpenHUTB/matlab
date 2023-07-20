function postProcessLinkSet(this,mfLinkSet)












    checkSLLinks=slreq.data.ReqData.isMATLABVersionBefore(mfLinkSet.MATLABVersion,'2018b');



    checkProxyLinks=checkSLLinks||slreq.data.ReqData.isMATLABVersionBefore(mfLinkSet.MATLABVersion,'2019b');


    migrateMuPAD=checkProxyLinks||slreq.data.ReqData.isMATLABVersionBefore(mfLinkSet.MATLABVersion,'2020a');
    mupadCount=0;

    if~migrateMuPAD

        return;
    end


    links=mfLinkSet.links.toArray;


    referencedReqSets=containers.Map('KeyType','char','ValueType','logical');

    for i=1:length(links)

        mfLink=links(i);
        ref=mfLink.dest;
        destDomain=ref.domain;

        checkSL=false;

        switch destDomain

        case 'linktype_rmi_slreq'

            referencedReqSets(ref.artifactUri)=true;

            if checkProxyLinks&&isempty(ref.reqSetUri)
                this.populateReqSetUri(ref);
            end

        case 'linktype_rmi_simulink'

            if checkSLLinks
                checkSL=true;
            end

        case 'linktype_rmi_matlab'

            if checkSLLinks
                checkSL=rmisl.isSidString(ref.artifactUri);
                if checkSL
                    ref.domain='linktype_rmi_simulink';
                end
            end

        case 'linktype_rmi_mupad'
            if migrateMuPAD
                mupadCount=mupadCount+1;
                ref.domain='linktype_rmi_matlab';
                [fDir,fName]=fileparts(ref.artifactUri);
                ref.artifactUri=fullfile(fDir,[fName,'.mlx']);
                mfLink.description=sprintf('%s (%s)',...
                mfLink.description,getString(message('Slvnv:reqmgt:linktype_rmi_mupad:MuPADLinkConverted','MuPAD')));
            end

        otherwise

        end

        if checkSL
            [ref.artifactUri,ref.artifactId]=rmisl.correctSimulinkUriAndId(ref.artifactUri,ref.artifactId);
        end

    end

    if mupadCount>0



        rmiut.warnNoBacktrace('Slvnv:reqmgt:linktype_rmi_mupad:NMuPADLinksConverted',...
        num2str(mupadCount),slreq.uri.getShortNameExt(mfLinkSet.artifactUri));
    end






    if mfLinkSet.registeredReqSetFiles.Size>0

        if checkSLLinks
            cleanupDuplicateReqSetRegistrations(mfLinkSet);
        end

        checkPathsToRegisteredReqSets(mfLinkSet,keys(referencedReqSets));
    end

end

function cleanupDuplicateReqSetRegistrations(mfLinkSet)
    registeredReqSets=mfLinkSet.registeredReqSetFiles.toArray;
    [uniqueReqSets,uniqueIdx]=unique(registeredReqSets);
    if~isequal(uniqueReqSets,registeredReqSets)


        reqSetUuids=mfLinkSet.registeredReqSetUuids.toArray;
        mfLinkSet.registeredReqSetFiles.clear;
        mfLinkSet.registeredReqSetUuids.clear;
        for n=1:length(uniqueIdx)
            mfLinkSet.registeredReqSetFiles.add(registeredReqSets{uniqueIdx(n)});
            mfLinkSet.registeredReqSetUuids.add(reqSetUuids{uniqueIdx(n)});
        end
    end
end

function checkPathsToRegisteredReqSets(mfLinkSet,referencedReqSets)
    registeredReqSets=mfLinkSet.registeredReqSetFiles.toArray;
    for i=numel(registeredReqSets):-1:1
        storedReqSetPath=registeredReqSets{i};
        shortFileName=slreq.uri.getShortNameExt(storedReqSetPath);





        if rmiut.isCompletePath(storedReqSetPath)
            if~isfile(storedReqSetPath)

                mfLinkSet.registeredReqSetFiles(i)=shortFileName;
            end
        end
    end
end

