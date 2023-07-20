

classdef MetaConfigLayout<handle
    properties
WidgetGroupMap
GroupObjectMap
ParentGroupMap
TopLevelPanes

EnglishNameMap

FeatureSet
    end

    properties(Transient,Hidden)
LocalNameMap
    end

    properties(Transient,Dependent)

MetaCS
    end

    properties(Constant)
        BasePath=fullfile(matlabroot,'toolbox','simulink','configset_model','datamodel');
        DataPath=fullfile(configset.layout.MetaConfigLayout.BasePath,'layout');
        XmlFileName='ConfigSetCategoryLayout.xml';
        SaveFile='ConfigSetCategoryLayout.mat';
        BaseMatFile=fullfile(configset.layout.MetaConfigLayout.BasePath,configset.layout.MetaConfigLayout.SaveFile);
        CustomCCPath=strjoin({configset.layout.MetaConfigLayout.DataPath,'CustomCC'},filesep);
    end

    methods(Static)
        function matFile=getMatFile(className,componentPath)
            if isempty(componentPath)
                matFile=fullfile(configset.layout.MetaConfigLayout.CustomCCPath,[className,'.Layout.mat']);
            else
                matFile=fullfile(componentPath,[className,'.Layout.mat']);
            end
        end

        function xmlFile=getXmlFile(className,componentPath)
            if isempty(componentPath)
                xmlFile=fullfile(configset.layout.MetaConfigLayout.CustomCCPath,[className,'.Layout.xml']);
            else
                xmlFile=fullfile(componentPath,[className,'.Layout.xml']);
            end
        end

        obj=getInstance(varargin)
        obj=buildAll(matFile,xmlFile,customCCPath)
        out=getSTFPageDisplayPath(adp,pageName)
    end

    methods(Static,Hidden)
    end

    methods(Hidden)

        checkMissingWidgets(obj)

        buildWebCategoryLayout(layout,component,dirName)
        buildCustomFunctionScripts(layout,component,target,dirName)
        buildDispatchScripts(layout,component,dirName)
        lines=getFeatureControlScript(layout)
    end

    methods(Access=protected)
        function obj=MetaConfigLayout(xmlFile)
            obj.FeatureSet={};
            obj.parse(xmlFile);
            disp('ConfigSet Layout Model created');
        end

        addComponentParameters(obj,component)
    end

    methods(Access=private)
        parse(obj,xmlFileName)
        pane=getPaneDisplay(obj,paneID)
    end

    methods
        loadComponent(obj,className,componentPath)
        out=isUIParam(obj,param,varargin)
        UI=param2UI(obj,adp,names)
    end

    methods
        function out=get.MetaCS(~)
            out=configset.internal.getConfigSetStaticData;
        end

        out=getGroup(obj,groupID)
        out=getParentGroupName(obj,groupID)
        paneName=getPaneDisplayPath(obj,paneID,delimiter)
        out=getPaneDisplayName(obj,englishName)
        out=getParam(obj,name)
        out=getParamGroup(obj,name,varargin)
        [group,index]=getWidgetGroup(obj,name,safeMode,featureCheck)
        [wObject,index]=getWidget(obj,name,adp,cs,varargin)
        out=getParamPane(obj,name,varargin)
        paneName=getParamDisplayPath(obj,name,varargin)
        tag=getParamPageTag(obj,name)
        cshpath=getParamCSHPath(obj,name)
        cshmap=getParamCSHMap(obj,name)
        tags=getParamTags(obj,name,varargin)
        tag=getWidgetLabelTag(obj,name,cs)
        paneID=paneIDFromLocalName(obj,name)

        bool=isAdvanced(obj,name)
        features=getFeatures(obj)
    end
end





