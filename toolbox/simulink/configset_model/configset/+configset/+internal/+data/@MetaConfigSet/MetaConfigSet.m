

classdef MetaConfigSet<configset.internal.data.ParamContainer
    properties
        ComponentList={};


        ComponentMap=containers.Map('KeyType','char','ValueType','any');%#ok<MCHDP>
        WidgetNameMap=containers.Map('KeyType','char','ValueType','char');%#ok<MCHDP>





    end

    properties(Constant,Hidden)
        BasePath=fullfile('toolbox','simulink','configset_model','datamodel');
        DataPath=fullfile(configset.internal.data.MetaConfigSet.BasePath,'data');
        SaveFile='ConfigSetData.mat';
        MatFile=fullfile(matlabroot,configset.internal.data.MetaConfigSet.BasePath,configset.internal.data.MetaConfigSet.SaveFile);
        DerivedDataDir=fullfile(matlabroot,'toolbox','simulink','configset_model','configset','derived','htmlview');
        DerivedScriptDir=fullfile(matlabroot,'toolbox','simulink','configset_model','configset','derived','+configset');


        DerivedDataPath='/toolbox/simulink/configset_model/configset/derived/htmlview';

        DerivedScriptPath=fullfile(matlabroot,'/toolbox/simulink/configset_model/configset/derived');
    end

    properties(Dependent)
XmlFiles
    end

    properties(Hidden)
Dlg
    end

    methods(Static)
        function obj=getInstance(varargin)
mlock
            persistent cssd
            saveMat=configset.internal.data.MetaConfigSet.MatFile;
            if nargin==0
                if isempty(cssd)
                    if loc_needReGen
                        cssd=configset.internal.data.MetaConfigSet;


                        if exist(saveMat,'file')
                            delete(saveMat);
                        end
                        save(saveMat,'cssd');
                    else
                        tmp=load(saveMat);
                        cssd=tmp.cssd;
                        cssd.loadCustomComponent();
                        if cssd.isValid


                            cssd.isLoaded(true);
                        end
                    end
                end
            else
                if strcmp(varargin{1},'new')
                    cssd=configset.internal.data.MetaConfigSet;
                    cssd.parse();
                    cssd.setup();


                    if exist(saveMat,'file')
                        delete(saveMat);
                    end
                    save(saveMat,'cssd');
                end
            end
            obj=cssd;
        end
    end

    methods
        function out=getComponent(obj,name)
            if~obj.ComponentMap.isKey(name)

                out=[];
            else
                out=obj.ComponentMap(name);
            end
        end

        function out=get.XmlFiles(~)
            files=loc_getFiles();
            out={files.name}';
        end

        function out=getBaseXmls(~)
            [~,base,~,~]=loc_getFiles();
            out={base.name}';
        end

        function out=getCustomXmls(~)
            [~,~,custom,~]=loc_getFiles();
            out={custom.name}';
        end

        function out=getTargetXmls(~)
            [~,~,~,target]=loc_getFiles();
            out={target.name}';
        end
    end

    methods(Access=public)
        parse(obj)
        setup(obj)
        out=isValid(obj)
        addComponent(obj,cp)
        [dm,loadNeeded]=loadComponent(obj,componentClassName,componentPath)
    end

    methods(Hidden)
        widget=findWidget(obj,wName,varargin);
        dlg=view(obj)
    end

    methods(Access=private)
        addParams(obj,paramList)
    end

    methods(Static)
        cp=parseComponentXml(xmlFile,varargin)
        cp=buildComponentXml(xmlFile,type,dstDir)



        function out=isFeatureUnique(paramList)
            out=true;
            for i=1:length(paramList)
                if isempty(paramList{i}.Feature)
                    out=false;
                    break;
                end
            end
        end

        out=isLoaded(varargin)

        out=registerComponent(varargin)





    end
end


function out=loc_needReGen
    matfile=dir(configset.internal.data.MetaConfigSet.MatFile);
    if isempty(matfile)
        out=true;
        return;
    end

    out=false;
end

function[out,base,custom,target]=loc_getFiles

    xmlFolder=fullfile(matlabroot,configset.internal.data.MetaConfigSet.DataPath);
    baseXml=dir(fullfile(xmlFolder,'*.xml'));
    for i=1:length(baseXml)
        cmp=baseXml(i).name;
        fileName=fullfile(matlabroot,configset.internal.data.MetaConfigSet.DataPath,cmp);
        base(i)=dir(fileName);%#ok
    end

    customXml=dir(fullfile(xmlFolder,'CustomCC','*.xml'));
    for i=1:length(customXml)
        cmp=customXml(i).name;
        fileName=fullfile(xmlFolder,'CustomCC',cmp);
        custom(i)=dir(fileName);%#ok
    end

    targetXml=dir(fullfile(xmlFolder,'Target','*.xml'));
    for i=1:length(targetXml)
        cmp=targetXml(i).name;
        fileName=fullfile(xmlFolder,'Target',cmp);
        target(i)=dir(fileName);%#ok
    end

    out=[base,custom,target];
end
