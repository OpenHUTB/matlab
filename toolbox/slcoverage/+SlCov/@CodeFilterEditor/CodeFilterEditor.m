





classdef(Hidden)CodeFilterEditor<SlCov.FilterEditor

    properties(GetAccess=public,SetAccess=protected)
        ctxInfo(1,1)struct
        nameTag(1,:)char
        descriptionTag(1,:)char
        isUnknownFile(1,1)logical=true
    end

    methods(Access=protected,Hidden)



        function this=CodeFilterEditor(moduleName,fileName)

            this@SlCov.FilterEditor('',fileName);


            this.modelName=moduleName;
            this.dialogTag=SlCov.CodeFilterEditor.getDialogTag(moduleName);
            this.dialogTitle=SlCov.CodeFilterEditor.getDialogTitle(moduleName);
            this.saveToModel=false;
            this.widgetTag='Tree_';
            this.isUnknownFile=isempty(fileName);
        end
    end

    methods(Hidden)



        function load(this,fileName)


            modelName=this.modelName;
            try
                this.modelName='';
                load@SlCov.FilterEditor(this,fileName);
            catch Me
                this.modelName=modelName;
                rethrow(Me);
            end
            this.modelName=modelName;
            this.isUnknownFile=isempty(fileName);
            if~isempty(this.ctxInfo)
                this.ctxInfo.filterUUID=this.uuid;
                this.ctxInfo.filterFileName=this.fileName;
            end
        end




        function filterNameChangedCallback(this,varargin)
            this.needSave=true;
        end




        function filterDescriptionChangedCallback(this,varargin)
            this.needSave=true;
        end

        dlg=getDialogSchema(this,~);
        groupFilterState=getFilterStateGroup(this,tag,widgetId,varargin);
        saveFilterCallback(this,dlg,varargin);
        loadFilterCallback(this,dlg);
        [status,errstr]=postApplyCallback(this,dlg);
        [status,errstr]=postRevertCallback(this,dlg)
        [status,errStr]=closeCallback(this,dlg);
        updateResults(this);
    end

    methods(Static=true)



        function fName=defaultFileName(moduleName)
            fName='covfilter';
            if~isempty(moduleName)
                fName=[moduleName,'_',fName];
            end
        end




        function tag=getDialogTag(moduleName)
            tag=['Code_Coverage_Filter_',moduleName];
        end




        function title=getDialogTitle(moduleName)
            title=[getString(message('Slvnv:simcoverage:covFilterUITitle')),' ',moduleName];
        end




        function this=createFilterEditor(moduleName,fileName)
            this=SlCov.CodeFilterEditor(moduleName,fileName);
            this.reset();
            this.load(fileName);
        end




        function this=createFilter(fileName)
            this=SlCov.CodeFilterEditor('','');
            this.reset();
            this.load(fileName);
        end




        function filter=getInstance(moduleName,filterFileName,filterUUID)
            if nargin<3
                filterUUID='';
            end
            if nargin<2
                filterFileName='';
            end
            dialogTag=SlCov.CodeFilterEditor.getDialogTag(moduleName);
            filter=SlCov.CodeFilterEditor.findExistingDlg(moduleName,filterFileName,dialogTag,filterUUID);
            if isempty(filter)
                isEmptyFileName=isempty(filterFileName);
                if isEmptyFileName
                    filterFileName=SlCov.CodeFilterEditor.defaultFileName(moduleName);
                end
                filter=SlCov.CodeFilterEditor.createFilterEditor(moduleName,filterFileName);
                filter.isUnknownFile=isEmptyFileName;
            else
                filter=filter(1);
            end
        end




        function filterDlg=findExistingDlg(moduleName,filterFileName,dialogTag,filterUUID)
            if nargin<4
                filterUUID='';
            end



            tr=DAStudio.ToolRoot;
            dlgs=tr.getOpenDialogs();
            filterDlg=[];
            for idx=1:numel(dlgs)
                if strcmp(dlgs(idx).dialogTag,dialogTag)
                    dlg=dlgs(idx);
                    cfilter=dlg.getSource();
                    try
                        if strcmpi(cfilter.modelName,moduleName)
                            if~isempty(cfilter.ctxInfo)&&~isempty(filterUUID)&&...
                                strcmp(cfilter.ctxInfo.filterUUID,filterUUID)
                                filterDlg=cfilter;
                                break
                            end
                            if~isempty(filterFileName)&&~strcmpi(cfilter.fileName,filterFileName)
                                continue
                            end
                            filterDlg=cfilter;
                            break
                        end
                    catch MEx %#ok<NASGU>
                    end
                end
            end
        end





        function openFilterCallback(filterCtxUUID,filterUUID,cvdataId,viewCmd,moduleName,filterFileName)
            ctxInfo.filterCtxId=filterCtxUUID;
            ctxInfo.filterUUID=filterUUID;
            ctxInfo.filterReportViewCmd=viewCmd;
            ctxInfo.cvdId=cvdataId;
            ctxInfo.topModelName=moduleName;
            ctxInfo.filterFileName=filterFileName;

            f=SlCov.CodeFilterEditor.getInstance(moduleName,filterFileName,filterUUID);
            f.ctxInfo=ctxInfo;
            f.show();
        end





        function reportRuleCallback(filterCtxUUID,filterUUID,cvdataId,viewCmd,moduleName,filterFileName,action,codeCovInfo)
            ctxInfo.filterCtxId=filterCtxUUID;
            ctxInfo.filterUUID=filterUUID;
            ctxInfo.filterReportViewCmd=viewCmd;
            ctxInfo.cvdId=cvdataId;
            ctxInfo.topModelName=moduleName;
            ctxInfo.filterFileName=filterFileName;


            cvd=cv.coder.cvdatamgr.instance().get(ctxInfo.topModelName,ctxInfo.cvdId);
            if isempty(cvd)||~cvd.valid()
                return
            end


            if~isempty(filterFileName)
                filterFileNames=cellfun(@strtrim,strsplit(filterFileName,','),'UniformOutput',false);
                if numel(filterFileNames)
                    filterFileName='';
                    for ii=1:numel(cvd.filterAppliedStruct)
                        if strcmp(cvd.filterAppliedStruct(ii).uuid,filterUUID)
                            filterFileName=cvd.filterAppliedStruct(ii).fileName;
                        end
                    end
                    if isempty(filterFileName)
                        idx=find(ismember(filterFileNames,{cvd.filterAppliedStruct.fileName}),1);
                        if isempty(idx)
                            filterFileName=filterFileNames{1};
                        else
                            filterFileName=filterFileNames{idx};
                        end
                    end
                else
                    filterFileName=filterFileNames{1};
                end
            end

            f=SlCov.CodeFilterEditor.getInstance(moduleName,filterFileName,filterUUID);
            f.ctxInfo=ctxInfo;

            if strcmpi(action,'showRule')
                f.showMetricRule(codeCovInfo,0,0,'',true);
            elseif strcmpi(action,'add')
                f.addRemoveInstance(codeCovInfo,'',0,0,'',action);
            end
            f.show();
        end
    end
end


