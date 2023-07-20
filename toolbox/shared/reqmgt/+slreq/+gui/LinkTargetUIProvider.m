classdef LinkTargetUIProvider



    methods(Static)


        function clickAction(obj,caller,reference)
            import slreq.gui.LinkTargetUIProvider.*
            if~exist('caller','var')
                caller='standalone';
            end

            if nargin<3
                reference='';
            end
            if~isempty(obj)
                if isstruct(obj)


                    domain=obj.domain;
                    artifactUri=slreq.uri.ResourcePathHandler.getFullPath(obj.artifactUri,reference);
                    id=obj.id;
                else
                    domain=getDomain(obj);
                    [artifactUri,id]=getArtifactUriId(obj);
                end
                switch domain
                case 'linktype_rmi_slreq'
                    [caller,dataReq]=overwriteCallerIfNeeded(caller,obj);
                    if strcmp(caller,'standalone')
                        slreq.adapters.SLReqAdapter.navigate(artifactUri,id,caller,'highlight');
                    else

                        appmgr=slreq.app.MainManager.getInstance();
                        dasObj=appmgr.getDasObjFromDataObj(dataReq);
                        if~isempty(dasObj)
                            spObj=appmgr.getCurrentView(caller);
                            spObj.setHighlightedObject(dasObj,true);
                        end
                    end
                case 'linktype_rmi_simulink'
                    if rmisl.isSidString(artifactUri)



                        rmi.navigate('linktype_rmi_matlab',artifactUri,id,reference);
                    else
                        [~,modelName]=fileparts(artifactUri);
                        slreq.adapters.SLAdapter.navigate(modelName,id,caller);
                    end
                otherwise


                    rmi.navigate(domain,artifactUri,id,reference);
                end
            end
        end


        function cmd=getClickActionCommandString(obj,caller,isExternal)


            if nargin<2
                caller='standalone';
            end

            if nargin<3





                isExternal=false;
            end

            import slreq.gui.LinkTargetUIProvider.*
            if~exist('caller','var')
                caller='standalone';
            end

            if isempty(obj)
                cmd='';
            else
                domain=getDomain(obj);
                [artifactUri,id]=getArtifactUriId(obj);
                if isExternal
                    cmd=sprintf('rmi.navigate(''%s'',''%s'',''%s'','''')',domain,artifactUri,id);
                else
                    if isa(obj,'slreq.data.Requirement')||strcmp(domain,'linktype_rmi_slreq')
                        if~strcmp(caller,'standalone')
                            caller=overwriteCallerIfNeeded(caller,obj);
                        end
                        if isa(obj,'slreq.data.Requirement')&&strcmp(obj.domain,'linktype_rmi_simulink')

                            [~,modelName]=fileparts(artifactUri);
                            cmd=sprintf('slreq.adapters.SLAdapter.navigate(''%s'',''%s'',''%s'')',modelName,id,caller);
                        elseif isa(obj,'slreq.data.Requirement')&&~obj.isDirectLink
                            artifactUri=obj.getReqSet.name;
                            id=obj.sid;
                            caller=overwriteCallerIfNeeded(caller,obj);
                            cmd=sprintf('slreq.adapters.SLReqAdapter.navigate(''%s'',''%d'',''%s'',''highlight'')',artifactUri,id,caller);
                        else
                            cmd=sprintf('rmi.navigate(''%s'',''%s'',''%s'',[],''%s'')',domain,artifactUri,id,caller);
                        end
                    elseif strcmp(domain,'linktype_rmi_simulink')
                        if rmisl.isSidString(artifactUri)







                            cmd=sprintf('rmi.navigate(''linktype_rmi_matlab'',''%s'',''%s'','''')',artifactUri,id);
                        else
                            [~,modelName]=fileparts(artifactUri);
                            cmd=sprintf('slreq.adapters.SLAdapter.navigate(''%s'',''%s'',''%s'')',modelName,id,caller);
                        end
                    else


                        cmd=sprintf('rmi.navigate(''%s'',''%s'',''%s'','''')',domain,artifactUri,id);
                    end
                end
            end
        end

        function navigate(obj,caller,toSource)


            import slreq.gui.LinkTargetUIProvider.*
            if nargin<2
                toSource=false;
            end
            if toSource
                if obj.isReqIF()||obj.isOSLC()
                    slreq.internal.navigateToExternalSource(obj);
                    return;
                else
                    options={'original'};
                end
            else
                options={};
            end
            [artifactUri,id,customId]=getArtifactUriId(obj,toSource);
            if isa(obj,'slreq.data.Requirement')
                refpath=obj.getReqSet.filepath;
            else
                refpath='';
            end
            domain=getDomain(obj,true);
            switch domain
            case 'linktype_rmi_excel'
                if toSource


                    if isempty(id)||id(1)=='?'||id(1)=='$'
                        fullId=getFullIdForTargetInSubdoc(obj);
                        rmi.navigate(domain,artifactUri,fullId,refpath,options{:});
                    else


                        rmi.navigate(domain,artifactUri,id,refpath,options{:});
                    end
                else
                    rmi.navigate(domain,artifactUri,customId,refpath);
                end
            case 'linktype_rmi_word'
                if toSource||isempty(customId)
                    rmi.navigate(domain,artifactUri,id,refpath,options{:});
                else
                    rmi.navigate(domain,artifactUri,customId,refpath);
                end
            otherwise
                if isempty(customId)
                    rmi.navigate(domain,artifactUri,id,refpath,options{:});
                else

                    rmi.navigate(domain,artifactUri,customId,refpath,options{:});
                end
            end
        end

        function[artifactUri,id,customId]=getArtifactUriId(obj,toSource)
            if nargin<2
                toSource=false;
            end
            artifactUri=obj.artifactUri;
            customId='';
            if isa(obj,'slreq.data.TextRange')
                textItemId=obj.getTextNodeId();
                if isempty(textItemId)
                    id=obj.id;
                else
                    [~,mdlName]=fileparts(artifactUri);
                    artifactUri=[mdlName,textItemId];
                    id=obj.id;
                end
            elseif isa(obj,'slreq.data.SourceItem')
                id=obj.id;
            elseif isa(obj,'slreq.data.Requirement')
                if~obj.external

                    artifactUri=[obj.getReqSet.name,'.slreqx'];
                    id=num2str(obj.sid);
                else

                    if obj.isDirectLink||toSource
                        id=obj.artifactId;
                        customId=obj.customId;
                    else


                        artifactUri=[obj.getReqSet.name,'.slreqx'];
                        id=num2str(obj.sid);
                    end
                end

            end
        end

        function domain=getDomain(obj,useExternalDomain)
            if nargin==1
                useExternalDomain=false;
            end
            if isa(obj,'slreq.data.SourceItem')
                domain=obj.domain;
            elseif isa(obj,'slreq.data.Requirement')
                if obj.isDirectLink||(obj.external&&useExternalDomain)
                    domain=obj.domain;
                else

                    domain='linktype_rmi_slreq';
                end
            else
                error(message('Slvnv:slreq:UnexpectedObjectType'));
            end
            if strcmp(domain,'other')
                linkType=rmi.linktype_mgr('resolveByFileExt',obj.artifactUri);
                if~isempty(linkType)
                    domain=linkType.Registration;
                end
            end
        end
    end
end

function[out,reqObj]=overwriteCallerIfNeeded(caller,obj)


    out=caller;
    reqObj=[];
    appmgr=slreq.app.MainManager.getInstance();
    if~strcmp(caller,'standalone')
        spObj=appmgr.getCurrentView(caller);
        if~isempty(spObj)&&isa(spObj,'slreq.gui.ReqSpreadSheet')
            if isa(obj,'slreq.data.Requirement')
                reqObj=obj;
            else
                reqObj=slreq.utils.getReqObjFromSourceItem(obj);
            end
            if~isempty(reqObj)
                dataReqSet=reqObj.getReqSet;
                if~spObj.isReqOrLinkSetRegistered(dataReqSet)

                    out='standalone';
                end
            end
        end
    end
end

function fullId=getFullIdForTargetInSubdoc(dataObj)


    parent=dataObj.parent;
    if isempty(parent)

        parent=dataObj;
    else
        while~isempty(parent.parent)



            parent=parent.parent;
        end
    end


    [~,subDocName]=slreq.internal.getDocSubDoc(parent.customId);

    if isempty(subDocName)

        fullId=dataObj.artifactId;
    else

        artifactId=dataObj.artifactId;

        if isempty(artifactId)
            fullId=['!',subDocName];
            return;

        elseif artifactId(1)=='?'||artifactId(1)=='$'

            firstChar=artifactId(1);
            artifactId=artifactId(2:end);
        else
            firstChar='';
        end


        if strncmp(artifactId,subDocName,length(subDocName))

            fullId=dataObj.artifactId;
        else

            fullId=[firstChar,subDocName,'!',artifactId];
        end
    end
end