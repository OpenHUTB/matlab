classdef SLAdapter<slreq.adapters.BaseAdapter




    properties(Constant,Hidden)

        domain2IconMap=containers.Map(...
        {...
        'simulink-state',...
        'simulink-actionstate',...
        'simulink-connection',...
        'simulink-transition',...
        'simulink-specblock',...
        'simulink-statebox',...
        'simulink-sfslfcn',...
        'simulink-sfgraphfcn',...
        'simulink-emlaction',...
        'simulink-truthtable',...
        'simulink-historyjunction',...
        'simulink-annotation',...
        'simulink-image',...
        'simulink-chart',...
        'simulink-subchart',...
        'simulink-block',...
        'simulink-subsystem',...
        'simulink-eml',...
        'simulink-model',...
        'simulink-testseq',...
        'simulink-component',...
        'systemcomposer-port',...
        'systemcomposer-physical-port',...
        'simulink-area-annotation',...
        'simulink-assertion',...
        'systemcomposer-model',...
        'faultanalyzer-fault',...
        'faultanalyzer-conditional',...
        'unresolved-item',...
        },...
        {...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','State_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','ActionState_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','ConnectiveJunction_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','DefaultTransition_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','reqblkicon_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','Box_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','SimulinkFunction_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','StateflowFunction_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','EmbeddedMATLABFunction_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','TruthTable_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','HistoryJunction_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','NoteAdd_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Palette','16px','stateflow','ImageAdd_mo_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','stateflow','sfsnr2','StateflowChart_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Toolbars','16px','Subchart_16.png'),...
        fullfile(matlabroot,'toolbox','shared','reqmgt','icons','BlockIcon.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','SubSystemIcon.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','ModelBrowser','16px','EmbeddedMATLABfunction_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Toolbars','16px','SimulinkModel_16.png'),...
        fullfile(matlabroot,'toolbox','shared','reqmgt','icons','testsequence_16.png'),...
        fullfile(matlabroot,'toolbox','shared','reqmgt','icons','zcComponent.png'),...
        fullfile(matlabroot,'toolbox','shared','reqmgt','icons','zcPort.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','ARCHITECTURE','PhysicalPort_16.svg'),...
        fullfile(matlabroot,'toolbox','shared','reqmgt','icons','BlockIcon.png'),...
        fullfile(matlabroot,'toolbox','shared','reqmgt','icons','BlockIcon.png'),...
        fullfile(matlabroot,'toolbox','shared','reqmgt','icons','zcModel.png'),...
        fullfile(matlabroot,'toolbox','shared','simulinktest','resources','icons','InjectorBolt16px.svg'),...
        fullfile(matlabroot,'toolbox','shared','safety','resources','icons','function_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','warning_16.png'),...
        });
    end

    properties(Hidden)
