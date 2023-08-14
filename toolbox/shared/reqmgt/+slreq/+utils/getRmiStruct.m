function rmiStruct=getRmiStruct(obj,varargin)




    if nargin>1

        rmiStruct=srcIdsToStruct(obj,varargin{:});
        return;
    end

    if isa(obj,'slreq.data.Requirement')||isa(obj,'slreq.BaseItem')
        rmiStruct=obj.toStruct();
        return;
    end

    switch class(obj)

    case 'char'
        if any(obj=='|')
            rmiStruct=locationToSrcStruct(obj);
        elseif rmisl.isSidString(obj)
            rmiStruct=sidToSrcStruct(obj);
        elseif exist(obj,'file')==4

            [rmiStruct.artifact,rmiStruct.id]=ensureFullPathToOwnerFile(obj,true);
            rmiStruct.domain='linktype_rmi_simulink';
        elseif exist(obj,'file')==2

            rmiStruct.artifact=ensureFullPathToOwnerFile(obj,false);
            rmiStruct.id='';
            rmiStruct.domain=slreq.utils.getDomainLabel(rmiStruct.artifact);
        elseif sysarch.isZCElement(obj)
            rmiStruct=sysarch.getRmiStruct(obj);
        else

            rmiStruct=sidToSrcStruct(Simulink.ID.getSID(obj));
        end

    case 'double'
        if sysarch.isZCPort(obj)
            rmiStruct=sysarch.getRmiStruct(obj);
        else
            [isSf,objH,errMsg]=rmi.resolveobj(obj);
            if isempty(objH)
                throwAsCaller(MException(message('Slvnv:slreq:UnsupportedType',errMsg)));
            end
            [objH,refSid]=slreq.utils.slGetSource(isSf,objH);
            if~isempty(refSid)

                rmiStruct=sidToSrcStruct(refSid);
            else

                if isSf
                    sfRoot=sfroot();
                    sfObj=sfRoot.idToHandle(objH);
                    rmiStruct=sidToSrcStruct(Simulink.ID.getSID(sfObj));
                else
                    rmiStruct=sidToSrcStruct(Simulink.ID.getSID(obj));
                end
            end
        end

    case 'Simulink.DDEAdapter'
        rmiStruct.domain='linktype_rmi_data';
        [rmiStruct.id,rmiStruct.artifact]=rmide.getGuid(obj);

    case 'slreq.data.SourceItem'
        rmiStruct.domain=obj.domain;
        rmiStruct.artifact=obj.artifactUri;
        rmiStruct.id=obj.id;

    case 'slreq.data.TextRange'
        rmiStruct.domain='linktype_rmi_matlab';
        rmiStruct.artifact=obj.artifactUri;
        rmiStruct.id=obj.id;
        rmiStruct.parent=obj.getTextNodeId();

    case 'struct'
        rmiStruct.domain=obj.reqsys;
        if rmisl.isHarnessIdString(obj.doc)


            [mainModel,harnessID]=strtok(obj.doc,':');
            rmiStruct.artifact=get_param(mainModel,'FileName');
            rmiStruct.id=[harnessID,obj.id];
        else

            rmiStruct.artifact=obj.doc;
            rmiStruct.id=obj.id;
        end


    case{'Simulink.fault.Fault','Simulink.fault.Conditional'}
        rmiStruct.domain='linktype_rmi_simulink';
        rmiStruct.artifact=obj.getTopModelName;
        rmiStruct.id=[rmifa.itemIDPref,obj.Uuid];
        return;
    case{'sm.internal.SafetyManagerNode'}
        rmiStruct=rmism.getRmiStruct(obj,false);
        return;
    otherwise

        if sysarch.isSysArchObject(obj)
            rmiStruct=sysarch.getRmiStruct(obj);
            return;
        end




        if isa(obj,'Simulink.Object')
            rmiStruct=sidToSrcStruct(Simulink.ID.getSID(obj));

        elseif isa(obj,'Stateflow.Object')

            [objH,refSid]=slreq.utils.slGetSource(true,obj);
            if isempty(refSid)
                rmiStruct=sidToSrcStruct(Simulink.ID.getSID(objH));
            else
                rmiStruct=sidToSrcStruct(refSid);
            end
        else
            error(message('Slvnv:slreq:ErrorInvalidType','slreq.utils.getRmiStruct',class(obj)));
        end
    end
end

function src=sidToSrcStruct(sid)
    [mdlName,id]=strtok(sid,':');
    if rmisl.isComponentHarness(mdlName)

        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(mdlName);
        idPrefix=[':',harnessInfo.uuid];
        mdlName=harnessInfo.model;
    else
        idPrefix='';
    end
    try
        src.artifact=get_param(mdlName,'FileName');


        artiHandle=Simulink.ID.getHandle(sid);
        trgtHandle=slreq.utils.getRMISLTarget(artiHandle,false,true);
        if~isequal(trgtHandle,artiHandle)


            [~,id]=strtok(Simulink.ID.getSID(trgtHandle),':');
        end
    catch ex %#ok<NASGU>

        src.artifact=which(mdlName);
    end
    src.id=[idPrefix,id];
    src.domain='linktype_rmi_simulink';


    if isempty(src.artifact)
        src.artifact=[mdlName,'.slx'];
    end
end

function src=locationToSrcStruct(in)
    [artifact,remainder]=strtok(in,'|');
    src=srcIdsToStruct(artifact,remainder(2:end));
end

function src=srcIdsToStruct(artifact,id,type)
    if rmisl.isSidString(artifact)
        [artifact,theRest]=strtok(artifact,':');
        src.artifact=get_param(artifact,'FileName');
        src.domain='linktype_rmi_simulink';
        src.parent=theRest;
        src.id=id;
    else
        src.artifact=artifact;
        if nargin>2
            src.domain=type;
        else
            src.domain=slreq.utils.getDomainLabel(artifact);
        end
        if strcmp(src.domain,'linktype_rmi_data')

            src.id=rmide.getGuid(artifact,'',id);
        else
            src.id=id;
        end
    end
end

function[srcPath,id]=ensureFullPathToOwnerFile(in,checkForHanress)
    id='';
    [sDir,inName,sExt]=fileparts(in);
    if isempty(sDir)||isempty(sExt)
        srcPath=which(in);
        if checkForHanress
            try
                [~,sName]=fileparts(srcPath);
                if~strcmp(sName,inName)&&rmisl.isComponentHarness(in)


                    harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(inName);
                    id=[':',harnessInfo.uuid];
                end
            catch
            end
        end
    else
        srcPath=in;
    end
end



