function[anyExtIn,anyExtOut]=duplicate(varargin)




















    anyExtIn=false;
    anyExtOut=false;

    if nargin==2
        objH=varargin{1};
        srcSID={get_param(objH,'BlockCopiedFrom')};


        if~isempty(srcSID{1})&&~shouldContinueCopy(srcSID{1},objH)
            return;
        end
        modelH=varargin{2};
        isSf=false;

    elseif nargin==3

        objH=varargin{1};
        modelH=varargin{2};

        if ischar(varargin{3})
            srcSID=varargin(3);
            isSf=false;
            if~isempty(srcSID{1})&&~shouldContinueCopy(srcSID{1},objH)
                return;

            end

        else

            if modelH==0
                srcH=varargin{3};
                reqs=rmi.getReqs(srcH);
                if~isempty(reqs)
                    modelH=bdroot(objH);
                    srcSid=Simulink.ID.getSID(srcH);
                    rmidata.duplicateReqs(objH,modelH,false,srcSid);





                    src.domain='linktype_rmi_simulink';
                    [src.artifact,src.id]=strtok(srcSid,':');
                    slreq.internal.setLinks(src,[]);
                end
            else
                srcH=varargin{3};
                reqs=rmi.getReqs(srcH);
                if~isempty(reqs)
                    setReqsAsObjAttr(objH,reqs,modelH);
                end
            end
            return;
        end

    else

        if~validSfArgs(varargin{:})
            anyExtIn=false;
            anyExtOut=false;
            return;
        end

        isSf=true;
        srcChartSID=varargin{1};
        srcIds=varargin{2};
        dstChartSID=varargin{3};
        dstIds=varargin{4};

        srcMdl=strtok(srcChartSID,':');
        dstMdl=strtok(dstChartSID,':');
        if~isempty(srcMdl)&&~shouldContinueCopy(srcMdl,dstMdl)
            return;
        end
        if~isempty(srcMdl)&&rmidata.isExternal(srcMdl)
            srcSID=idsToFullSIDs(srcChartSID,srcIds);
        else
            srcSID=cell(size(srcIds));
        end
        objH=idsToHandles(dstChartSID,dstIds);
        modelH=get_param(dstMdl,'Handle');
    end

    fromExt=false(1,length(objH));
    toExt=false(1,length(objH));

    if isSf

        sfisa=rmisf.sfisa;
        typesWithReqs=[sfisa.chart,sfisa.state,sfisa.transition];
    end



    artifactPath=get_param(modelH,'FileName');
    slreq.data.DataModelObj.checkLicense(['allow ',artifactPath]);

    for i=1:length(objH)
        if objH(i)==0


            continue;
        end
        if~isSf||any(typesWithReqs==sf('get',objH(i),'.isa'))
            [fromExt(i),toExt(i)]=rmidata.duplicateReqs(objH(i),modelH,isSf,srcSID{i});
        end
    end


    slreq.data.DataModelObj.checkLicense('clear');


    anyExtIn=any(fromExt);

    anyExtOut=any(toExt);
end

function sids=idsToFullSIDs(chartId,objIds)
    count=length(objIds);
    sids=cell(count,1);
    for i=1:count
        sids{i}=sprintf('%s:%d',chartId,objIds(i));
    end
end

function handles=idsToHandles(chartId,objIds)


    count=length(objIds);
    handles=zeros(count,1);
    for i=1:count
        try
            obj=Simulink.ID.getHandle(sprintf('%s:%d',chartId,objIds(i)));
            handles(i)=obj.Id;
        catch Ex
            if~strcmp(Ex.identifier,'Simulink:utility:invalidSID')
                warning(message('Slvnv:rmidata:duplicate:idsToHandles',sprintf('%s:%d',chartId,objIds(i)),Ex.message));
            end
        end
    end
end

function result=validSfArgs(srcChartSID,srcIds,dstChartSID,dstIds)

    if isempty(srcChartSID)

        result=false;
    elseif isempty(dstChartSID)
        warning(message('Slvnv:rmidata:duplicate:EmptyDestinationChartSID'));
        result=false;
    elseif any(srcIds==0)

        result=false;
    elseif any(dstIds==0)
        warning(message('Slvnv:rmidata:duplicate:ZeroDestinationSID'));
        result=false;
    else
        result=true;
    end
end

function result=isLibrary(sid,isSrc)
    if~ischar(sid)

        diagramType=get_param(bdroot(sid),'BlockDiagramType');
    elseif isSrc
        mdlName=strtok(sid,':');

        if strcmp(mdlName,'simulink')
            result=true;
            return;
        else
            try
                diagramType=get_param(mdlName,'BlockDiagramType');
            catch Ex0 %#ok<NASGU>



                try
                    load_system(mdlName);
                    diagramType=get_param(mdlName,'BlockDiagramType');
                catch Ex1



                    if~strcmp(Ex1.identifier,'Simulink:Commands:OpenSystemUnknownSystem')
                        warning(message('Slvnv:rmidata:duplicate:GetDiagramTypeFailed',sid,Ex1.message));
                    end
                    result=true;
                    return;
                end
            end
        end
    else

        mdlName=strtok(sid,':');
        diagramType=get_param(mdlName,'BlockDiagramType');
    end
    result=strcmp(diagramType,'library');
end

function out=isSubsystemReference(blockSid)
    if ischar(blockSid)
        mdlName=strtok(blockSid,':');
    else
        mdlName=get_param(bdroot(blockSid),'Name');
    end

    out=bdIsSubsystem(mdlName);
end

function out=shouldContinueCopy(src,dst)




    out=true;
    if isLibrary(src,true)&&~isLibrary(dst,false)
        out=false;



        return;
    end

    if isSubsystemReference(src)&&~isSubsystemReference(dst)
        out=false;
        return;
    end

end

function setReqsAsObjAttr(objH,structArray,modelH)


    reqstr=rmi.reqs2str(structArray);


    GUID=rmi.guidGet(objH);


    if isempty(reqstr)
        reqstr='{} ';
    end
    reqstr=[reqstr,' %',GUID];


    rmi.setRawReqs(objH,false,reqstr,modelH);

end
