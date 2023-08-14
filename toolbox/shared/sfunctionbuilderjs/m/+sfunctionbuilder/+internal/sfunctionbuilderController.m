classdef sfunctionbuilderController<handle




    properties(SetAccess=protected)
sfunctionbuilderModel
    end

    methods

        function obj=sfunctionbuilderController()
            obj.sfunctionbuilderModel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();
        end


        function attachModel()
        end


        function buildLog=doBuild(obj,blockHandle)
            applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);

            if~strcmp(applicationData.blockName,getfullname(blockHandle))
                obj.updateSFunctionBlockPath(blockHandle,getfullname(blockHandle));
                applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);
            end
            [applicationData,abortBuild]=sfcnbuilder.doBuild_CheckNameAndLangext(blockHandle,applicationData);
            buildLog=applicationData.buildLog;
            obj.sfunctionbuilderModel.setApplicationData(blockHandle,applicationData);


            if~abortBuild
                obj.sfunctionbuilderModel.refreshViews(blockHandle,'set unsaved change',false);
            end
        end

        function doPackage(obj,blockHandle)
            applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);
            if~strcmp(applicationData.blockName,getfullname(blockHandle))
                obj.updateSFunctionBlockPath(blockHandle,getfullname(blockHandle));
                applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);
            end
            applicationData=sfunctionwizard(blockHandle,'doPackage',applicationData);
            obj.sfunctionbuilderModel.setApplicationData(blockHandle,applicationData);
        end

        function updateSFunctionPackageOption(obj,blockHandle,optionSetting)
            obj.sfunctionbuilderModel.updateSFunctionPackageOption(blockHandle,optionSetting);
        end


        function abortClose=doSave(obj,blockHandle)
            applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);
            if isfield(applicationData,'SfunWizardData')
                if isfield(applicationData.SfunWizardData,'BeginPackaging')
                    applicationData.SfunWizardData.BeginPackaging='0';
                end
                if isfield(applicationData.SfunWizardData,'SignPackage')
                    applicationData.SfunWizardData.SignPackage='0';
                end
                if isfield(applicationData.SfunWizardData,'CertificateName')
                    applicationData.SfunWizardData.CertificateName='';
                end
            end

            if~strcmp(applicationData.blockName,getfullname(blockHandle))
                obj.updateSFunctionBlockPath(blockHandle,getfullname(blockHandle));
                applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);
            end

            [~,abortClose]=sfcnbuilder.doBuild_CheckNameAndLangext(blockHandle,applicationData,true);

            if~abortClose
                obj.sfunctionbuilderModel.refreshViews(blockHandle,'set unsaved change',false);
            end
        end


        function updateSFBWindowPostion(obj,blockHandle,type,position)
            obj.sfunctionbuilderModel.updateSFBWindowPostion(blockHandle,type,position);
        end


        function position=getSFBWindowPostion(obj,blockHandle,type)
            position=obj.sfunctionbuilderModel.getSFBWindowPostion(blockHandle,type);
        end


        function updateSFunctionName(obj,blockHandle,name)
            obj.sfunctionbuilderModel.updateSFunctionName(blockHandle,name);
        end


        function updateCertificateName(obj,blockHandle,name)
            obj.sfunctionbuilderModel.updateCertificateName(blockHandle,name);
        end


        function updateSFunctionLanguage(obj,blockHandle,language)
            obj.sfunctionbuilderModel.updateSFunctionLanguage(blockHandle,language);
        end


        function updateSFunctionBlockPath(obj,blockHandle,bpath)
            obj.sfunctionbuilderModel.updateSFunctionBlockPath(blockHandle,bpath);
        end


        function applicationData=setSourceFileOverwritable(obj,blockHandle)
            obj.sfunctionbuilderModel.setSourceFileOverwritable(blockHandle);
            applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);
            applicationData=sfcnbuilder.doBuild_OverwriteTLC(blockHandle,applicationData);
        end


        function applicationData=setTLCFileOverwritable(obj,blockHandle)
            applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);
            applicationData=sfcnbuilder.doFinish(blockHandle,applicationData);
        end


        function updateSFunctionBuildOption(obj,blockHandle,optionSetting)
            obj.sfunctionbuilderModel.updateSFunctionBuildOption(blockHandle,optionSetting);
        end


        function updateSFunctionSetting(obj,blockHandle,setting)
            obj.sfunctionbuilderModel.updateSFunctionSetting(blockHandle,setting);
        end


        function newport=addItemToPortTable(obj,blockHandle,newItem)
            newport=obj.sfunctionbuilderModel.addItemToPortTable(blockHandle,newItem);
        end


        function delItemFromPortTable(obj,blockHandle,names,scopes)
            obj.sfunctionbuilderModel.delItemFromPortTable(blockHandle,names,scopes);
        end


        function updateUserCode(obj,blockHandle,userCode,varargin)






            refreshGUI=false;
            if nargin==4
                refreshGUI=varargin{1};
            end
            obj.sfunctionbuilderModel.updateUserCode(blockHandle,userCode,refreshGUI);
        end

        function updateParameterValue(obj,blockHandle,parameterName,value)
            obj.sfunctionbuilderModel.updateParameterValue(blockHandle,parameterName,value);
        end

        function updateItemOfPortTable(obj,blockHandle,newItem,field,oldvalue)
            obj.sfunctionbuilderModel.updateItemOfPortTable(blockHandle,newItem,field,oldvalue);
        end

        function addItemToLibTable(obj,blockHandle,item)
            obj.sfunctionbuilderModel.addItemToLibTable(blockHandle,item);
        end

        function delItemFromLibTable(obj,blockHandle,items,ranges)
            obj.sfunctionbuilderModel.delItemFromLibTable(blockHandle,items,ranges);
        end

        function updateItemOfLibTable(obj,blockHandle,oldItem,field,newValue,index)
            obj.sfunctionbuilderModel.updateItemOfLibTable(blockHandle,oldItem,field,newValue,index);
        end

        function applicationData=getApplicationData(obj,blockHandle)
            applicationData=obj.sfunctionbuilderModel.getApplicationData(blockHandle);
        end

        function saveSfunctionName(obj,blockHandle)

            applicationData=obj.getApplicationData(blockHandle);
            sfunctionName=applicationData.SfunWizardData.SfunName;
            if~(strcmp(sfunctionName,'system')||isempty(sfunctionName))
                set_param(blockHandle,'FunctionName',sfunctionName);
            end
        end

        function saveWizardData(obj,blockHandle)

            applicationData=obj.getApplicationData(blockHandle);
            set_param(blockHandle,'WizardData',applicationData.SfunWizardData);
        end


        function setApplicationData(obj,blockHandle,appData)
            obj.sfunctionbuilderModel.setApplicationData(blockHandle,appData);
        end



        function ad=refreshViews(obj,blockHandle,action,varargin)
            actionMessage=varargin{1};
            if nargin==4
                ad=obj.sfunctionbuilderModel.refreshViews(blockHandle,action,actionMessage);
            elseif nargin==5
                extraData=varargin{2};
                ad=obj.sfunctionbuilderModel.refreshViews(blockHandle,action,actionMessage,extraData);
            end

        end

    end


    methods(Static)
        function sfunctionbuilderController=getInstance()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=sfunctionbuilder.internal.sfunctionbuilderController();
            end
            sfunctionbuilderController=localObj;
        end




        function[fileContent,filePath]=readFileByName(fileName)
            if(exist(fileName,'file'))
                filePath=which(fileName);
                fileContent=fileread(filePath);
            else
                ME=MSLException('Simulink:SFunctionBuilder:MissingSourceFile',fileName);
                throw(ME)
            end
        end

    end

end

