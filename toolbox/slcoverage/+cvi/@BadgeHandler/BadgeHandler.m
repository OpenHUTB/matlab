classdef BadgeHandler<cvi.HiliteBase




    properties(Access='private')
    end

    properties(SetAccess=private,GetAccess=public)
        allCovData=[]
        covModes=[]
badgeMap
handleToCvIdMap
cvIdToHtmlMap
options
modelName
        badges=[]
reportName
        stylerName='MathWorks.CoverageToolTip'
        styles=[]
        fullCovStyle=[]
        styler=[]
        colorTable=[];
    end
    methods(Static)
        messages=getFullTextMessages()
    end
    methods

        function this=BadgeHandler(modelName,allCovData,cvhtmlSettings,covStyleSession)
            this.options=cvhtmlSettings;
            this.handleToCvIdMap=containers.Map('KeyType','double','ValueType','Any');
            this.cvIdToHtmlMap=containers.Map('KeyType','double','ValueType','char');
            this.fullCovStyle=containers.Map('KeyType','double','ValueType','Any');
            this.modelName=modelName;
            this.reportName=[modelName,'_BadgeHandler'];

            this.allCovData=allCovData;
            this.covStyleSession=covStyleSession;
            styler=diagram.style.getStyler(this.stylerName);
            if isempty(styler)
                diagram.style.createStyler(this.stylerName);
                styler=diagram.style.getStyler(this.stylerName);
            end
            this.styler=styler;
            this.colorTable=cvi.HiliteBase.getHighlightingColorTable;
        end

        function setOptions(this,cvhtmlSettings)
            this.options=cvhtmlSettings;
        end

        function storeColoring(this,fullCovObjs,justifiedCovObjs,missingCovObjs,filteredCovObjs)
            this.coloring.full=fullCovObjs;
            this.coloring.missing=missingCovObjs;
            this.coloring.justified=justifiedCovObjs;
            this.coloring.filtered=filteredCovObjs;
        end


        function strHtml=getStrHtml(this,cvId)
            strHtml=this.objToTextMap(cvId);


            pos=strfind(strHtml,'<br>');
            if~isempty(pos)
                strHtml=replaceBetween(strHtml,pos(1),pos(1)+3,'');
            end



            strHtml=['<html>',strHtml,'</html>'];
        end

        function activateBadges(this)
            keys=this.objToTextMap.keys;
            for idx=1:numel(keys)
                cvId=keys{idx};
                [udiObj,handle]=getUdiObj(this,cvId);
                strHtml=getStrHtml(this,cvId);
                addStyleAndBadge(this,cvId,[],handle,udiObj,strHtml);
            end
        end

        function checkSFStates(this,parentCvId)
            sfStateType=sf('get','default','state.isa');
            if cv('get',parentCvId,'.refClass')==sfStateType
                children=cv('ChildrenOf',parentCvId);
                if isempty(children)
                    return;
                end
                stateChildren=cv('find',children,'.refClass',sfStateType);
                for idx=1:numel(stateChildren)
                    cvId=stateChildren(idx);
                    allMetrics=cv('get',cvId,'.metrics');
                    if isempty(allMetrics)

                        parentName=cv('GetSlsfName',parentCvId);
                        strHtml=getString(message('Slvnv:simcoverage:cvmodelview:SFSeeParentCoverage',parentName));
                        [udiObj,handle]=getUdiObj(this,cvId);
                        addStyleAndBadge(this,cvId,parentCvId,handle,udiObj,strHtml);
                    end
                end
            end
        end


        function addStyleAndBadge(this,cvId,paretnCvId,handle,udiObj,strHtml)
            if~isempty(udiObj)
                this.handleToCvIdMap(handle)=[cvId,paretnCvId];
                [diagramObjOut,diagramObjIn]=this.diagramResolve(udiObj);
                addStyle(this,diagramObjOut,cvId,strHtml);
                this.addBadge(diagramObjOut,strHtml);
                this.addBadge(diagramObjIn,strHtml);
                checkSFStates(this,cvId);
            end
        end

        function removeStyler(this)
            st=diagram.style.getStyler(this.stylerName);
            if~isempty(st)
                st.removeRules(false);
                st.destroy();
            end
            this.styler=[];
        end


        function deleteBadges(this)
            try
                if isempty(this.badges)
                    return;
                end
                panelTypes={'Chart','Graph'};
                for idx=1:numel(panelTypes)
                    cp=panelTypes{idx};
                    if isfield(this.badges,cp)
                        bdg=this.badges.(cp);
                        if~isempty(bdg)&&ishandle(bdg)
                            bdg.remove;
                        end
                    end
                end
                this.badges=[];
            catch MEx
                rethrow(MEx);
            end
        end

        function close(this)
            this.removeStyler();
            deleteBadges(this);
        end

        function[diagramObjOut,diagramObjIn]=diagramResolve(~,udiObj)

            diagramObjIn=[];
            diagramObjOut=diagram.resolver.resolve(udiObj);
            if(strcmpi(diagramObjOut.resolutionDomain,'simulink'))
                if isa(udiObj,'Simulink.SubSystem')
                    diagramObjIn=diagram.resolver.resolve(udiObj.Handle,'diagram');
                end
                diagramObjOut=diagram.resolver.resolve(udiObj.Handle);
            end

        end

        function addBadge(this,diagramObj,strHtml)
            if isempty(diagramObj)||diagramObj.isNull
                return;
            end
            bdg=getObjBadge(this,diagramObj);
            if isempty(bdg)
                return;
            end
            bdg.setTooltipForInstance(diagramObj,strHtml);
            bdg.setVisible(diagramObj,true);
        end

        function addStyle(this,diagramObj,cvId,strHtml)
            if isempty(diagramObj)||...
                diagramObj.isNull||...
                strcmpi(diagramObj.type,'Graph')
                return;
            end
            isFullStyle=false;
            if any(this.coloring.full==cvId)

                isFullStyle=addFullCoverageStyle(this,diagramObj,strHtml);
            end

            if~isFullStyle
                s.style=diagram.style.Style;
                s.style.set('Tooltip',strHtml);
                s.style.set('TooltipTimeIn',100);

                if ismember(cvId,this.coloring.missing)
                    glowConfig=MG2.GlowEffect;
                    glowConfig.Color=this.colorTable.sfRedGlow;
                    glowConfig.Spread=7;
                    glowConfig.Gain=2;
                    s.style.set('Glow',glowConfig);
                    s.style.set('StrokeWidth',this.colorTable.sfStrokeWidth);
                else

                    glowConfig=MG2.GlowEffect;
                    glowConfig.Color=[0,0,0];
                    glowConfig.Spread=0;
                    glowConfig.Gain=0;
                    s.style.set('Glow',glowConfig);
                end

                s.selectorName=['cv_',int2str(cvId)];
                s.selector=diagram.style.ClassSelector(s.selectorName);
                s.rule=this.styler.addRule(s.style,s.selector);
                s.diagramObjs=diagramObj;
                this.styler.applyClass(diagramObj,s.selectorName);
                if isempty(this.styles)
                    this.styles=s;
                else
                    this.styles(end+1)=s;
                end
            end
        end

        function res=addFullCoverageStyle(this,diagramObj,strHtml)
            res=false;
            if isempty(diagramObj)||diagramObj.isNull
                return;
            end
            fullMessages=cvi.BadgeHandler.getFullTextMessages;
            idx=find(strcmp(fullMessages,strHtml));

            if isempty(idx)
                return;
            end
            res=true;
            if~this.fullCovStyle.isKey(idx)
                s.style=diagram.style.Style;
                s.style.set('Tooltip',strHtml);
                s.style.set('TooltipTimeIn',100);
                s.style.set('StrokeWidth',this.colorTable.sfStrokeWidth);
                s.selectorName=['cv_full_',num2str(idx)];
                s.selector=diagram.style.ClassSelector(s.selectorName);
                s.rule=this.styler.addRule(s.style,s.selector);
                s.diagramObjs=diagramObj;
                this.fullCovStyle(idx)=s;
            else
                s=this.fullCovStyle(idx);
                s.diagramObjs=[s.diagramObjs,diagramObj];
                this.fullCovStyle(idx)=s;
            end
            this.styler.applyClass(diagramObj,s.selectorName);
        end

        function bdg=getObjBadge(this,obj)
            try
                bdg=[];
                if isempty(this.badges)||~isfield(this.badges,obj.type)
                    switch(obj.type)
                    case 'Chart'
                        bdgp='sfDiagramBadgesPanel';
                    case 'Graph'
                        bdgp='Graph';
                    otherwise
                        return;
                    end
                    id=['Coverage_',this.modelName,'_',bdgp];
                    try
                        bdg=diagram.badges.create(id,bdgp);
                    catch Mex
                        if strcmp(Mex.identifier,'diagram_badges:badges:DuplicateKey')
                            bdg=diagram.badges.get(id,bdgp);
                        else
                            throw(Mex);
                        end
                    end

                    bdg.Image=fullfile(matlabroot,'toolbox','slcoverage','+cvi','@BadgeHandler','icons','coverageAnalysisApp_16.png');
                    bdg.setActionHandler(@this.onClickBadge);
                    bdg.DefaultOpacity=0.7;
                    this.badges.(obj.type)=bdg;
                else
                    bdg=this.badges.(obj.type);
                end
            catch MEx
                rethrow(MEx);
            end
        end


        function onClickBadge(this,diagramObject,posX,posY)
            needReport=~cvi.Informer.isDockedReportVisibleForActiveStudio();
            if needReport
                h=cvi.PopupInformer(this,diagramObject,posX,posY,false,needReport);
                h.show();
            end
        end


        function popupInformerLinkCallback(this,diagramObject,action)%#ok<INUSL>
            try
                if isequal(action,'report')
                    cvi.Informer.openCoverageDetails();
                end
            catch MEx
                rethrow(MEx);
            end
        end


        function cvId=getCvId(this,handle)
            cvId=0;
            if this.handleToCvIdMap.isKey(handle)
                cvId=this.handleToCvIdMap(handle);
                if numel(cvId)==2

                    cvId=cvId(2);
                end
            end
        end
    end
end


