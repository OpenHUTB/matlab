classdef FilterEditor<handle




    properties(SetObservable=true)
        uuid=''
        filterName=''
        filterDescr=''
        fileName=''
        modelName=''
        saveToModel=false
        attachToData=false
        m_dlg=[]
        filterState=[]
        tableIdxMap=[]
        ctableIdxMap=[]
        filterCache=[]
        dialogTag=''
        dialogTitle=''
        widgetTag=''
        savedStructFieldName=''
        forceSelectedRow=0
        eventListener=[]
        lastKeyAdded=[]
        clastKeyAdded=[]

        hasUnappliedChanges=false
        lastFilterElement=[]
        needSave=false
        numOfMetricProps=0
        numOfRteProps=0
        supportExecutionOnlyBlocks=false
        overwriteRules=true
        isReadOnly=false;
    end



    methods(Static=true)
        newFile=browseCallback(val,ext,text)
        fileName=mergeFilters(filterName1,filterName2)
        [foundFileName,fullFileName]=findFile(fileName,modelName)

        function filter=findExistingDlg(modelH,~,dialogTag)

            tr=DAStudio.ToolRoot;
            dlgs=tr.getOpenDialogs;
            filter=[];
            for idx=1:numel(dlgs)
                if strcmp(dlgs(idx).dialogTag,dialogTag)
                    dlg=dlgs(idx);
                    filter=dlg.getSource;
                    try
                        if~strcmpi(filter.modelName,get_param(modelH,'name'))

                            filter=[];
                        end
                    catch MEx %#ok<NASGU>
                        filter=[];
                    end

                    break;
                end
            end
        end

        function modelobject=getObject(ssid)
            modelobject=cvi.TopModelCov.getObject(ssid);
        end

        function ssid=getSSID(object)
            try
                ssid=[];
                if contains(class(object),'Simulink.')
                    object=object.Handle;
                end
                ssid=Simulink.ID.getSID(object);
            catch %#ok<CTCH> %some object does not have, e.g., Stateflow.LinkChart
            end
        end



        function key=encodeCodeFilterInfo(fNameOrCodeFiltInfo,funName,expr,exprIdx,cvMetricType,ssid)
            narginchk(1,6);



            if nargin==1&&isstruct(fNameOrCodeFiltInfo)&&...
                isfield(fNameOrCodeFiltInfo,'codeCovInfo')&&...
                isfield(fNameOrCodeFiltInfo,'ssid')
                codeFiltInfo=fNameOrCodeFiltInfo;
                args=codeFiltInfo.codeCovInfo;
                args(numel(args)+1:6)={''};
                if~isempty(codeFiltInfo.ssid)
                    args{end}=codeFiltInfo.ssid;
                end
                key=SlCov.FilterEditor.encodeCodeFilterInfo(args{:});
                return
            else
                fName=fNameOrCodeFiltInfo;
            end

            if nargin<6
                ssid='';
            end
            if nargin<5
                cvMetricType='';
            elseif~ischar(cvMetricType)
                cvMetricType=sprintf('%d',cvMetricType);
            end
            if nargin<4
                exprIdx='';
            elseif~ischar(exprIdx)

                exprIdx=strjoin(arrayfun(@(x)sprintf('%d',x),exprIdx,'UniformOutput',false),':');
            end
            if nargin<3
                expr='';
            end
            if nargin<2
                funName='';
            end
            key=sprintf('{%s}/{%s}/{%s}/{%s}/{%s}/{%s}',fName,funName,expr,exprIdx,cvMetricType,ssid);

        end


        function[codeInfo,ssid]=decodeCodeFilterInfo(key)

            codeInfo=cell(1,5);
            ssid='';


            tok=regexp(key,'{(.*?)}/{(.*?)}/{(.*?)}/{([\d:]+)?}/{(\d*)}(/{.*?})?','tokens');
            try
                if~isempty(tok)&&~isempty(tok{1})&&numel(tok{1})>=5
                    if isempty(tok{1}{1})
                        return
                    end
                    for ii=1:5
                        val=tok{1}{ii};
                        if isempty(val)
                            continue
                        end
                        if ii==4

                            strs=strsplit(val,':');
                            val=cellfun(@(x)sscanf(x,'%d'),strs);
                        elseif ii>3
                            val=sscanf(val,'%d');
                        end
                        codeInfo{end+1}=val;%#ok<AGROW>
                    end
                    if numel(tok{1})==6
                        tok=regexp(tok{1}{6},'/{(.*)}','tokens');
                        if~isempty(tok)&&~isempty(tok{1})&&~isempty(tok{1}{1})
                            ssid=strtrim(tok{1}{1});
                        end
                    end
                end
            catch
            end
            codeInfo(cellfun(@isempty,codeInfo))=[];
        end


        function[forCode,codeFiltInfo,codeKey]=isForCode(ssid)
            forCode=false;
            codeFiltInfo=[];
            codeKey='';
            if iscell(ssid)||isstruct(ssid)
                if isstruct(ssid)
                    codeFiltInfo=ssid;
                else
                    codeFiltInfo.codeCovInfo=ssid;
                    codeFiltInfo.ssid=[];
                end
                forCode=true;
                codeKey=SlCov.FilterEditor.encodeCodeFilterInfo(codeFiltInfo);
            end
        end


        function out=isCodeFilterFileInfo(ssid)

            out=numel(ssid)==1&&iscellstr(ssid(1))&&~isempty(ssid{1});%#ok<ISCLSTR> 
        end


        function out=isCodeFilterFunInfo(ssid)

            out=numel(ssid)==2&&iscellstr(ssid)&&...
            ~isempty(ssid{2})&&SlCov.FilterEditor.isCodeFilterFileInfo(ssid(1));%#ok<ISCLSTR> 
        end


        function out=isCodeFilterDecInfo(ssid)


            out=numel(ssid)==5&&iscellstr(ssid(1:3))&&...
            ~isempty(ssid{3})&&SlCov.FilterEditor.isCodeFilterFunInfo(ssid(1:2))&&...
            ~isempty(ssid{4})&&(numel(ssid{4})==1||numel(ssid{4})==2)&&...
            ~isempty(ssid{5})&&isequal(ssid{5},1);%#ok<ISCLSTR> 
        end


        function out=isCodeFilterCondInfo(ssid)


            out=numel(ssid)==5&&iscellstr(ssid(1:3))&&...
            ~isempty(ssid{3})&&SlCov.FilterEditor.isCodeFilterFunInfo(ssid(1:2))&&...
            ~isempty(ssid{4})&&(numel(ssid{4})==1||numel(ssid{4})==2||numel(ssid{4})==3)&&...
            ~isempty(ssid{5})&&isequal(ssid{5},0);%#ok<ISCLSTR> 
        end


        function out=isCodeFilterMCDCInfo(ssid)


            out=numel(ssid)==5&&iscellstr(ssid(1:3))&&...
            ~isempty(ssid{3})&&SlCov.FilterEditor.isCodeFilterFunInfo(ssid(1:2))&&...
            ~isempty(ssid{4})&&numel(ssid{4})==2&&...
            ~isempty(ssid{5})&&isequal(ssid{5},2);%#ok<ISCLSTR> 
        end


        function out=isCodeFilterRelBoundInfo(ssid)


            out=numel(ssid)==5&&iscellstr(ssid(1:3))&&...
            ~isempty(ssid{3})&&SlCov.FilterEditor.isCodeFilterFunInfo(ssid(1:2))&&...
            ~isempty(ssid{4})&&(numel(ssid{4})==2||numel(ssid{4})==3)&&...
            ~isempty(ssid{5})&&isequal(ssid{5},3);%#ok<ISCLSTR> 
        end


        function activateTab(filterDlg,widgetTag,forCode)
            rulesTabId=[widgetTag,'rulesTab'];
            tabNum=filterDlg.getActiveTab(rulesTabId);
            if tabNum>=0
                widgetName='filterState';
                if forCode&&tabNum~=1
                    filterDlg.setActiveTab(rulesTabId,1);
                    widgetName=['c',widgetName];
                elseif~forCode&&tabNum~=0
                    filterDlg.setActiveTab(rulesTabId,0);
                end
                widgetTag=[widgetTag,widgetName];
                filterDlg.setFocus(widgetTag);
            end
        end

        function descr=getMetricFilterValueDescr(metricName,cvId,outcomeIdx,isLinked)

            if nargin<4
                isLinked=false;
            end
            descr=cvi.ReportUtils.getTextOf(cvId,-1,[],2);
            if strcmpi(metricName,'condition')
                if outcomeIdx==2
                    outcomeStr='F';
                else
                    outcomeStr='T';
                end
            elseif strcmpi(metricName,'mcdc')
                conditionIds=cv('get',cvId,'.conditions');
                outcomeStr=cvi.ReportUtils.getTextOf(conditionIds(outcomeIdx),-1,[],2);
            else
                outcomeStr=cvi.ReportUtils.getTextOf(cvId,outcomeIdx-1,[],2);
                if strcmpi(outcomeStr,'true')
                    outcomeStr='T';
                elseif strcmpi(outcomeStr,'false')
                    outcomeStr='F';
                else
                    outcomeStr(outcomeStr=='"')=[];
                end
            end

            descr=getString(message('Slvnv:simcoverage:filterEditor:OutcomeOfTxt',outcomeStr,descr));
            slsfObjId=cv('get',cvId,'.slsf');
            descr=getString(message('Slvnv:simcoverage:filterEditor:InTxt',descr,cvi.ReportScript.object_titleStr_and_link(slsfObjId,[],false,isLinked)));
        end


        function filterObj=getFilterObjFromDlg(dlg)

            obj=dlg.getSource;
            if isa(obj,'SlCovResultsExplorer.Folder')
                filterObj=obj.m_impl.resultsExplorer.getFilter;
            elseif isa(obj,'SlCovResultsExplorer.Data')
                filterObj=obj.m_impl.getFilter;
            else
                filterObj=obj;
            end
        end

        function updateFilterNameWidget(dlg,forCode)
            if nargin<2
                forCode=false;
            end


            widgetName='filterState';
            if forCode
                widgetName=['c',widgetName];
            end
            try
                idx=dlg.getSelectedTableRows(['Tree_',widgetName]);
            catch

                return;
            end



            if isempty(idx)&&~forCode
                return;
            end


            name='';
            if forCode
                filterObj=SlCov.FilterEditor.getFilterObjFromDlg(dlg);
                if isempty(filterObj)
                    return;
                end
                if~isempty(idx)
                    name=genCodeFilterDescription(filterObj,idx);
                end
            else
                if~isempty(idx)
                    name=dlg.getTableItemValue(['Tree_',widgetName],idx,0);

                    type=dlg.getTableItemValue(['Tree_',widgetName],idx,1);
                    if strcmpi(type,DAStudio.message('Slvnv:simcoverage:getPropertyDB:P5s'))||...
                        strcmpi(type,DAStudio.message('Slvnv:simcoverage:getPropertyDB:P8s'))||...
                        strcmpi(type,DAStudio.message('Slvnv:simcoverage:getPropertyDB:P10s'))
                        dlg.setEnabled(('Tree_highlight'),false);
                    else
                        dlg.setEnabled(('Tree_highlight'),true);
                    end
                end
            end


            widgetName='filterStateName';
            if forCode
                widgetName=['c',widgetName];
            end
            dlg.setWidgetValue(['Tree_',widgetName],name);
        end

        function tag=getDialogTag(modelName)
            tag=['Coverage_Filter_',modelName];
        end

        function fileName=defaultFileName(modelName)

            covOutputDir=cvi.CvhtmlSettings.getOutputDir(modelName);
            fileName=[get_param(modelName,'name'),'_covfilter'];
            fileName=fullfile(covOutputDir,fileName);
        end

        function filter=create(modelH)
            filter=SlCov.FilterEditor.getInstance(modelH);
            filter.show;
        end

        function filter=findInstance(modelH,fileName)
            modelName=get_param(modelH,'Name');
            if nargin<2
                fileName=get_param(modelH,'CovFilter');
            end
            filter=SlCov.FilterEditor.findExistingDlg(modelName,fileName,SlCov.FilterEditor.getDialogTag(modelName));
            if isempty(filter)
                if~isempty(fileName)
                    filter=SlCov.FilterEditor.createFilterEditor(modelName,fileName);
                else
                    fileName=SlCov.FilterEditor.defaultFileName(modelName);
                    foundFileName=SlCov.FilterEditor.findFile(fileName);
                    if~isempty(foundFileName)
                        filter=SlCov.FilterEditor.createFilterEditor(modelName,fileName);
                    end
                end
            end
        end


        function filter=getInstance(modelH,fileName)
            modelName=get_param(modelH,'Name');
            if nargin<2
                fileName=get_param(modelName,'CovFilter');
            end
            filter=SlCov.FilterEditor.findExistingDlg(modelName,fileName,SlCov.FilterEditor.getDialogTag(modelName));
            if isempty(filter)
                if isempty(fileName)
                    fileName=SlCov.FilterEditor.defaultFileName(modelName);
                end
                filter=SlCov.FilterEditor.createFilterEditor(modelName,fileName);
            end
        end

        function filter=loadFilter(modelH,fileName)
            modelName=get_param(modelH,'Name');
            filter=SlCov.FilterEditor.findExistingDlg(modelName,fileName,SlCov.FilterEditor.getDialogTag(modelName));
            if isempty(filter)
                filter=SlCov.FilterEditor.createFilterEditor(modelName,fileName);
            end
        end


        function[res,rootModelName]=isCoverageEnabled(studio)








            rootModelH=studio.App.blockDiagramHandle;


            coveng=cvi.TopModelCov.getInstance(rootModelH);
            if~isempty(coveng)
                rootModelH=coveng.topModelH;
            end

            rootModelName=get_param(rootModelH,'Name');
            activeModelH=studio.App.getActiveEditor.blockDiagramHandle;
            activeModelName=get_param(activeModelH,'Name');

            if(rootModelH==activeModelH)||...
                (~locIsLibrary(rootModelH)&&locIsLibrary(activeModelH))

                res=strcmpi(get_param(rootModelH,'RecordCoverage'),'on');
            else

                modelRefEnable=get_param(rootModelH,'CovModelRefEnable');
                modelRefExcludeList=cv.ModelRefData.getExcludedModels(get_param(rootModelH,'CovModelRefExcluded'));
                res=cv.ModelRefData.assessModelRefEnabled(activeModelName,...
                modelRefEnable,...
                modelRefExcludeList);
            end

        end

        function newFilterFileName=convertCovFilter(origFilterFileName,origModelH,newSubsysH,suffix,dirPath)

            filter=SlCov.FilterEditor.createFilterEditor(origModelH,origFilterFileName);
            if~exist('dirPath','var')
                dirPath=fileparts(get_param(bdroot(newSubsysH),'FileName'));
            end
            [~,origFilterFileNameBase,~]=fileparts(origFilterFileName);
            newFilterFileName=[origFilterFileNameBase,suffix];
            newFilter=filter.deriveHarnessFilter(newSubsysH);
            newFilter.save(fullfile(dirPath,newFilterFileName));
        end

        function this=createFilterEditor(modelName,fileName)
            this=SlCov.FilterEditor(modelName,fileName);
            this.reset;
            setEventHandler(this);
            this.load(fileName);
        end


        function this=createFilter(fileName)
            this=SlCov.FilterEditor('','');
            this.reset;
            this.load(fileName);
        end

        propMap=deriveProperties(ssid,supportExecutionOnlyBlocks)
        propMap=deriveMetricProperties(ssid)
        propMap=getPropertyDB()
        desc=getCodeFilterDescription(prop)

        function text=getPropertyDescription(prop)
            try
                text=DAStudio.message(prop.propDesc);
            catch %#ok<CTCH> %wrong number of argument, TBD - getPropertyDB should store it
                text=DAStudio.message(prop.propDesc,prop.valueDesc);
            end
        end

        function metricNames=getSupportedMetricNames
            metricNames={'decision','condition','mcdc','cvmetric_Structural_relationalop','cvmetric_Structural_saturate'};
        end

    end


    methods
        function saveAs(this,fileName)

            this.setUUID();
            this.save(fileName);
        end

        function fileName=getDefaultFileName(this)
            fileName=SlCov.FilterEditor.defaultFileName(this.modelName);
        end

        propMap=getProperties(this,ssid)
        children=getDescendants(this,ssid)
        allAncs=getAncestors(this,ssid)


        function pname=getModelParamName(~)
            pname='CovFilter';
        end

        function helpFcn(~)
            helpview([docroot,'/toolbox/slcoverage/helptargets.map'],'modelcoveragefilter_dialog');
        end

        function out=getAllCodeInfo(this)
            values=this.filterState.values();
            isCode=false(1,numel(values));
            for ii=1:numel(values)
                isCode(ii)=values{ii}.isCode==1;
            end
            out=values(isCode);
        end

        function[hasModel,hasCode]=hasModelOrCodeRules(this)
            hasModel=false;
            hasCode=false;
            values=this.filterState.values();
            for ii=1:numel(values)
                cHasCode=(values{ii}.isCode==1);
                if~hasCode&&cHasCode
                    hasCode=true;
                end
                if~hasModel&&~cHasCode
                    hasModel=true;
                end
                if hasModel&&hasCode
                    return;
                end
            end
        end


        function res=isPropIncludeChildren(~,prop)
            res=prop.includeChildren;
        end

        function text=getPropertyValueDescription(~,prop)
            if isequal(prop.valueDesc,'metric')
                text=prop.value(end).valueDesc;
            else
                text=prop.valueDesc;
            end
        end

        function mode=getFilterMode(this,ssid)
            mode=getFilterStateValue(this,ssid,'mode');
        end

        filterReportCallback(this);
        filterRemoveCallback(this,dlg,widgetTag,forCode);
        filterFileBrowseCallback(this,dlg);
        filterFileChangeCallback(this,dlg,filterFileNameTag);
        highliteCallback(this,dlg,widgetTag);
        [status,str]=postApply(this);
        [cvd,cvdc]=applyFilter(this);

        function currProp=getInstanceProperty(this,ssid)

            currProp=[];
            prop=this.getProperties(ssid);
            if~isempty(prop)


                idx=2;
                if numel(prop)<2
                    idx=1;
                end
                currProp=prop(idx);



                if currProp.selectorType==slcoverage.BlockSelectorType.BlockType&&...
                    prop(1).selectorType==slcoverage.BlockSelectorType.Chart
                    currProp=prop(1);
                elseif currProp.selectorType==slcoverage.BlockSelectorType.Subsystem
                    currProp=prop(1);
                end
            end
        end

        function addRemoveByProp(this,action,prop)
            if strcmpi(action,'add')
                this.setFilterByProp(prop,[]);
            else
                this.removeFilterByProp(prop);
            end
            this.hasUnappliedChanges=true;
        end

        function rat=checkExistingRationale(this,prop)
            key=this.getPropKey(prop);
            map=this.filterState;
            rat='';
            if map.isKey(key)
                value=map(key);
                if this.isMetricProperty(prop)||this.isRteProperty(prop)
                    rat=value.rationale;
                else
                    rat=value.Rationale;
                end
            end
        end

        function addRemoveInstance(this,ssid,descr,idx,outcomeIdx,metricName,action)
            if~isempty(ssid)
                if idx~=0
                    if strcmpi(action,'add')
                        descr=cvi.ReportUtils.html_to_str(descr);
                        this.addMetricFilter(ssid,metricName,idx,outcomeIdx,1,[],descr);
                        this.hasUnappliedChanges=true;
                    elseif strcmpi(action,'remove')
                        v.ssid=ssid;
                        v.type='metric';
                        v.name=metricName;
                        v.idx=idx;
                        v.outcomeIdx=outcomeIdx;
                        prop.value=v;
                        this.removeFilterByProp(prop);
                        this.hasUnappliedChanges=true;
                    end
                else
                    currProp=getInstanceProperty(this,ssid);
                    if~isempty(currProp)
                        if strcmpi(action,'add')
                            rat=this.checkExistingRationale(currProp);
                            this.setFilterByProp(currProp,rat);
                        elseif strcmpi(action,'remove')
                            this.removeFilterByProp(currProp);
                        end
                        this.hasUnappliedChanges=true;
                    end
                end
            end
        end

        function res=isEmpty(this)
            res=this.filterState.isempty();
        end

        function flag=hasNonRteProps(this)
            flag=false;
            values=this.filterState.values;
            for i=1:numel(values)
                if~this.isRteProperty(values{i})
                    flag=true;
                    return;
                end
            end
        end

        function reset(this)
            this.tableIdxMap=containers.Map('KeyType','double','ValueType','any');
            this.ctableIdxMap=containers.Map('KeyType','double','ValueType','any');
            this.filterCache=containers.Map('KeyType','char','ValueType','any');
            this.filterState=containers.Map('KeyType','char','ValueType','any');
            this.lastFilterElement=[];
            this.needSave=false;
        end


        function initFilterFromFile(this,filterFileName)
            if isempty(this.lastFilterElement)&&...
                ~isempty(filterFileName)&&...
                ~strcmpi(this.fileName,filterFileName)

                this.fileName=filterFileName;
                this.load(filterFileName);

                this.saveToModel=false;
                if~isempty(this.m_dlg)
                    this.m_dlg.enableApplyButton(true);
                    this.m_dlg.refresh;
                end
            end
        end

        function show(this,forCode)
            if nargin<2
                forCode=false;
            end

            if isempty(this.m_dlg)
                dlg=DAStudio.Dialog(this);
                this.m_dlg=dlg;
            else
                this.m_dlg.show;
            end


            SlCov.FilterEditor.activateTab(this.m_dlg,this.widgetTag,forCode);

            if this.hasUnappliedChanges
                this.m_dlg.enableApplyButton(true)
            end
        end

        function revert(this,~)
            try
                if~isempty(this.lastFilterElement)
                    fe=this.lastFilterElement;
                    if isfield(fe,'add')
                        if numel(fe.add)>1
                            this.removeFilterByProp(fe.add{1});
                            this.setFilterByProp(fe.add{2},'');
                        else
                            this.removeFilterByProp(fe.add);
                        end
                    end
                    if isfield(fe,'remove')
                        this.setFilterByProp(fe.remove,'');
                    end
                    if isfield(fe,'rationale')
                        this.addRationaleCallback([],fe.rationale{1},fe.rationale{2},fe.rationale{3},fe.rationale{4});
                    end
                    if isfield(fe,'mode')
                        this.changeFilterModeCallback([],fe.mode{1},fe.mode{2},fe.mode{3});
                    end
                    this.lastFilterElement={};
                    this.hasUnappliedChanges=false;
                end
            catch MEx
                rethrow(MEx);
            end
        end

        function ssid=getRuleSIDByTablePosition(this,tableRowIdx)
            ssid=[];
            if~this.tableIdxMap.isempty&&this.tableIdxMap.isKey(tableRowIdx)
                prop=this.tableIdxMap(tableRowIdx);
                ssid=this.getPropSSID(prop);
            end
        end

    end
    methods(Access=protected)

        function id=getPropId(~,prop)
            id=prop.id;
        end

        function key=getPropKey(this,prop)
            key=[];
            if~this.isSubProperty(prop)
                key=prop.value;
            elseif~isempty(prop.value)
                fn={'ssid','type','name'};

                for idx=1:numel(fn)
                    if isfield(prop.value,fn{idx})
                        val=prop.value.(fn{idx});
                        if~isa(val,char)
                            key=[key,num2str(val)];%#ok<AGROW>
                        else
                            key=[key,val];%#ok<AGROW>
                        end
                    end
                end
            end
        end

        function res=isSubProperty(~,prop)
            res=isa(prop.value,'struct');
        end

        function res=isMetricProperty(this,prop)
            res=false;
            if this.isSubProperty(prop)
                value=prop.value;
                if~isempty(value)
                    res=isfield(value,'type')&&isequal(value.type,'metric');
                end
            end
        end

        function res=isRteProperty(this,prop)
            res=false;
            if this.isSubProperty(prop)
                value=prop.value;
                if~isempty(value)
                    res=isfield(value,'type')&&isequal(value.type,'rte');
                end
            end
        end

        function res=isCodeMetricProperty(~,prop)
            res=false;
            if prop.isCode&&~isempty(prop.selectorType)
                codeMetricType=[...
                int32(slcoverage.CodeSelectorType.DecisionOutcome),...
                int32(slcoverage.CodeSelectorType.ConditionOutcome),...
                int32(slcoverage.CodeSelectorType.MCDCOutcome),...
                int32(slcoverage.CodeSelectorType.RelationalBoundaryOutcome),...
                int32(slcoverage.SFcnSelectorType.SFcnInstanceCppDecisionOutcome),...
                int32(slcoverage.SFcnSelectorType.SFcnInstanceCppConditionOutcome),...
                int32(slcoverage.SFcnSelectorType.SFcnInstanceCppMCDCOutcome),...
                int32(slcoverage.SFcnSelectorType.SFcnInstanceCppRelationalBoundaryOutcome)...
                ];
                res=~isempty(find(codeMetricType==int32(prop.selectorType),1));
            end
        end

        function[res,objSID]=hasSSID(this,prop)
            res=false;

            objSID=[];
            if prop.isCode
                [~,objSID]=SlCov.FilterEditor.decodeCodeFilterInfo(prop.value);
                if isempty(objSID)
                    return
                end

            elseif~this.isSubProperty(prop)
                objSID=prop.value;
            elseif isfield(prop.value(1),'ssid')
                objSID=prop.value(1).ssid;
            end
            try
                res=Simulink.ID.isValid(objSID);
            catch %#ok<CTCH>
            end
            if~res
                objSID=[];
            end
        end

        function ssid=getPropSSID(this,prop)
            [~,ssid]=hasSSID(this,prop);
        end

        function text=getPropertyType(~,prop)
            text=DAStudio.message(prop.propType);
        end

        function resetCache(this)


            if~this.filterCache.isempty()
                this.filterCache.remove(this.filterCache.keys);
            end
        end

        function key=getInternalKey(~,ssid)
            [forCode,~,codeKey]=SlCov.FilterEditor.isForCode(ssid);
            if forCode
                key=codeKey;
            else
                key=ssid;
            end
        end

        function[isChached,res,prop]=isCached(this,ssid)
            key=this.getInternalKey(ssid);
            isChached=this.filterCache.isKey(key);
            res=false;
            prop=[];
            if isChached
                prop=this.filterCache(key);
                res=~isempty(prop);
            end
        end

        function cacheIt(this,ssid,res,prop)
            key=this.getInternalKey(ssid);
            if~res
                prop=[];
            end

            if~this.filterCache.isKey(key)||prop.mode==0
                this.filterCache(key)=prop;
            end
        end

        function removeFromCache(this,ssid)
            key=this.getInternalKey(ssid);
            this.filterCache.remove(key);
        end

        function[res,prop]=isFilteredIntern(this,ssid)
            [isCached,res,prop]=this.isCached(ssid);
            if isCached
                return;
            end

            res=false;
            prop=[];
            props=this.getProperties(ssid);

            for idx=1:numel(props)
                prop=props(idx);
                if~this.isSubProperty(prop)&&this.isFilteredByProp(prop)
                    res=true;

                    prop=this.filterState(this.getPropKey(prop));
                    this.cacheIt(ssid,res,prop);
                    return;
                end
            end
            this.cacheIt(ssid,res,[]);
        end

        desc=genCodeFilterDescription(obj,rowIdx)


    end

    methods(Hidden=true)

        function this=FilterEditor(modelName,fileName,attachedFilename,dialogTag,dialogTitle)
            this.savedStructFieldName='coverageFilterRules';
            this.fileName=fileName;
            if~isempty(modelName)
                this.modelName=getfullname(modelName);
                if nargin<3
                    attachedFilename=get_param(this.modelName,this.getModelParamName);
                end
                if nargin<4
                    dialogTag=SlCov.FilterEditor.getDialogTag(this.modelName);
                end
                if nargin<5
                    dialogTitle=[DAStudio.message('Slvnv:simcoverage:covFilterUITitle'),' ',modelName];
                end
                this.saveToModel=~isempty(fileName)&&strcmpi(fileName,attachedFilename);
                this.dialogTag=dialogTag;
                this.dialogTitle=dialogTitle;
                this.widgetTag=[this.dialogTag,'_'];
            end
            this.setUUID();
        end

        function setUUID(this)
            guidStr=char(matlab.lang.internal.uuid);
            this.uuid=guidStr;
        end

        function uuid=getUUID(this)
            uuid=this.uuid;
        end

        function key=addProp(this,prop)
            key=this.getPropKey(prop);
            this.filterState(key)=prop;
            if isfield(prop,'selectorType')&&isa(prop.selectorType,'slcoverage.MetricSelectorType')
                this.numOfMetricProps=this.numOfMetricProps+1;
            end
            if isfield(prop,'selectorType')&&isa(prop.selectorType,'Sldv.RteSelectorType')
                this.numOfRteProps=this.numOfRteProps+1;
            end
        end

        function removeProp(this,key,prop)
            this.filterState.remove(key);
            if isfield(prop,'selectorType')&&isa(prop.selectorType,'slcoverage.MetricSelectorType')
                this.numOfMetricProps=this.numOfMetricProps-1;
            end
            if isfield(prop,'selectorType')&&isa(prop.selectorType,'Sldv.RteSelectorType')
                this.numOfRteProps=this.numOfRteProps-1;
            end
        end


        function res=hasMetricProp(this)
            res=this.numOfMetricProps>0;
        end

        function res=hasRteProp(this)
            res=this.numOfRteProps>0;
        end

        function varType=getPropDataType(~,varName)
            switch(varName)
            case{'fileName'}
                varType='string';
            otherwise
                varType='bool';
            end
        end

    end
end





function res=locIsLibrary(modelH)
    try
        bdType=get_param(modelH,'BlockDiagramType');
        res=strcmpi(bdType,'library');
    catch
        res=false;
    end
end




