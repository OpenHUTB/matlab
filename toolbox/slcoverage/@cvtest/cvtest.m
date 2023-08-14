





























classdef cvtest<cv.internal.cvtest&SlCov.CovEngineProxy

    properties(GetAccess=public,SetAccess=private,Dependent=true)
modelcov
rootPath
    end

    properties(Dependent=true)
label
setupCmd
settings
modelRefSettings
emlSettings
options
filter
excludeInactiveVariants
    end

    properties(Hidden=true,Dependent=true)
sfcnSettings
    end

    methods



        function this=cvtest(varargin)



            narginchk(1,3);




            [varargin{:}]=convertStringsToChars(varargin{:});

            modelId=[];
            switch nargin
            case 1
                switch class(varargin{1})
                case 'double'
                    handle=varargin{1};

                    if~isempty(handle)&&isequal(floor(handle),handle)&&...
                        cv('ishandle',handle)&&cv('get',handle,'.isa')==cv('get','default','test.isa')
                        this.id=handle;

                    elseif ishandle(handle)
                        [modelId,path]=resolve_model_and_path(handle);
                        create_new_test(this,modelId,path);
                    else
                        error(message('Slvnv:simcoverage:cvtest:BadInput'));
                    end

                case 'char'
                    [modelId,path]=resolve_model_and_path(varargin{1});
                    create_new_test(this,modelId,path);

                otherwise
                    if isa(varargin{1},class(this))
                        this=varargin{1};
                        return
                    end
                end

            case 2
                [modelId,path]=resolve_model_and_path(varargin{1});
                create_new_test(this,modelId,path);
                install_test_label(this.id,varargin{2})
            case 3
                [modelId,path]=resolve_model_and_path(varargin{1});
                create_new_test(this,modelId,path);
                install_test_label(this.id,varargin{2})
                install_setup_cmd(this.id,varargin{3})
            otherwise
                [modelId,path]=resolve_model_and_path(varargin{1});
                create_new_test(this,modelId,path);
                install_test_label(this.id,varargin{2})
                install_setup_cmd(this.id,varargin{3})
            end

            if~isempty(modelId)
                modelName=SlCov.CoverageAPI.getModelcovName(modelId);
                [status,msgId]=cvi.TopModelCov.checkLicense(get_param(modelName,'handle'));
                if status==0
                    error(message(msgId));
                end
                copyMetricsFromModel(this,modelName);
            end

        end

        function res=valid(testObj)
            res=true;
            id=testObj.id;

            if testObj.isInvalidated||~cv('ishandle',id)...
                ||isempty(cv('get',id,'.isa'))...
                ||cv('get',id,'.isa')~=cv('get','default','testdata.isa')

                res=false;
            end
        end



        display(testObj)



        function value=get.settings(this)
            metricNames=cvi.MetricRegistry.getAllSettingsMetricNames();
            value=[];
            for idx=1:numel(metricNames)
                metric=metricNames{idx};
                value.(metric)=getSettingsMetricValue(this,metric);
            end
        end

        function set.settings(this,value)
            metNames=fieldnames(value);
            for idx=1:numel(metNames)
                metricName=metNames{idx};
                setMetric(this,metricName,value.(metricName));
            end
        end

        function value=get.modelRefSettings(this)
            value.enable=cv('get',this.id,'testdata.mldref_enable');
            value.excludeTopModel=cv('get',this.id,'testdata.mldref_excludeTopModel');
            value.excludedModels=cv('get',this.id,'testdata.mldref_excludedModels');
        end

        function set.modelRefSettings(this,value)
            enableStr=convertStringsToChars(value.enable);
            if~ischar(enableStr)
                enableStr='on';
            end
            cv('set',this.id,'testdata.mldref_enable',enableStr);
            cv('set',this.id,'testdata.mldref_excludeTopModel',value.excludeTopModel);
            cv('set',this.id,'testdata.mldref_excludedModels',convertStringsToChars(value.excludedModels));
        end

        function value=get.options(this)
            value.forceBlockReduction=cv('get',this.id,'testdata.forceBlockReductionOff');

            cvs=this.getSlcovSettings;
            value.useTimeInterval=cvs.useTimeInterval;
            value.intervalStartTime=cvs.intervalStartTime;
            value.intervalStopTime=cvs.intervalStopTime;
            value.covBoundaryRelTol=cvs.covBoundaryRelTol;
            value.covBoundaryAbsTol=cvs.covBoundaryAbsTol;

            if SlCov.isMaskingMcdcCovFeatureOn
                value.mcdcMode=SlCov.McdcMode(cv('get',this.id,'testdata.mcdcMode'));
            end
        end

        function set.options(this,value)

            cv('set',this.id,'testdata.forceBlockReductionOff',value.forceBlockReduction);

            cvs=this.getSlcovSettings;
            cvs.covBoundaryRelTol=value.covBoundaryRelTol;
            cvs.covBoundaryAbsTol=value.covBoundaryAbsTol;
            cvs.useTimeInterval=value.useTimeInterval;
            cvs.intervalStartTime=value.intervalStartTime;
            cvs.intervalStopTime=value.intervalStopTime;

            if SlCov.isMaskingMcdcCovFeatureOn
                cv('set',this.id,'testdata.mcdcMode',SlCov.McdcMode(value.mcdcMode));
            end
        end

        function value=get.modelcov(this)
            value=cv('get',this.id,'testdata.modelcov');
        end

        function value=get.rootPath(this)
            value=cv('GetTestRootPath',this.id);
        end

        function value=get.label(this)
            value=cv('get',this.id,'testdata.label');
        end

        function set.label(this,value)
            cv('set',this.id,'testdata.label',convertStringsToChars(value));
        end

        function value=get.setupCmd(this)
            value=cv('get',this.id,'testdata.mlSetupCmd');
        end

        function set.setupCmd(this,value)
            cv('set',this.id,'testdata.mlSetupCmd',convertStringsToChars(value));
        end

        function value=get.emlSettings(this)
            value.enableExternal=cv('get',this.id,'testdata.covExternalEMLEnable');
        end

        function set.emlSettings(this,value)
            cv('set',this.id,'testdata.covExternalEMLEnable',value.enableExternal);
        end

        function value=get.filter(this)
            value.fileName=cv('get',this.id,'testdata.covFilter');
        end

        function set.filter(this,value)

            if isfield(value,'filename')
                val=value.filename;
            elseif isfield(value,'fileName')
                val=value.fileName;
            elseif ischar(value)
                val=value;
            else
                val='';
            end
            cv('set',this.id,'testdata.covFilter',convertStringsToChars(val));
        end

        function value=get.sfcnSettings(this)
            value.enableSfcn=cv('get',this.id,'testdata.covSFcnEnable');
        end

        function set.sfcnSettings(this,value)
            cv('set',this.id,'testdata.covSFcnEnable',value.enableSfcn);
        end

        function value=get.excludeInactiveVariants(this)
            value=cv('get',this.id,'testdata.excludeInactiveVariants');
        end

        function set.excludeInactiveVariants(this,value)
            cv('set',this.id,'testdata.excludeInactiveVariants',value);
        end


    end
    methods(Static,Hidden)
        function testId=create(modelId)
            testId=cv('new','testdata',...
            '.type','CMDLINE_TST',...
            '.modelcov',modelId,...
            '.dbVersion',SlCov.CoverageAPI.getDbVersion());
            cvtest.setMf0(testId);
        end

        function testId=setMf0(testId)

            model=mf.zero.Model;
            cv('set',testId,'testdata.mf0.model',model);
            cv('set',testId,'testdata.mf0.settings',slcov.settings(model));
        end
        function testId=deleteMf0(testId)
            settings=cv('get',testId,'testdata.mf0.settings');
            if~isempty(settings)
                settings.destroy;
            end

            model=cv('get',testId,'testdata.mf0.model');
            if~isempty(model)
                model.destroy;
            end
        end
        function settings=getMf0Settings(testId)
            settings=cv('get',testId,'testdata.mf0.settings');
        end

    end
    methods(Hidden)


        activate(testObj,modelcovId)
        outTestObj=clone(testObj,varargin)
        testObj=copyMetricsFromModel(testObj,modelName)
        copySettings(testObj,fromTestObj)
        [enabled,enabledTO]=getEnabledMetricNames(testObj)
        value=getMetricValue(cvtest,metricName)
        value=getTOMetricValue(cvtest,metricName)
        cvtest=setAllMetric(cvtest,value)
        cvtest=setMetric(cvtest,metricName,value)
        setMetricDataOn(cvtest,metricNames)
        value=getSettingsMetricValue(cvtest,metricName)

        function settings=getSlcovSettings(testObj)
            settings=cvtest.getMf0Settings(testObj.id);
        end

        function value=getCutPath(this)
            value=cv('get',this.id,'testdata.cutPath');
        end

        function setCutPath(this,value)
            cv('set',this.id,'testdata.cutPath',value);
        end

    end

