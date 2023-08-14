classdef Informer<cvi.HiliteBase




    properties(SetObservable=true)
        infrmObj=[]
        modelcovIds=[]
        windowTitle=''
        defaultWindowText=''
        badgeHandlers=[]
        options=[]
        dockedReports=[]
        reportManager=[]

    end

    methods(Static=true)

        function obj=createInstance(modelcovId,options)
            cvi.Informer.close(modelcovId)
            obj=cvi.Informer(modelcovId,options);
            cv('set',modelcovId,'modelcov.currentDisplay.informer',obj);
        end
        function res=getInstance(modelcovId)
            res=[];

            if SlCov.CoverageAPI.isaValidCvId(modelcovId,'modelcov.isa')
                obj=cv('get',modelcovId,'.currentDisplay.informer');
                if isa(obj,'cvi.Informer')
                    res=obj;
                end
            end
        end
        function refreshReopenedRefModel(modelH)
            try
                allModelCovIds=cv('find','all','.isa',cv('get','default','modelcov.isa'));
                if isempty(allModelCovIds)
                    return;
                end

                modelName=get_param(modelH,'name');
                modelcovId=[];
                for idx=1:numel(allModelCovIds)
                    if strcmpi(modelName,SlCov.CoverageAPI.getModelcovName(allModelCovIds(idx)))
                        modelcovId=allModelCovIds(idx);
                        break;
                    end
                end
                if~isempty(modelcovId)
                    topModelcovId=cv('get',modelcovId,'.topModelcovId');
                    if~isempty(topModelcovId)&&topModelcovId~=0
                        h=cvi.Informer.getInstance(topModelcovId);
                        if isa(h,'cvi.Informer')
                            allTestIds=cv('find','all','.isa',cv('get','default','testdata.isa'));
                            informerModelcovIds=h.modelcovIds;
                            testIds=[];
                            for idx=1:numel(allTestIds)
                                tmc=cv('get',allTestIds(idx),'.modelcov');
                                if any(informerModelcovIds==tmc)
                                    testIds=[testIds,allTestIds(idx)];%#ok<AGROW>
                                end
                            end
                            if numel(testIds)==1
                                cvd=cvdata(testIds);
                            else
                                cvd=cv.cvdatagroup;
                                for idx=1:numel(testIds)
                                    cvd.add(cvdata(testIds(idx)));
                                end
                            end
                            cvmodelview(cvd);
                        end
                    end
                end
            catch MEx %#ok<NASGU>

            end
        end

        function close(modelcovId)
            try
                if~cv('ishandle',modelcovId)
                    return
                end
                [infrmObj,mdlcovId]=cvi.Informer.findInformerModelCov(modelcovId);
                if~isempty(infrmObj)
                    infrmObj.destroy();
                    cv('set',mdlcovId,'.currentDisplay.informer',[]);
                    delete(infrmObj);
                    modelH=cv('get',modelcovId,'.handle');
                    cvi.Informer.markHighlightingApplied(modelH,false);
                end
            catch MEx
                rethrow(MEx);
            end
        end

        function[obj,mdlcovId]=findInformer(modelH)
            modelcovId=get_param(modelH,'CoverageId');
            [obj,mdlcovId]=cvi.Informer.findInformerModelCov(modelcovId);
        end

        function[obj,mdlcovId]=findInformerModelCov(modelcovId)
            obj=[];
            mdlcovId=[];

            if~SlCov.CoverageAPI.isaValidCvId(modelcovId,'modelcov.isa')
                return;
            end

            topModelcovId=cv('get',modelcovId,'.topModelcovId');
            if SlCov.CoverageAPI.isaValidCvId(topModelcovId,'modelcov.isa')
                infrmObj=cvi.Informer.getInstance(topModelcovId);
                if isa(infrmObj,'cvi.Informer')
                    obj=infrmObj;
                    mdlcovId=topModelcovId;
                    return;
                end
            else

                topModelcovId=0;
            end


            ownerModel=cv('get',modelcovId,'.ownerModel');
            if~isempty(ownerModel)&&bdIsLoaded(ownerModel)
                ownerModelId=get_param(ownerModel,'CoverageId');
                infrmObj=cvi.Informer.getInstance(ownerModelId);
                if isa(infrmObj,'cvi.Informer')
                    obj=infrmObj;
                    mdlcovId=ownerModelId;
                    return;
                end
            end


            infrmObj=cvi.Informer.getInstance(modelcovId);
            if isa(infrmObj,'cvi.Informer')
                obj=infrmObj;
                mdlcovId=modelcovId;
                return;
            end



            if topModelcovId==0
                return;
            end
            allModelcovIds=cv('find','all','.isa',cv('get','default','modelcov.isa'));
            allInstances=cv('get',allModelcovIds,'.currentDisplay.informer');
            refModelCvId=cv('get',topModelcovId,'.refModelcovIds');

            relatedCvIds=unique([modelcovId,refModelCvId,topModelcovId]);
            for idx=1:numel(allInstances)
                if isempty(allInstances{idx})
                    continue;
                end
                infrmObj=allInstances{idx};
                if isa(infrmObj,'cvi.Informer')&&~isempty(intersect(relatedCvIds,infrmObj.modelcovIds))
                    mdlcovId=allModelcovIds(idx);
                    obj=infrmObj;
                    return;
                end
            end
        end

        function session=getCovStyleSession(modelH)
            session=[];
            infrmObj=cvi.Informer.findInformer(modelH);


            if isa(infrmObj,'cvi.Informer')
                session=infrmObj.covStyleSession;
            end
        end

        function colorTable=cvi.Informer.getHighlightingColorTable
            colorTable=cvi.HiliteBase.getHighlightingColorTable;
        end

        function out=covcolordata_struct
            out=struct('mappedBlks',[],...
            'FGColor',[],...
            'BGColor',[],...
            'systems',[],...
            'screenColors',[],...
            'sfLinkInfo',[]);
        end
    end


    methods(Static=true)

        function removeColor(modelH)
            if ishandle(modelH)
                [clr,isLocked]=cvprivate('unlockModel',modelH);
                if isLocked&&isempty(clr)

                    return
                end
                modelColorData=get_param(modelH,'covColorData');
                if~isempty(modelColorData)||SlCov.CovStyle.IsFeatureEnabled()
                    cvslhighlight('revert',modelH);
                    cvprivate('cv_remove_sfhighlight',get_param(modelH,'CoverageId'));
                end
            end
        end


        function str=defaultText

            str=[
            '<table>',10...
            ,'<tr> <td align=center>',10...
            ,'<h3>',getString(message('Slvnv:simcoverage:cvmodelview:InformerDeafultTxt0')),'</h3>',10...
            ,getString(message('Slvnv:simcoverage:cvmodelview:InformerDeafultTxt1')),10...
            ,getString(message('Slvnv:simcoverage:cvmodelview:InformerDeafultTxt2')),10...
            ,'</td> </tr>',10...
            ,'</table>',10...
            ];
        end



        function markHighlightingAvailable(model,isAvailable,setOnHarness,skipIfHarness)
            try
                if nargin<3
                    setOnHarness=true;
                end
                if nargin<4
                    skipIfHarness=false;
                end

                curModelId=get_param(model,'CoverageId');
                if SlCov.CoverageAPI.isaValidCvId(curModelId,'modelcov.isa')
                    harnessModel=cv('get',curModelId,'.harnessModel');
                else
                    harnessModel=[];
                end
                if~isempty(harnessModel)
                    if skipIfHarness

                        harnessModelH=get_param(harnessModel,'handle');
                        thisModelH=get_param(model,'handle');
                        if(harnessModelH==thisModelH)
                            return;
                        end
                    end

                    if setOnHarness

                        cvi.Informer.markHighlightingAvailable(harnessModel,isAvailable,false,false);
                    end
                end

                clr=cvprivate('unlockModel',model);%#ok<NASGU>

                if isAvailable
                    set_param(model,'CovUI_isHighlightingAvailable','on');
                else
                    set_param(model,'CovUI_isHighlightingAvailable','off');
                    set_param(model,'CovUI_IsHighlightingApplied','off');
                    set_param(model,'CovUI_areDetailsShowing','off');
                end
            catch
                return
            end
        end


        function markHighlightingApplied(model,isApplied,setOnHarness)
            try
                if nargin<3
                    setOnHarness=true;
                end

                if setOnHarness

                    curModelId=get_param(model,'CoverageId');
                    harnessModel=cv('get',curModelId,'.harnessModel');
                    if~isempty(harnessModel)
                        cvi.Informer.markHighlightingApplied(harnessModel,isApplied,false);
                    end
                end

                clr=cvprivate('unlockModel',model);%#ok<NASGU>

                if isApplied
                    set_param(model,'CovUI_isHighlightingAvailable','on');
                    set_param(model,'CovUI_IsHighlightingApplied','on');
                else
                    set_param(model,'CovUI_IsHighlightingApplied','off');
                    set_param(model,'CovUI_areDetailsShowing','off');
                end


                simulinkcoder.internal.Report.getInstance.refresh(model);
            catch
                return
            end
        end


    end

    methods
        function this=Informer(modelcovId,options)

            modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);
            this.windowTitle=[getString(message('Slvnv:simcoverage:cvmodelview:Coverage')),': ',modelName];
            this.defaultWindowText=cvi.Informer.defaultText;

            this.badgeHandlers=[];
            this.modelcovIds=[];

            modelH=cv('get',modelcovId,'.handle');
            this.covStyleSession=SlCov.CovStyle.Session(modelH);
            this.options=options;
            this.dockedReports=containers.Map('KeyType','char','ValueType','Any');
            this.reportManager=cvi.DetailedReportManager(modelName,options.contextInfo);
        end


        function destroy(this)
            for sIdx=1:numel(this.modelcovIds)
                cvId=this.modelcovIds(sIdx);
                if cv('ishandle',cvId)
                    handle=cv('get',cvId,'.handle');
                    cvi.Informer.removeColor(handle);

                    this.removeBadges();
                    if this.options.explorerGeneratedHighlight
                        modelName=SlCov.CoverageAPI.getModelcovName(cvId);
                        cvi.ResultsExplorer.ResultsExplorer.highlightRemoved(modelName);
                    end
                    cvi.Informer.markHighlightingApplied(handle,false);
                end
            end


            if~isvalid(this)
                return;
            end
            if~isempty(this.infrmObj)&&ishandle(this.infrmObj)
                this.infrmObj.preCloseFcn='';
                this.infrmObj.hide;
            end

            allDockedReports=this.dockedReports.values;
            for sIdx=1:numel(allDockedReports)
                sDR=allDockedReports{sIdx};
                for idx=1:numel(sDR)
                    curDr=sDR(idx);
                    delete(curDr);
                end
            end

            delete(this.reportManager);
        end

        function badgeHandler=initBadgeHandler(this,modelName,allCovData,options,covStyleSession)
            modelH=get_param(modelName,'handle');

            badgeHandler=findBadgeHandler(this,modelH);
            if~isempty(badgeHandler)
                badgeHandler.setOptions(options);
            else
                badgeHandler=cvi.BadgeHandler(modelName,allCovData,options,covStyleSession);
                ns=struct('modelH',modelH,'badgeHandler',badgeHandler);
                if isempty(this.badgeHandlers)
                    this.badgeHandlers=ns;
                else
                    this.badgeHandlers(end+1)=ns;
                end
            end
        end

        function badgeHandler=findBadgeHandler(this,modelHandle)
            badgeHandler=[];
            if isempty(this.badgeHandlers)
                return;
            end
            bhStruct=this.badgeHandlers([this.badgeHandlers.modelH]==modelHandle);
            if~isempty(bhStruct)
                badgeHandler=bhStruct.badgeHandler;
            end
        end


        function key=getBadgeHandlerKey(~,modelName)

            modelName=strrep(modelName,' ','_');
            modelName=strrep(modelName,'(','');
            key=strrep(modelName,']','');
        end


        function removeBadges(this)
            if isempty(this.badgeHandlers)
                return;
            end
            for idx=1:numel(this.badgeHandlers)
                badgeHandler=this.badgeHandlers(idx).badgeHandler;
                badgeHandler.close;
                delete(badgeHandler);
            end
            this.badgeHandlers=[];
        end

        function res=getSelectedText(this)
            res=this.infrmObj.text;
        end
        function res=visible(this)
            res=this.infrmObj.visible;
        end
        function res=mode(this)
            res=this.infrmObj.mode;
        end

        function addToMap(this,udiObj,htmlStr)
            if ishandle(udiObj)
                this.infrmObj.mapData(udiObj,htmlStr);
            end

        end
        function addModel(this,modelcovId)
            this.modelcovIds=[this.modelcovIds,modelcovId];
        end

        function activateMap(this)
            if~isempty(this.badgeHandlers)
                for idx=1:numel(this.badgeHandlers)
                    badgeHandler=this.badgeHandlers(idx).badgeHandler;
                    badgeHandler.activateBadges();
                end
            end
        end

        function infMap=createWebViewStorage(this)
            infMap=containers.Map;
            if~isempty(this.badgeHandlers)
                for idx=1:numel(this.badgeHandlers)
                    badgeHandler=this.badgeHandlers(idx).badgeHandler;
                    infMap=addToStorage(badgeHandler,infMap);
                end
            end
        end

        function storeColoring(this,fullCovObjs,justifiedCovObjs,missingCovObjs,filteredCovObjs)
            this.coloring.full=fullCovObjs;
            this.coloring.missing=missingCovObjs;
            this.coloring.justified=justifiedCovObjs;
            this.coloring.filtered=filteredCovObjs;
        end

        function ctxInfo=getContextInfo(this,modelName)
            generatedReports=this.reportManager.generatedReports;
            genRep=generatedReports({generatedReports.modelName}==string(modelName));
            ctxInfo=[];
            if~isempty(genRep)
                ctxInfo=genRep.ctxInfo;
            end
        end
    end


    methods
        createDetailedReport(this,covdata)
        dr=createDockedReport(this,studio,covMode,hasMultipleTypes)
        storeDockedReport(this,dr)
        dockedReports=getDockedReportsForStudio(this,studio)
        [urlStr,htmlStr]=getCoverageDetailsContent(this,modelH,covType,selectionH,useModelAsFallback)
    end

    methods(Static=true)
        studios=getStudiosForModels(modelList);
        isVisible=isDockedReportVisibleForActiveStudio()
        dockedReports=getDockedReportsForActiveStudio()
        openCoverageDetails(studio)
    end

end



