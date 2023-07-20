classdef(Sealed=true)Manager<handle




    properties(SetAccess=private,Hidden=true)




        ApplicationObjMap=containers.Map('KeyType','char','ValueType','any');

        ErrorLog='';
        parallelDatabase='';

    end

    properties(Constant,Hidden=true)
        Version=1.2;
    end

    properties(Hidden=true)









        slCustomizationDataStructure=[];

        Progressbar=[];

        cmdRoot=[matlabroot,filesep,'toolbox',filesep,'simulink',filesep,'simulink',filesep,'modeladvisor'];
    end

    properties(Access=private)
        ActiveApplicationObj=[];
    end





    methods

    end




    methods(Hidden=true)

        function setParallelDatabase(obj,databaseFileLocation)
            obj.parallelDatabase=databaseFileLocation;
        end




        function clearSlCustomizationData(obj,varargin)
            obj.slCustomizationDataStructure=[];

            obj.slCustomizationDataStructure.CheckIDMap=containers.Map('KeyType','char','ValueType','double');
            obj.slCustomizationDataStructure.TaskAdvisorIDMap=containers.Map('KeyType','char','ValueType','double');
            obj.setParallelDatabase('');
            if nargin<2
                cacheFilePath=obj.getCacheFilePath;
                if exist(cacheFilePath,'file')
                    delete(cacheFilePath);
                end
            end
        end

        function loadCachedFcnHandle(obj,CheckObj)
            cacheFilePath=obj.getCacheFilePath;
            if~exist(cacheFilePath,'file')
                obj.update_customizations;
            end
            if obj.slCustomizationDataStructure.CheckIDMap.isKey(CheckObj.ID)
                CheckObjInManager=obj.slCustomizationDataStructure.checkCellArray{obj.slCustomizationDataStructure.CheckIDMap(CheckObj.ID)};
                varName=['FcnHandle_',num2str(CheckObj.Index)];
                load(cacheFilePath,'-mat',varName);
                loc_setFcnHandle(CheckObj,eval(varName));
                loc_setFcnHandle(CheckObjInManager,eval(varName));
            end
        end


        function loadAllCachedFcnHandle(obj,CheckCellArray)
            cacheFilePath=obj.getCacheFilePath;
            if~exist(cacheFilePath,'file')
                obj.update_customizations;
            end
            load(cacheFilePath,'FcnHandle_*');
            for i=1:length(CheckCellArray)
                varName=['FcnHandle_',num2str(CheckCellArray{i}.Index)];
                loc_setFcnHandle(CheckCellArray{i},eval(varName));
            end
        end

        function cachedData=loadCachedSlCustomizationData(obj)
            cacheFilePath=obj.getCacheFilePath;
            savedVars=load(cacheFilePath,'-mat','CustomizationData');
            cachedData=savedVars.CustomizationData;
        end

        function cacheFilePath=getCacheFilePath(~)
            cacheFilePath=fullfile(prefdir,'mdladvcache.mat');
        end


        varargout=copySlCustomizationData(obj,stage,varargin)

        updateCacheIfNeeded(obj,varargin)

        function output=getSlCustomizationData(obj,field)
            output=obj.slCustomizationDataStructure.(field);
        end



        function app=getActiveApp(this)
            app=this.ActiveApplicationObj;
        end



        function app=setActiveApp(this,varargin)
            if~isempty(varargin)
                if ischar(varargin{1})&&this.ApplicationObjMap.isKey(varargin{1})

                    this.ActiveApplicationObj=this.ApplicationObjMap(varargin{1});

                elseif isa(varargin{1},'Advisor.Application')

                    this.ActiveApplicationObj=varargin{1};

                elseif isempty(varargin{1})

                    this.ActiveApplicationObj=[];

                else

                end
            end

            app=this.ActiveApplicationObj;
        end


        function rootNodes=getAllTreeRoot(this)
            speedupReference=this.slCustomizationDataStructure.TaskAdvisorCellArray;
            rootNodes={};
            for i=1:numel(speedupReference)
                if isempty(speedupReference{i}.ParentIndex)
                    rootNodes{end+1}=speedupReference{i};%#ok<AGROW>
                end
            end
        end
    end




    methods(Access='private')



        function obj=Manager()
            obj.slCustomizationDataStructure.CheckIDMap=containers.Map('KeyType','char','ValueType','double');
            obj.slCustomizationDataStructure.TaskAdvisorIDMap=containers.Map('KeyType','char','ValueType','double');
        end


        function destroyApplication(this,ID)

            if~isempty(this.ApplicationObjMap)&&this.ApplicationObjMap.isKey(ID)

                activeApp=this.getActiveApplicationObj();

                if~isempty(activeApp)&&strcmp(activeApp.ID,ID)
                    this.getActiveApplicationObj([]);
                end


                this.ApplicationObjMap.remove(ID);


                if this.ApplicationObjMap.length==0

                    dlgObj=ModelAdvisor.ExportPDFDialog.getInstance;
                    dlgObj.delete;
                end
            end
        end

        cacheSlCustomizationData(obj);

        [checks,checkIDMap]=collectChecksAndTasks(this);

        taskAdvisorInfo=collectTaskAdvisorTasks(this);

    end




    methods(Static=true)
        applicationObj=createApplication(varargin)

        applicationObj=getApplication(varargin)

        refresh_customizations();

        function update_customizations
            am=Advisor.Manager.getInstance();
            am.refresh_customizations;
            am.loadslCustomization();
            am.cacheSlCustomizationData();
        end
    end




    methods(Static,Hidden)

        function singleObj=getInstance()
            mlock;
            persistent AdvisorManager;
            if isempty(AdvisorManager)||~isvalid(AdvisorManager)
                AdvisorManager=Advisor.Manager;
            end
            singleObj=AdvisorManager;
        end





        function app=getActiveApplicationObj(varargin)
            am=Advisor.Manager.getInstance;

            if isempty(varargin)
                app=am.getActiveApp();
            else
                app=am.setActiveApp(varargin{:});
            end
        end


        function handleEvent(src,evtdata)
            am=Advisor.Manager.getInstance;

            switch evtdata.EventName
            case 'IdChanged'
                newId=src.ID;


                if am.ApplicationObjMap.isKey(evtdata.OldID)

                    am.ApplicationObjMap.remove(evtdata.OldID);
                end



                if am.ApplicationObjMap.isKey(newId)
                    oldApp=am.ApplicationObjMap(newId);

                    oldApp.delete();
                end


                am.ApplicationObjMap(newId)=src;

            case 'Destroy'
                am.destroyApplication(src.ID);
            otherwise

            end
        end
    end





    methods(Static,Access=private)



        function checkLicense(token)

            internalToken='MWAdvi3orAPICa11';

            if strcmp(token,internalToken)

            else

                if(Advisor.Utils.license('test','SL_Verification_Validation')==1)
                    Advisor.Utils.license('checkout','SL_Verification_Validation');
                else
                    DAStudio.error('Advisor:base:App_APIMissingLicense');
                end
            end
        end
    end
end

function loc_setFcnHandle(CheckObj,varName)
    CheckObj.Callback=varName.Callback;
    CheckObj.InputParametersCallback=varName.InputParametersCallback;
    CheckObj.ListViewActionCallback=varName.ListViewActionCallback;
    CheckObj.ListViewActionCallback=varName.ListViewActionCallback;
    CheckObj.ListViewCloseCallback=varName.ListViewCloseCallback;
    if isfield(varName,'ActionCallbackHandle')
        CheckObj.Action.CallbackHandle=varName.ActionCallbackHandle;
    end
end