end





function path=getPath(model,block)
    path=getfullname(block);
    bdName=get_param(model,'Name');
    bdlength=length(bdName);
    path=path((bdlength+2):end);
end

function[modelId,path]=resolve_model_and_path(block)

    try

        cvprivate('model_name_refresh');

        if ischar(block)
            if exist(block,'file')==4
                [~,block,~]=fileparts(block);
            end

            block=get_param(block,'Handle');
        end
        model=bdroot(block);
    catch Mex
        error(message('Slvnv:simcoverage:cvtest:OpenModel'));
    end

    path='';
    if(block~=model)
        if~isa(get_param(block,'object'),'Simulink.SubSystem')
            error(message('Slvnv:simcoverage:cvtest:BadInputNotSubsystem',getfullname(block)));
        end
        path=getPath(model,block);
    end

    modelId=get_param(model,'CoverageId');
    if~cv('ishandle',modelId)||...
        ~strcmpi(getfullname(model),SlCov.CoverageAPI.getModelcovName(modelId))
        [~,modelId]=cvi.TopModelCov.setup(model);
    end

end





function testId=create_new_test(testObj,modelId,path,~)


    testId=cvtest.create(modelId);

    cv('SetTestRootPath',testId,path);
    testObj.id=testId;




    cv('PendingTestAdd',modelId,testId);


end



function install_test_label(testId,label)

    if~ischar(label)
        error(message('Slvnv:simcoverage:cvtest:InvalidArgumentForTestName'))
    end

    cv('set',testId,'.label',label);

end



function install_setup_cmd(testId,cmd)

    if~ischar(cmd)
        error(message('Slvnv:simcoverage:cvtest:InvalidArgumentForSetupCommandString'))
    end

    cv('set',testId,'.mlSetupCmd',cmd);

end





