classdef CoderTargetConnection<coder.internal.connectivity.TgtConnTargetInfo





    properties(Access=private)
rtModel
TopModelName
SupportedAppSvcNames
SupportedAppSvcHeaders
SupportedAppSvcSimLibs
SupportedAppSvcNeeded
ConfigSetObj
TargetServiceInfo
AppServiceInfo
    end



    methods(Access={?coder.internal.connectivity.TgtConnMgr})
        function obj=CoderTargetConnection()
            obj.SupportedAppSvcNames={};
            [topMdlName,~]=coder.internal.connectivity.TgtConnMgr.getTopModelAndBuildArgs();
            if~isempty(topMdlName)

                obj.rtModel=[topMdlName,'_M'];
                obj.TopModelName=topMdlName;
                if codertarget.target.isCoderTarget(topMdlName)
                    obj.ConfigSetObj=getActiveConfigSet(topMdlName);
                    obj.SupportedAppSvcNames={...
                    'ToAsyncQueueAppSvc',...
                    'RTIOStreamAppSvc',...
                    'ParamTuningAppSvc',...
'StreamingProfilerAppSvc'...
                    };
                    obj.SupportedAppSvcHeaders={...
                    {'ToAsyncQueueTgtAppSvc/ToAsyncQueueTgtAppSvcCIntrf.h'},...
                    {'RTIOStreamTgtAppSvc/RTIOStreamTgtAppSvcCIntrf.h'},...
                    {'ParamTuningTgtAppSvc/ParamTuningTgtAppSvcCIntrf.h',[topMdlName,'.h'],'rtw_modelmap.h'},...
                    {'soc/StreamingProfilerTgtAppSvc/StreamingProfilerTgtAppSvcCIntrf.h'},...
                    };
                    [~,libExt]=coder.internal.connectivity.TgtConnMgr.getMLSysLibPathAndExt();
                    obj.SupportedAppSvcSimLibs={...
                    ['libmwcoder_ToAsyncQueueTgtAppSvc',libExt]...
                    ,['libmwcoder_ParamTuningTgtAppSvc',libExt]...
                    ,['libmwcoder_RTIOStreamTgtAppSvc',libExt]...
                    ,['libmwsoc_StreamingProfilerTgtAppSvc',libExt]...
                    };
                    obj.SupportedAppSvcNeeded=false(size(obj.SupportedAppSvcNames));
                    attributes=codertarget.attributes.getTargetHardwareAttributes(obj.ConfigSetObj);
                    if~isempty(attributes)&&attributes.EnableOneClick





                        lData=get_param(obj.ConfigSetObj,'CoderTargetData');
                        lIOInterface=lData.ExtMode.Configuration;
                        obj.TargetServiceInfo=attributes.getTargetService('toolchain',get_param(topMdlName,'Toolchain'),'iointerfacename',lIOInterface);
                        if~isempty(obj.TargetServiceInfo)
                            for i=1:length(obj.SupportedAppSvcNames)
                                p=obj.TargetServiceInfo.getApplicationService(topMdlName,obj.SupportedAppSvcNames{i});
                                if~isempty(p)&&isempty(obj.AppServiceInfo)
                                    obj.AppServiceInfo=p;
                                    obj.SupportedAppSvcNeeded(i)=true;
                                elseif~isempty(p)
                                    obj.AppServiceInfo(end+1)=p;
                                    obj.SupportedAppSvcNeeded(i)=true;
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    methods(Access=public)
        function isNeeded=isNeeded(obj)
            isNeeded=false;
            if~isempty(obj.TopModelName)&&~isempty(obj.TargetServiceInfo)
                isNeeded=codertarget.targetservices.needsCommService(obj.TopModelName,'CheckIfToAsynqBlocksPresent');
            end
        end

        function setupBeforeTLC(obj,mdl)
            buildInfo=rtwprivate('get_makertwsettings',mdl,'BuildInfo');
            if isempty(obj.TopModelName)

                return;
            end


            if~isempty(obj.TargetServiceInfo)
                targetInfo=codertarget.attributes.getTargetHardwareAttributes(obj.ConfigSetObj);


                for i=1:numel(obj.AppServiceInfo)
                    if coder.internal.connectivity.TgtConnMgr.isServiceNeeded(['coder.internal.connectivity.',obj.AppServiceInfo(i).Name])
                        appSvc=obj.AppServiceInfo(i);
                        if~isempty(appSvc.Library)
                            [pth,fn,ext]=fileparts(appSvc.Library);
                            pth=codertarget.utils.replaceTokens(obj.ConfigSetObj,pth,targetInfo.Tokens);
                            buildInfo.addLinkObjects([fn,ext],pth,1000,true,true,'TgtConn');
                        end
                        if~isempty(appSvc.LinkFlags)
                            linkFlags=codertarget.utils.replaceTokens(obj.ConfigSetObj,appSvc.LinkFlags,targetInfo.Tokens);
                            buildInfo.addLinkFlags(linkFlags,'SkipForSil');
                        end
                    end
                end
                if~isempty(obj.TargetServiceInfo.BuildConfigurationInfo.Libraries)
                    libs=obj.TargetServiceInfo.BuildConfigurationInfo.Libraries;
                    for ii=1:numel(libs)
                        [pth,fn,ext]=fileparts(libs{ii});
                        pth=codertarget.utils.replaceTokens(obj.ConfigSetObj,pth,targetInfo.Tokens);
                        buildInfo.addLinkObjects([fn,ext],pth,1000,true,true,'TgtConn');
                    end
                end
                if~isempty(obj.TargetServiceInfo.BuildConfigurationInfo.LinkFlags)
                    linkFlags=codertarget.utils.replaceTokens(obj.ConfigSetObj,obj.TargetServiceInfo.BuildConfigurationInfo.LinkFlags,targetInfo.Tokens);
                    buildInfo.addLinkFlags(linkFlags,'SkipForSil');
                end
                if~isempty(obj.TargetServiceInfo.BuildConfigurationInfo.SourceFiles)
                    srcFiles=codertarget.utils.replaceTokens(obj.ConfigSetObj,obj.TargetServiceInfo.BuildConfigurationInfo.SourceFiles,targetInfo.Tokens);
                    for ii=1:numel(srcFiles)
                        [pth,fn,ext]=fileparts(srcFiles{ii});
                        buildInfo.addSourceFiles([fn,ext],pth,'SkipForSil');
                    end
                end
                if~isempty(obj.TargetServiceInfo.BuildConfigurationInfo.IncludePaths)
                    incpaths=codertarget.utils.replaceTokens(obj.ConfigSetObj,obj.TargetServiceInfo.BuildConfigurationInfo.IncludePaths,targetInfo.Tokens);
                    buildInfo.addIncludePaths(incpaths,'SkipForSil');
                end
            end
        end

        function cleanupAfterTLC(obj,mdl)%#ok
        end

        function codeStr=getIncludesAndDefinesCode(obj)
            codeStr=[...
            '#include <stdio.h>',...
            newline];




            if~isempty(obj.TargetServiceInfo)
                for i=1:length(obj.SupportedAppSvcNames)
                    if obj.SupportedAppSvcNeeded(i)&&coder.internal.connectivity.TgtConnMgr.isServiceNeeded(['coder.internal.connectivity.',obj.SupportedAppSvcNames{i}])
                        for jj=1:numel(obj.SupportedAppSvcHeaders{i})
                            codeStr=[...
                            codeStr,...
                            '#include "',obj.SupportedAppSvcHeaders{i}{jj},'"',...
                            newline,...
                            ];%#ok<AGROW>
                        end
                    end
                end
                for i=1:length(obj.TargetServiceInfo.HeaderFiles)
                    codeStr=[...
                    codeStr,...
                    '#include "',obj.TargetServiceInfo.HeaderFiles{i},'"',...
                    newline,...
                    ];%#ok<AGROW>
                end
            end


            datatype=codertarget.targetservices.getTargetServiceArgs(obj.TopModelName,'datatype');
            codeStr=[...
            codeStr,...
            'extern void initializeCommService(',datatype,');',...
            'extern void terminateCommService();',...
            newline,...
            ];
        end

        function codeStr=getBackgroundTaskCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getMdlInitCode(obj)
            value=codertarget.targetservices.getTargetServiceArgs(obj.TopModelName);
            codeStr=['initializeCommService(',value,');'];
        end

        function codeStr=getMdlTermCode(obj)%#ok
            codeStr='terminateCommService();';
        end

        function codeStr=getPreStepCode(obj)
            if~isempty(obj.TargetServiceInfo)&&obj.SupportedAppSvcNeeded(3)


                codeStr=[...
                'rtwCAPI_ModelMappingInfo* rt_modelMapInfoPtr = &(rtmGetDataMapInfo(',obj.rtModel,').mmi);',...
                newline,...
                ];
            else
                codeStr='';
            end
        end

        function codeStr=getPostStepCode(obj)%#ok
            codeStr='';
        end

        function opts=getTargetConnectionOptions(~,argMap)



            opts=coder.internal.connectivity.ConnectionOptions;
            if argMap.isKey('transport')
                opts.Transport=argMap('transport');
            else
                opts.Transport='tcpip';
            end
            switch opts.Transport
            case 'serial'
                if argMap.isKey('serialport')
                    opts.SerialPort=argMap('serialport');
                end
                if argMap.isKey('baudrate')
                    opts.BaudRate=argMap('baudrate');
                end
            case 'tcpip'
                if argMap.isKey('port')
                    opts.IPPort=argMap('port');
                end
                if argMap.isKey('host')
                    opts.HostName=argMap('host');
                end
            end
        end

        function appSvcClassNames=getSupportedAppSvcNames(obj)
            appSvcClassNames=strcat('coder.internal.connectivity.',obj.SupportedAppSvcNames(obj.SupportedAppSvcNeeded));
        end
    end
    methods
        function obj=set.TargetServiceInfo(obj,val)
            if~isa(val,'codertarget.targetservices.TargetService')&&~isempty(val)
                error('Invalid value for the property TargetService. The values stored in the name must be of the type codertarget.targetservices.TargetService')
            end
            obj.TargetServiceInfo=val;
        end
        function obj=set.AppServiceInfo(obj,val)
            if~isa(val,'codertarget.targetservices.ApplicationService')&&~isempty(val)
                error('Invalid value for the property AppServiceInfo. The values stored in the name must of the type codertarget.targetservices.ApplciationService')
            end
            obj.AppServiceInfo=val;
        end
    end
end
