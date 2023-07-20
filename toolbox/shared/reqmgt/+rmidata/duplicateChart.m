function[anyExtIn,anyExtOut]=duplicateChart(sfH,modelH,slH,srcSID)










    anyExtIn=false;
    anyExtOut=false;


    if rmisl.inLibrary(slH,false)
        return;
    end

    if rmisl.inSubsystemReference(slH,false)

        return;
    end


    if nargin<4
        srcSID=get_param(slH,'BlockCopiedFrom');
    end



    try
        if Simulink.ID.getHandle(srcSID)==slH
            return;
        end
    catch ME %#ok<NASGU>

    end

    if isempty(srcSID)

        srcIsExternal=false;
    else


        srcMdl=strtok(srcSID,':');



        try
            hostDiagramType=get_param(srcMdl,'BlockDiagramType');
        catch Ex1

            try
                load_system(srcMdl);
                hostDiagramType=get_param(srcMdl,'BlockDiagramType');
            catch Ex2



                if~strcmp(Ex2.identifier,'Simulink:Commands:OpenSystemUnknownSystem')
                    warning(message('Slvnv:rmidata:duplicate:GetDiagramTypeFailed',...
                    srcSID,[Ex1.message,', ',Ex2.message]));
                end
                return;
            end
        end



        refBlock=get_param(slH,'ReferenceBlock');
        if isempty(refBlock)&&strcmp(hostDiagramType,'library')
            if strcmp(get_param(bdroot(slH),'Name'),srcMdl)

            else
                return;
            end
        end

        [srcIsExternal,srcH]=rmidata.isExternal(srcMdl);
        srcIsExternal=(srcIsExternal&&rmidata.bdHasExternalData(srcH,true));
    end

    if isMATLABFunction(slH)


        if slreq.internal.mlfbHasLinkData(srcSID)
            destSID=Simulink.ID.getSID(slH);
            [~,totalLinks]=rmidata.duplicateMLFB(srcSID,destSID,false);
            anyExtIn=(totalLinks>0);
            anyExtOut=anyExtIn;
        end
        return;
    end


    states=sf('get',sfH,'.states');
    trans=sf('get',sfH,'.transitions');
    allObjs=[sfH,states,trans];
    destMdlName=get_param(modelH,'Name');

    if srcIsExternal

        srcRootName=strtok(srcSID,':');
        if rmisl.isComponentHarness(srcRootName)



            harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(srcRootName);
            if isempty(harnessInfo)
                return;
            end
            harnessID=[srcRootName,':',harnessInfo.uuid];
            srcSID=strrep(srcSID,srcRootName,harnessID);
        end
        keys=getNestedWithLinks(srcSID);
        ids=zeros(1,length(keys));





        stripGUIDs=false;

        if~isempty(keys)

            try
                if~isempty(refBlock)


                    [anyExtIn,anyExtOut,ids]=copyFromLibToMdl(modelH,slH,srcSID,keys,ids);
                else

                    ancBlock=get_param(slH,'AncestorBlock');
                    if~isempty(ancBlock)&&strncmp(ancBlock,destMdlName,length(destMdlName))


                        [anyExtIn,anyExtOut,ids]=copyFromMdlToLib(modelH,slH,srcSID,keys,ids);
                    else

                        [anyExtIn,anyExtOut,ids,stripGUIDs]=copyFromMdlToMdl(modelH,slH,srcSID,keys,ids);
                    end
                end

            catch ME %#ok<NASGU>





            end
        end


        if stripGUIDs
            remainingObjs=setdiff(allObjs,ids);
            for i=1:length(remainingObjs)
                rmi.setRawReqs(remainingObjs(i),true,'',modelH);
            end
        end






        slreqCleanupUnmatchedItems(slH,srcSID,keys);





        if~stripGUIDs&&srcIsExternal&&~rmidata.isExternal(modelH)
            remainingObjs=setdiff(allObjs,ids);
            for i=1:length(remainingObjs)
                oneId=remainingObjs(i);
                reqStr=sf('get',oneId,'.requirementInfo');
                if~isempty(reqStr)&&~strncmp(reqStr,'{}',2)
                    reqStr=regexprep(reqStr,'{[^}]+}','{}');
                    sf('set',oneId,'.requirementInfo',reqStr);
                end
            end
        end

    elseif strcmp(get_param(srcMdl,'hasReqInfo'),'on')


        toExt=false(1,length(allObjs));
        for i=1:length(allObjs)
            if allObjs(i)==sfH
                continue;
            end
            [~,toExt(i)]=rmidata.duplicateReqs(allObjs(i),modelH,true,'');
        end
        anyExtOut=any(toExt);

        if anyExtOut&&rmidata.bdHasExternalData(modelH)



            try
                mdlBlockH=Simulink.ID.getHandle(srcSID);
            catch ME %#ok<NASGU>



                return;
            end
            ancestorBlock=get_param(mdlBlockH,'AncestorBlock');
            if~isempty(ancestorBlock)


                origMdlName=strtok(ancestorBlock,'/');
                if strcmp(origMdlName,destMdlName)
                    ancChartSID=Simulink.ID.getSID(ancestorBlock);
                    destChartSID=get_param(mdlBlockH,'BlockCopiedFrom');
                    if~strcmp(destChartSID,ancChartSID)
                        adjustLibKeys(ancChartSID,destChartSID);
                    end
                end
            end
        end
    end
end

function tf=isMATLABFunction(slH)
    chartType=rmisf.sfBlockType(slH);
    tf=strcmp(chartType,'MATLAB Function');
end

