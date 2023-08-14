classdef ReportInfo<coder.report.ReportInfoBase


    properties(Hidden)
        AddCode=true
ModelFile
        ModelVersion=''
        CoderVersion=''
        HDLCoderVersion=''
        CodeFormat=''
        TargetLang=''
        ModelReferenceTargetType=''
BInfoMat
CodeVariants
TopProtectedModelReferences
ModelReferences
ModelReferencesBuildDir
ModelReferencesReports
        SourceSubsystem=''
TemporaryModelFullSSName
        SourceSubsystemFullName=''
        SystemMap={}
IsERTTarget
        Target=''
        WebviewFileName=''
        IsTestHarness=false
        HarnessOwner=''
        HarnessName=''
        OwnerFileName=''

        PerfTracerTargetName=''
    end

    properties(Transient)
        ModelName=''
        GenUtilsPath=''
    end

    properties(Access=private,Transient)
        CachedSortedFileInfo={}
WebDDG
    end

    methods(Abstract=true)
        registerPages(obj)
        emitContents(obj,filename)
    end

    methods
        function obj=ReportInfo(modelName)
            obj.ModelName=modelName;
            obj.Dirty=true;
            obj.WebviewFileName='';
        end
        function set.GenUtilsPath(obj,value)
            if~isempty(value)&&value(end)==filesep

                value=fileparts(value);
            end
            obj.GenUtilsPath=value;
        end
    end

    methods(Hidden)
        out=isSameReportAsDisplay(obj)
        out=getWebDDG(obj)
        preSetEvt(obj,~,~)
        taggedFiles=getTaggedFiles(obj,tag)
        removeTaggedFiles(obj,tag)
        out=hasWebview(obj)
        out=isValidateReportInfo(obj,varargin)
        emitRequirements(obj)
        out=getURL(obj)
        openInApp(obj,url)
    end

    methods(Access=private)
        setSlprjFolder(obj,slprjFolder)
    end

    methods(Static)
        h=getBrowserDocument
        ret=getBrowserDialog(varargin)
        closeDialog(varargin)
        openURL(url,varargin)
        hyperlink=getMatlabCallHyperlink(cmd)
    end

    methods(Static=true,Hidden=true)
        setCleanupAfterShow(val)
        dlg=setBrowserDialog(url,title,helpMethod)
        openInWebkit(url,title,helpMethod)
        openInExternalBrowser(url)
        out=featureOpenInStudio(value)
        out=featureOpenInApp(value)
        out=featureWebview2(value)
        out=featureReportV2(value)
        out=debugReportV2(value)
        str=escapeSpecialCharInJS(str)
    end
end