harnessIdMap
    end

    methods
        function this=SLAdapter()
            this.domain='linktype_rmi_simulink';
            this.currentArtifact='';
            this.harnessIdMap=containers.Map('KeyType','char','ValueType','char');
        end

        function icon=getIcon(this,artifact,id)

            if this.isTextRange(id)
                simulinktype='simulink-eml';
            else
                simulinktype=slreq.utils.getSLType(artifact,id);
            end
            icon=this.domain2IconMap(simulinktype);
        end

        function str=getGlobalUniqueId(~,artifact,id)
            str=sprintf('%s%s',artifact,id);
        end

        function tf=isResolved(this,artifact,id)%#ok<INUSL>
            if~dig.isProductInstalled('Simulink')
                tf=false;
                return;
            end
            [~,modelName]=fileparts(artifact);




            longId=id;
            [itemId,prefix]=slreq.utils.getShortIdFromLongId(id);

            try
                sid='';
                if isempty(itemId)||itemId(1)==':'



                    sid=[modelName,strtok(itemId,'.')];
                elseif~isempty(prefix)
                    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
                    if~isempty(linkSet)

                        srcItem=linkSet.getLinkedItem(longId);
                        if~isempty(srcItem)&&srcItem.isTextRange()
                            sid=[modelName,srcItem.getTextNodeId()];
                        end
                    end
                elseif sysarch.isZCElement(itemId)

                    tf=true;
                    return;
                else

                    disp(['ERROR: invalid ID format in a call to SLAdapter.isResolved(): ',itemId]);
                end
                if isempty(sid)
                    tf=false;
                else

                    objH=[];
                    if rmisl.isHarnessIdString(sid)
                        [~,objH]=rmisl.resolveObjInHarness(sid);
                    elseif rmifa.isFaultIdString(sid)
                        objH=rmifa.resolveObjInFaultInfo(sid);
                    else
                        if bdIsLoaded(modelName)
                            objH=rmisl.getHandleFromFullSID(sid);

                        end
                    end
                    tf=~isempty(objH)&&objH~=-1;
                end
            catch ME %#ok<NASGU>



                tf=false;
            end
        end

        function success=select(this,artifact,id,caller)
            success=true;
            if nargin<4
                caller='';
            end
            [~,modelName]=fileparts(artifact);


            st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if bdIsLoaded(modelName)&&Simulink.internal.isArchitectureModel(modelName)&&~isempty(st)&&st(1).App.hasSpotlightView()
                sysarch.highlightAndFadeInSpotlight(modelName,id,st(1));
            else
                this.navigateToModelObj(modelName,id,caller);

            end
        end

        function success=highlight(this,artifact,id,caller)
            if~exist('caller','var')||isempty(caller)
                caller='';
            end
            success=select(this,artifact,id,caller);
        end

        function label=getLinkLabel(this,artifact,id)


            [label,isText]=this.getSummary(artifact,id);
            if~isText

                shortFilename=slreq.uri.getShortNameExt(artifact);
                label=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',label,shortFilename));
            end
        end

        function[str,isText]=getSummary(this,artifact,id)




            isText=false;


            [~,modelName]=fileparts(artifact);
            if this.isResolved(artifact,id)
                if this.isZC(id)
                    str=this.getSummaryStrSysarch(artifact,id);
                    return;
                elseif this.isTextRange(id)
                    str=this.getSummaryStrMATLAB(artifact,id);
                    isText=true;
                    return;
                elseif rmifa.isFaultIdString(id)
                    [fault,~]=rmifa.getFaultInfoObj(artifact,id);
                    str=fault.Name;
                    return;
                end
                sid=[modelName,id];
                str=rmi.objname(sid);
            else
                str=sprintf('%s%s',modelName,id);
                if rmisl.isHarnessIdString(id)
                    str=sprintf('%s:%s',modelName,'??');
                end
            end
        end

        function tooltip=getTooltip(this,artifact,id)

            if~this.isResolved(artifact,id)
                if rmisl.isHarnessIdString(id)
                    tooltip=getString(message('Slvnv:slreq:UnableToResolveLinkTargetForHarness'));
                else
                    tooltip=getString(message('Slvnv:slreq:UnableToResolveLinkSource',artifact,id));
                end
                return;
            end

            if sysarch.isZCElement(id)
                [~,tooltip]=this.getSummaryStrSysarch(artifact,id);
                return;
            end

            if rmifa.isFaultIdString(id)
                [faultInfoObj,~]=rmifa.getFaultInfoObj(artifact,id);
                tooltip=rmifa.getDisplayString(faultInfoObj);
                return;
            end

            if this.isTextRange(id)
                [~,tooltip]=this.getSummaryStrMATLAB(artifact,id);
                return;
            end

            [~,modelName]=fileparts(artifact);
            sid=[modelName,id];
            [~,objType,objH]=rmi.objname(sid);


            trgtobjH=slreq.utils.getRMISLTarget(objH,true);
            if~isequal(trgtobjH,objH)
                objH=trgtobjH;
                sr=sfroot;
                if sr.isValidSlObject(objH)
                    sid=Simulink.ID.getSID(objH);
                else
                    trgtObj=sr.idToHandle(trgtobjH);
                    sid=Simulink.ID.getSID(trgtObj);
                end
            end
            if~isempty(objH)

                dot=strfind(sid,'.');
                if~isempty(dot)&&strcmp(objType,'SigBuilder')
                    [~,tooltip]=rmi.objinfo(sid(1:dot(1)-1));
                    tooltip=strrep(tooltip,'(SubSystem)','(SigBuilder)');
                else
                    [~,tooltip]=rmi.objinfo(sid);
                end
            else
                if rmisl.isHarnessIdString(sid)
                    tooltip=getString(message('Slvnv:slreq:UnableToResolveLinkTargetForHarness'));
                else
                    tooltip=getString(message('Slvnv:slreq:ObjInfoNotAvailable'));
                end
            end
        end

        function apiObj=getSourceObject(this,artifact,id)
            apiObj=[];
            [~,diagName]=fileparts(artifact);
            if~any(strcmp(find_system('type','block_diagram'),diagName))
                rmiut.warnNoBacktrace('Slvnv:slreq:ArtifactNotLoaded',diagName);
            end

            if this.isTextRange(id)
                [textId,parentSID]=slreq.utils.getShortIdFromLongId(id);



                sid=[diagName,parentSID];
                isCode=true;
            else

                sid=[diagName,id];
                isCode=false;
            end
            try
                if isCode

                    dataLinkSet=slreq.utils.getLinkSet(artifact,this.domain,false);
                    if~isempty(dataLinkSet)
                        textItem=dataLinkSet.getTextItem(parentSID);
                        if~isempty(textItem)
                            dataTextRange=textItem.getRange(textId);
                            if~isempty(dataTextRange)
                                apiObj=slreq.TextRange(dataTextRange);
                            end
                        end
                    end
                elseif sysarch.isZCElement(id)
                    apiObj=sysarch.getWrapperForArchElement(id,diagName);
                elseif rmifa.isFaultIdString(id)
                    apiObj=rmifa.getFaultInfoObj(artifact,id);
                else
                    if rmisl.isHarnessIdString(id)
                        objectSid=slreq.utils.getObjSidFromHarnessIdString([diagName,id]);
                    else
                        objectSid=sid;
                    end
                    apiObj=Simulink.ID.getHandle(objectSid);
                    if~isa(apiObj,'Stateflow.Object')
                        apiObj=get_param(apiObj,'Object');
                        if Simulink.internal.isArchitectureModel(diagName)
                            archElem=systemcomposer.utils.getArchitecturePeer(apiObj.Handle);
                            apiObj=sysarch.getWrapperForArchElement(archElem.getZCIdentifier,diagName);
                        end
                    end
                end
            catch ME %#ok<NASGU>
                rmiut.warnNoBacktrace('Slvnv:slreq:UnableToResolveObject',sid);
            end
        end

        function success=onClickHyperlink(this,artifact,id,caller)
            success=true;
            if nargin<4
                caller='';
            end
            this.select(artifact,id,caller);
        end

        function cmdStr=getClickActionCommandString(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            [~,mdlName]=fileparts(artifact);
            if~this.isResolved(artifact,id)
                cmdStr=sprintf('slreq.adapters.SLAdapter.navigate(''%s'',''%s'',''%s'',''select'')',...
                mdlName,id,caller);
                return;
            end
            if this.isTextRange(id)

                [mlArtifact,mlId]=slreq.adapters.SLAdapter.getMatlabEditorIds(artifact,id);
                cmdStr=rmiml.bookmarkInfo(mlArtifact,mlId);
            else
                cmdStr=sprintf('slreq.adapters.SLAdapter.navigate(''%s'',''%s'',''%s'',''select'')',...
                mdlName,id,caller);
            end
        end

        function navCmd=getExternalNavCmd(this,artifact,id)




            if this.isTextRange(id)


                [mlArtifact,mlId]=slreq.adapters.SLAdapter.getMatlabEditorIds(artifact,id);
                navCmd=sprintf('rmicodenavigate(''%s'',''%s'')',mlArtifact,mlId);
            else


                modlNameExt=slreq.uri.getShortNameExt(artifact);
                navCmd=sprintf('rmiobjnavigate(''%s'',''%s'')',modlNameExt,id);
            end
        end

        function url=getURL(this,artifact,id)


            navCmd=this.getExternalNavCmd(artifact,id);
            url=rmiut.cmdToUrl(navCmd,false);
        end

        function fullPath=getFullPathToArtifact(~,artifact,varargin)
            if rmiut.isCompletePath(artifact)
                fullPath=artifact;
            else
                fullPath=rmi.locateFile(artifact,varargin{:});
            end
        end

        function refreshLinkOwner(~,linkedArtifact,linkedId,oldDestInfo,newDestInfo)
            if length(oldDestInfo)==length(newDestInfo)


                return;
            end
            [~,modelName]=fileparts(linkedArtifact);

            if any(linkedId=='~')


                [localId,textNodeId]=slreq.utils.getShortIdFromLongId(linkedId);
                editorName=[modelName,textNodeId];
                rmiml.notifyEditor(editorName,localId);
            else

                try
                    modelH=get_param(modelName,'Handle');
                    objH=Simulink.ID.getHandle([modelName,linkedId]);
                    if isa(objH,'Stateflow.Object')
                        isSf=true;
                        objH=objH.Id;
                    else
                        isSf=false;
                    end
                    rmisl.postSetReqsUpdates(modelH,objH,isSf,oldDestInfo,newDestInfo);
                catch ME %#ok<NASGU>

                end
            end
        end




        function tf=isImplementingSaveAs(~)
            tf=true;
        end



        function postSaveAsReset(this,newName)

            this.currentArtifact=newName;
            this.harnessIdMap=containers.Map('KeyType','char','ValueType','char');
        end



        function postSaveAsUpdate(this,dataObj)
            if isa(dataObj,'slreq.data.SourceItem')

                origId=dataObj.id;
                if rmisl.isHarnessIdString(origId)
                    [oldHarnessId,localId]=rmisl.splitHarnessId(origId);
                    newId=this.harnessIdMapHelper(oldHarnessId);
                    if~isempty(newId)
                        dataObj.rename([newId,localId]);
                    end
                else
                    [mdlName,tableSID,reqID]=rmisl.ReqTableUtils.splitEmbeddedReqIdString(origId);
                    if~any(cellfun(@isempty,{mdlName,tableSID,reqID}))

                        reqSetName=[this.currentArtifact,'_',tableSID,'.slreqx'];
                        newId=slreq.internal.LinkUtil.makeCompositeId(reqSetName,reqID);
                        dataObj.rename(newId);
                    end
                end
            elseif isa(dataObj,'slreq.data.Link')

                if rmisl.isHarnessIdString(dataObj.destId)



                    storedId=dataObj.destId;
                    oldHarnessId=rmisl.splitHarnessId(storedId);



                    newHarnessId=this.harnessIdMapHelper(oldHarnessId);

                    if isempty(newHarnessId)


                    else

                        dataObj.destId=strrep(storedId,oldHarnessId,newHarnessId);

                        dataObj.description=strrep(dataObj.description,oldHarnessId,newHarnessId);
                    end
                end
            else
                error('adapter.postSaveAsUpdate() called for unexpected type %s',class(dataObj));
            end
        end



        function artifactId=getArtifactIdFromSourceItem(this,srcItem)%#ok<INUSL>
            if srcItem.isTextRange()

                artifactId=slreq.utils.getLongIdFromShortId(srcItem.getTextNodeId,srcItem.id);
            else
                artifactId=srcItem.id;
            end
        end




        function artifactUri=getArtifactUriFromReq(this,dataReq)%#ok<INUSL>
            artifactUri=dataReq.artifactUri;
        end

        function linkType=getDefaultLinkType(~,artifactUri,artifactId)
            slType=slreq.utils.getSLType(artifactUri,artifactId);
            switch slType
            case{'simulink-annotation','faultanalyzer-fault','faultanalyzer-conditional'}
                linkType=slreq.custom.LinkType.Relate;
            case 'simulink-testseq'
                if reqmgt('rmiFeature','TestSeqVerif')...
                    &&slreq.adapters.SLAdapter.isVerificationStep(artifactUri,artifactId)
                    linkType=slreq.custom.LinkType.Verify;
                else
                    linkType=slreq.custom.LinkType.Relate;
                end
            case 'simulink-assertion'
                linkType=slreq.custom.LinkType.Verify;
            otherwise
                linkType=slreq.custom.LinkType.Implement;
            end
        end

        function preSave(~,dataLinkSet)


            if slreq.utils.isEmbeddedLinkSet(dataLinkSet)
                [outData.packageName,slreqPartLocation]=slreq.utils.getPackageLocation(dataLinkSet.artifact,dataLinkSet.filepath);
                if~isempty(outData.packageName)
                    if~strcmp(slreqPartLocation,dataLinkSet.filepath)
                        dataLinkSet.filepath=slreqPartLocation;
                    end
                end
            end



            if~isempty(dataLinkSet.getTextItemIds())
                mlAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_matlab');
                mlAdapter.preSave(dataLinkSet);
            end
        end

        function postSave(~,dataLinkSet,artifactUri)
            if~slreq.utils.isEmbeddedLinkSet(dataLinkSet)
                return;
            end


            if~isempty(artifactUri)


                slreq.utils.setPackageDirty(artifactUri);
            else

                slreq.utils.setPackageDirty(dataLinkSet.artifact);
            end
        end



        function[status,revisionInfo]=getRevisionInfo(~,sourceObj)
            status=slreq.analysis.ChangeStatus.UnsupportedArtifact;
            revisionInfo=slreq.utils.DefaultValues.getRevisionInfo();

            if sourceObj.isTextRange()


                mlAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_matlab');
                [status,revisionInfo]=mlAdapter.getRevisionInfo(sourceObj);
            end
        end

    end

    methods(Access=protected)

        function tf=isZC(~,id)
            tf=sysarch.isZCElement(id);
        end

        function tf=isTextRange(~,id)
            tf=contains(id,'~');
        end

        function[str,tooltip]=getSummaryStrSysarch(~,artifact,id)

            try
                [~,modelName]=fileparts(artifact);
                str=sysarch.getSummary(id,modelName);
                fullpaths=sysarch.getFullPath(id,modelName);
                tooltip='';


                for n=1:length(fullpaths)
                    if n~=1

                        tooltip=[tooltip,'<br>'];%#ok<AGROW>
                    end
                    tooltip=[tooltip,fullpaths{n}];%#ok<AGROW>
                end
            catch ex %#ok<NASGU>
                str=getString(message('Slvnv:slreq:UnableToResolveArchitectureObject',modelName));
                tooltip=str;
            end
        end

        function[str,tooltip]=getSummaryStrMATLAB(~,artifact,id)
            if any(id=='~')
                [mlArtifact,mlId]=slreq.adapters.SLAdapter.getMatlabEditorIds(artifact,id);
            else
                mlArtifact=artifact;
                mlId=id;
            end
            str=rmiml.getText(mlArtifact,mlId);
            if numel(str)>50
                str=[str(1:50),'...'];
            end
            str=strrep(str,newline,' ');
            tooltip=getString(message('Slvnv:rmiml:NamedRangeIn',mlId,slreq.uri.getShortNameExt(artifact)));
        end

        function navigateToModelObj(~,modelName,id,caller)




            if rmisl.isSidString(modelName)||any(id=='~')



                if any(id=='~')

                    [id,parent]=slreq.utils.getShortIdFromLongId(id);
                    mEditorId=[modelName,parent];
                else

                    mEditorId=modelName;
                end
                rmi.navigate('linktype_rmi_matlab',mEditorId,id,caller);
                return;
            end


            if~bdIsLoaded(modelName)
                try
                    open_system(modelName);
                catch ME %#ok<NASGU> 
                    dispId=[modelName,id];
                    if rmisl.isHarnessIdString(id)
                        errordlg(getString(message('Slvnv:slreq:InvalidHarnessItem',dispId)),getString(message('Slvnv:rmi:navigate:NavigationError')));
                    else
                        errordlg(getString(message('Slvnv:slreq:InvalidSimulinkItem',dispId)),getString(message('Slvnv:rmi:navigate:NavigationError')));
                    end
                    return;
                end
            end

            action_highlight('clear');

            if isnumeric(id)





                objH=id;
            else
                grpIdx=[];
                if contains(id,'.')

                    [id,tail]=strtok(id,'.');
                    if length(tail)>1
                        grpIdx=str2double(tail(2:end));
                    end
                end

                if rmisl.isHarnessIdString(id)
                    [isSf,objH]=rmisl.resolveObjInHarness([modelName,id]);

                    if isempty(objH)



                        errordlg(getString(message('Slvnv:slreq:InvalidHarnessItem',modelName)),getString(message('Slvnv:rmi:navigate:NavigationError')));
                        return;
                    end

                    if isSf

                        objH=idToHandle(sfroot,objH);
                    end
                elseif~isempty(id)&&sysarch.isZCElement(id)

                    sysarch.navigate(id,modelName);
                    return;
                elseif rmifa.isFaultIdString(id)
                    rmifa.navigate(modelName,id);
                    return;
                else
                    try
                        objH=Simulink.ID.getHandle([modelName,id]);
                    catch ex %#ok<NASGU>
                        errordlg(getString(message('Slvnv:slreq:InvalidSimulinkItem',modelName)),getString(message('Slvnv:rmi:navigate:NavigationError')));
                        return;
                    end
                end
            end




            st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(st)
                mostActiveStudio=st(1);
                piCmp=mostActiveStudio.getComponent('GLUE2:PropertyInspector','Property Inspector');
                piObj=piCmp.getInspector;
                piObj.setSticky(true);

                cleanup=onCleanup(@()piObj.setSticky(false));
            end
            objH=slreq.utils.getRMISLTarget(objH,true,true);
            if isa(objH,'Stateflow.Object')

                if isa(objH.Chart,'Stateflow.ReactiveTestingTableChart')
                    rmi.navigate('linktype_rmi_simulink',modelName,id);
                else
                    sfView=objH.Subviewer;
                    if~isempty(sfView)
                        sfView.view;
                    end
                    if isa(objH,'Stateflow.Transition')&&Stateflow.ReqTable.internal.TableManager.isParentedBySpecBlock(objH)
                        chartId=sf('get',objH.Id,'.chart');
                        Stateflow.ReqTable.internal.TableManager.higlightImplicationForTransition(chartId,objH);
                    else
                        objH.fitToView;
                    end
                end
            else

                parent=get_param(objH,'Parent');
                if isempty(parent)
                    try
                        if strcmpi(get(objH,'Type'),'block_diagram')
                            studioHelper=slreq.utils.DAStudioHelper.createHelper(mostActiveStudio);
                            if studioHelper.CurrentCanvasHandle==objH

                                studioHelper.bringStudioToTop();
                            else
                                open_system(objH);
                            end
                            set_param(objH,'ZoomFactor','FitToView');
                        end
                    catch ex %#ok<NASGU>


                    end

                    return;
                else
                    open_system(parent,'force')


                    Simulink.scrollToVisible(objH,'ensureFit','off','panMode','minimal');
                end

            end


            rmiut.hiliteAndFade(objH);

            if rmisl.is_signal_builder_block(objH)&&~isempty(grpIdx)
                open_system(objH);
                signalbuilder(objH,'activegroup',grpIdx);
            end
        end





        function newId=harnessIdMapHelper(this,storedId)
            if isKey(this.harnessIdMap,storedId)

                newId=this.harnessIdMap(storedId);
            else

                newId=rmisl.getUpdatedHarnessId(this.currentArtifact,storedId);
                this.harnessIdMap(storedId)=newId;
            end
        end
    end

    methods(Static)
        function navigate(artifact,id,caller,actionType)
            if nargin<4
                actionType='select';
            end
            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_simulink');
            if adapter.isTextRange(id)

                [mlEditorItem,msEditorId]=slreq.adapters.SLAdapter.getMatlabEditorIds(artifact,id);
                rmicodenavigate(mlEditorItem,msEditorId);
            else
                if dig.isProductInstalled('Simulink')&&license('test','simulink')
                    switch actionType
                    case 'select'
                        adapter.select(artifact,id,caller);
                    case 'highlight'
                        adapter.highlight(artifact,id,caller);
                    end
                else
                    errordlg(getString(message('Slvnv:slreq:CannotNavigateInvalidLicense','Simulink')),...
                    getString(message('Slvnv:rmi:navigate:NavigationError')));
                end
            end
        end

        function tf=isVerificationStep(artifact,id)
            tf=false;
            [~,modelName]=fileparts(artifact);
            harnessIdString=sprintf('%s%s',modelName,id);
            [~,objType,objH]=rmi.objname(harnessIdString);
            if objType=="Step"

                sfr=sfroot;
                stepObj=sfr.idToHandle(objH);

                [blockPath,stepName]=getFullStepName(stepObj);
                actionText=sltest.testsequence.readStep(blockPath,stepName,'Action');

                parseTree=mtree(actionText,'-comments');
                if parseTree.isnull||parseTree.root.iskind('ERR')
                    return;
                end

                verifyCalls=parseTree.find('Kind','ID','String',{'verify'}).strings();
                tf=~isempty(verifyCalls);
            end

            function[blockPath,fullStepName]=getFullStepName(stepObj)




                currentObj=stepObj;
                fullStepName=stepObj.Name;
                while isa(currentObj.getParent(),'Stateflow.State')
                    currentObj=currentObj.getParent();
                    fullStepName=sprintf('%s.%s',currentObj.Name,fullStepName);
                end
                blockPath=currentObj.getParent().Path;
            end
        end
    end

    methods(Static,Access=private)
        function[editorItem,editorId]=getMatlabEditorIds(storedArtifact,storedId)







            [rangeId,mfSID]=slreq.utils.getShortIdFromLongId(storedId);
            if~isempty(mfSID)
                [~,modelName]=fileparts(storedArtifact);
                editorItem=[modelName,mfSID];
                editorId=rangeId;
            else


                editorItem=storedArtifact;
                editorId=storedId;
            end
        end
    end
end