function[anyExtIn,anyExtOut,ids]=copyFromLibToMdl(modelH,slH,srcSID,keys,ids)





    if rmidata.bdHasExternalData(modelH,true)
        destSID=Simulink.ID.getSID(slH);
        destKeys=getNestedWithLinks(destSID);
        if~isempty(destKeys)
            cleanupStaleKeys(destKeys);
        end
    end


    destMdlName=get_param(modelH,'Name');
    anyExtIn=false;
    anyExtOut=false;





    sfMachine=find(sfroot,'-isa','Stateflow.Machine','Name',destMdlName);
    destChart=sfMachine.find('-isa','Stateflow.Chart','Name',get_param(slH,'Name'));
    for i=1:length(keys)


        sid=strrep(keys{i},[srcSID,':'],'');
        destObj=destChart.find('SSIdNumber',str2num(sid));%#ok<ST2NM>
        ids(i)=destObj.Id;
        [fromExt,toExt]=rmidata.duplicateReqs(ids(i),modelH,true,keys{i});
        anyExtIn=anyExtIn|fromExt;
        anyExtOut=anyExtOut|toExt;
    end
end

function[anyExtIn,anyExtOut,ids]=copyFromMdlToLib(modelH,slH,srcSID,keys,ids)
    anyExtIn=false;
    anyExtOut=false;



    mdlBlockH=Simulink.ID.getHandle(srcSID);
    destChartSID=get_param(mdlBlockH,'BlockCopiedFrom');



    if~rmidata.isExternal(modelH)
        destSID=Simulink.ID.getSID(slH);
    else
        destSID='';
    end


    for i=1:length(keys)




        reqs=localGetReqs(keys{i});
        anyExtIn=anyExtIn|~isempty(reqs);
        if isempty(destSID)
            destKey=strrep(keys{i},srcSID,destChartSID);
            localSetReqs(destKey,reqs);
            anyExtOut=anyExtOut|~isempty(reqs);
        else
            destKey=strrep(keys{i},srcSID,destSID);
            destObj=Simulink.ID.getHandle(destKey);
            ids(i)=destObj.Id;
            reqStr=rmi.reqs2str(reqs);
            rmi.objCopy(ids(i),reqStr,modelH,true);
        end
    end




    cleanupStaleKeys(keys);

end

function[anyExtIn,anyExtOut,ids,stripGUIDs]=copyFromMdlToMdl(modelH,slH,srcSID,keys,ids)
    anyExtIn=false;
    anyExtOut=false;
    destSID=Simulink.ID.getSID(slH);
    tmpSidPrefix=getTempSubspacePrefix(srcSID,destSID);
    stripGUIDs=false;
    for i=1:length(keys)

        destKey=strrep(keys{i},srcSID,destSID);
        destObj=Simulink.ID.getHandle(destKey);
        ids(i)=destObj.Id;
        stripGUIDs=stripGUIDs||~isempty(destObj.requirementInfo);
        [fromExt,toExt]=rmidata.duplicateReqs(ids(i),modelH,true,keys{i},tmpSidPrefix);
        anyExtIn=anyExtIn|fromExt;
        anyExtOut=anyExtOut|toExt;
    end
end

function tmpSidPrefix=getTempSubspacePrefix(srcSID,destSID)
    tmpSidPrefix='';
    destDiag=strtok(destSID,':');
    if strcmp(get_param(destDiag,'BlockDiagramType'),'library')
        srcDiag=strtok(srcSID,':');
        if strcmp(get_param(srcDiag,'BlockDiagramType'),'model')




            comaIdx=find(destSID==':');
            if numel(comaIdx)>=2
                tmpSidPrefix=destSID(comaIdx(1):comaIdx(2));
            end
        end
    end
end

function cleanupStaleKeys(keys)
    if~isempty(keys)
        model=strtok(keys{1},':');
        src.artifact=get_param(model,'FileName');
        src.domain='linktype_rmi_simulink';
        for i=1:length(keys)
            [~,src.id]=strtok(keys{i},':');
            slreq.internal.setLinks(src,[]);
        end
    end
end

function count=adjustLibKeys(ancChartSID,destChartSID)
    keys=getNestedWithLinks(ancChartSID);
    count=length(keys);
    for i=1:count
        oldKey=keys{i};
        data=localGetReqs(oldKey);
        newKey=strrep(oldKey,ancChartSID,destChartSID);
        localSetReqs(newKey,data);
        localSetReqs(oldKey,[]);
    end
end

function sids=getNestedWithLinks(parentSid)
    [host,parentId]=strtok(parentSid,':');
    ids=slreq.utils.getIDsUnder(host,parentId);
    if isempty(ids)
        sids={};
    else
        sids=strcat(host,ids);
    end
end

function reqs=localGetReqs(sid)
    [model,id]=strtok(sid,':');
    reqs=slreq.getReqs(get_param(model,'FileName'),id,'linktype_rmi_simulink');
end

function localSetReqs(sid,reqs)

    [model,src.id]=strtok(sid,':');
    src.artifact=get_param(model,'FileName');
    src.domain='linktype_rmi_simulink';





    reqs=slreq.uri.correctDestinationUriAndId(reqs);


    slreq.internal.setLinks(src,reqs);
end

function slreqCleanupUnmatchedItems(slH,srcSID,srcKeys)
    destSID=Simulink.ID.getSID(slH);
    dstKeys=getNestedWithLinks(destSID);
    if~isempty(dstKeys)
        src.artifact=strtok(dstKeys{1},':');
        src.domain='linktype_rmi_simulink';
        for i=1:length(dstKeys)

            matchKey=strrep(dstKeys{i},destSID,srcSID);
            if~any(strcmp(matchKey,srcKeys))


                [~,src.id]=strtok(dstKeys{i},':');
                slreq.internal.setLinks(src,[]);
            end
        end
    end
end

