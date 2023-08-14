function blkH=buildSubsystem(subsys,varargin)




    args=locParseArgs(varargin{:});

    try
        blkH=locBuild(subsys,args);
    catch ex
        if args.OkayToPushNags


            coder.internal.createAndPushNag(ex);
        end
        if args.CalledFromInsideSimulink



            blkH=[];
        else

            rethrow(ex);
        end
    end

end

function blkH=locBuild(subsys,args)

    blkH=[];

    forceTopModelBuild=args.ForceTopModelBuild;

    ssBlkH=get_param(subsys,'Handle');
    ssName=getfullname(subsys);
    origModel=bdroot(subsys);

    platformType=coder.dictionary.internal.getPlatformType(origModel);

    if strcmp(platformType,'FunctionPlatform')
        DAStudio.error(...
        'RTW:buildProcess:SubsystemBuildNotSupportedForFunctionPlatform');
    elseif strcmp(platformType,'ApplicationPlatform')




        [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(origModel);
        sdpMappingTypes={'CoderDictionary','CppModelMapping'};
        if~isempty(mapping)&&...
            ismember(mappingType,sdpMappingTypes)&&...
            (strcmp(mapping.DeploymentType,'Component')...
            ||strcmp(mapping.DeploymentType,'Subcomponent'))
            DAStudio.error(...
            'RTW:buildProcess:SubsystemBuildNotSupportedForDeploymentType');
        end
    else
        assert(false,'Unknown platform type: %s',platformType);
    end

    if isempty(args.ExpandVirtualBusPorts)
        expandVirtualBusPorts=~slfeature('RightClickBuild');
    else
        expandVirtualBusPorts=args.ExpandVirtualBusPorts;
    end

    ss2mdlArgs={'PushNags',args.OkayToPushNags,'CheckSimulationResults',args.CheckSimulationResults,...
    'ReplaceSubsystem',args.ReplaceSubsystem,'ExpandVirtualBusPorts',expandVirtualBusPorts};

    if strcmpi(args.Mode,'ExportFunctionCalls')
        if ecoderinstalled(origModel)

            if Simulink.harness.internal.isHarnessCUT(ssBlkH)
                DAStudio.error('RTW:buildProcess:exportFcnNotSupportedForHarnessCUT');
            end

            load_system('simulink');
            load_system('expfcnlib');



            rtwprivate('rtwattic','createSIDMap');

            [mdlHdl,strPorts,err,mExc]=coder.internal.ss2mdl(ssBlkH,...
            ss2mdlArgs{:},...
            'ExportFunctions',true,...
            'ExpFcnFileName',args.ExportFunctionFileName,...
            'ExpFcnInitFcnName',args.ExportFunctionInitializeFunctionName);


            if~ishandle(ssBlkH)
                ssBlkH=get_param(ssName,'Handle');
            end


            forceTopModelBuild=true;
        else
            DAStudio.error('RTW:buildProcess:invalidSubsystemBuild');
        end
    else


        rtwprivate('rtwattic','createSIDMap');
        [mdlHdl,strPorts,err,mExc]=coder.internal.ss2mdl(ssBlkH,ss2mdlArgs{:});
    end



    ss2mdlCleanup=onCleanup(@()locCloseModel(mdlHdl));


    set_param(origModel,'StatusString',message('RTW:buildStatus:Building').getString);

    resetStatusBar=onCleanup(@()set_param(origModel,'StatusString',''));

    if args.OkayToPushNags

        mExc=[];
    end

    strPorts.ExportFunctionCalls=strcmpi(args.Mode,'ExportFunctionCalls');
    if err==0&&~isempty(mdlHdl)
        mdl=get_param(mdlHdl,'Name');
        set_param(0,'CurrentSystem',mdl);
        if~coder.internal.buildUtils('HasTargetVariableStepSolverSupport',mdlHdl)
            coder.internal.buildUtils('SetSolverToFixStepSolver',mdlHdl);
        end
    else
        err=1;
    end

    if err==0


        old_autosave_state=get_param(0,'AutoSaveOptions');
        new_autosave_state=old_autosave_state;
        new_autosave_state.SaveOnModelUpdate=0;
        set_param(0,'AutoSaveOptions',new_autosave_state);


        metaData=get_param(mdlHdl,'MetaData');
        isConvertedViaModelReference=~isempty(metaData)&&...
        isfield(metaData,'IsConvertedViaModelReference')&&...
        metaData.IsConvertedViaModelReference;

        if isConvertedViaModelReference


            subsystemBuildCleanup=onCleanup(@()[]);
        else

            cs=getActiveConfigSet(mdlHdl);
            if hasProp(cs,'ExtMode')&&strcmp(get_param(cs,'ExtMode'),'on')

                set_param(cs,'ExtMode','off');

                MSLDiagnostic('RTW:buildProcess:ExtModeDisabled').reportAsWarning;
            end


            subsystemBuildCleanup=coder.internal.SubsystemBuild.create(ssBlkH,mdlHdl);


            ssFcnClsObj=get_param(ssBlkH,'SSRTWFcnClass');
            if~isempty(ssFcnClsObj)
                DAStudio.warning('coderdictionary:mapping:SubsystemBuildFPCForC',...
                getfullname(ssBlkH));
            end
            ssCppFcnClsObj=get_param(ssBlkH,'SSRTWCPPFcnClass');
            if~isempty(ssCppFcnClsObj)
                DAStudio.warning('coderdictionary:mapping:SubsystemBuildFPCForCPP',...
                getfullname(ssBlkH));
            end
        end

        genCodeOnlyArg={};
        if~isempty(args.GenerateCodeOnly)
            genCodeOnlyArg={'GenerateCodeOnly',args.GenerateCodeOnly};
        end

        configSetArg={};
        if slfeature('ConfigSetActivator')>0&&~isempty(args.ConfigSet)
            configSetArg={'ConfigSet',args.ConfigSet};
        end

        try

            sl('slbuild_private',...
            mdl,...
            'StandaloneCoderTarget',...
            'SubSystemBuild',true,...
            'ForceTopModelBuild',forceTopModelBuild,...
            'OkayToPushNags',args.OkayToPushNags,...
            'ObfuscateCode',args.ObfuscateCode,...
            'IncludeModelReferenceSimulationTargets',args.IncludeModelReferenceSimulationTargets,...
            'OpenBuildStatusAutomatically',args.OpenBuildStatusAutomatically,...
            configSetArg{:},...
            genCodeOnlyArg{:});

        catch mExc



            set_param(0,'AutoSaveOptions',old_autosave_state);
            err=1;
            if~isConvertedViaModelReference


                mExc=locMapExceptionToOriginalModel(mExc,mdlHdl,ssBlkH);
            end
        end
        delete(subsystemBuildCleanup)
        set_param(0,'AutoSaveOptions',old_autosave_state);
    end

    if slroot().isValidSlObject(mdlHdl)
        if~err



            buildDirs=RTW.getBuildDir(mdl);
            coder.internal.buildUtils('SaveSInfo',mdlHdl,ssBlkH,buildDirs.BuildDirectory);
        end
    end



    rtwprivate('rtwattic','deleteSIDMap');

    if err
        if~isempty(mExc)
            throw(mExc);
        end
    else



        try
            blkH=coder.internal.ssGenSfunPost(mdl,ssBlkH,strPorts);
        catch exc %#ok

            return;
        end
    end
end

function locCloseModel(mdl)
    if slroot().isValidSlObject(mdl)
        close_system(mdl,0);
    end
end

function msl=locMapExceptionToOriginalModel(origEx,model,origBlk)
    try
        hdls=origEx.handles{1};
    catch
        hdls=[];
    end
    msg=origEx.message;


    hdls=hdls(ishandle(hdls));
    for i=1:length(hdls)
        hdl=hdls(i);
        if isequal(get_param(hdl,'type'),'block')
            if isequal(bdroot(hdl),bdroot(model))


                oldName=getfullname(hdl);
                [~,newName]=strtok(oldName,'/');
                newName=strcat(get_param(origBlk,'Parent'),newName);
                root=get_param(0,'Object');
                if root.isValidSlObject(newName)
                    oldName=strrep(oldName,newline,' ');
                    newName=strrep(newName,newline,' ');
                    msg=...
                    strrep(origEx.message,oldName,newName);
                end
            end
        end
    end
    msl=MSLException(hdls,origEx.identifier,'%s',msg);
    msl=msl.setMetaData('CATEGORY','Build');

    if isa(origEx,'MSLException')
        msl=msl.setMetaData('ACTION',origEx);
    end
    causes=origEx.cause;
    if~isempty(causes)
        for c=1:length(causes)
            singleCause=locMapExceptionToOriginalModel(causes{c},model,origBlk);
            msl=msl.addCause(singleCause);
        end
    end
end

function args=locParseArgs(varargin)

    persistent p;
    if isempty(p)
        p=inputParser;
        p.addParameter('GenerateCodeOnly',[],@isCoercibleToLogical);
        p.addParameter('StoredChecksum',[]);
        p.addParameter('ForceTopModelBuild',false,@isCoercibleToLogical);
        p.addParameter('OpenBuildStatusAutomatically',false,@isCoercibleToLogical);
        p.addParameter('ConfigSet',[]);
        p.addParameter('OnlyCheckConfigsetMismatch',false,@isCoercibleToLogical);
        p.addParameter('OkayToPushNags',false,@isCoercibleToLogical);
        p.addParameter('ObfuscateCode',false,@isCoercibleToLogical);
        p.addParameter('SubSystemBuild',false,@isCoercibleToLogical);
        p.addParameter('IncludeModelReferenceSimulationTargets',false,@isCoercibleToLogical);
        p.addParameter('Mode','Normal',@(x)any(strcmpi(x,{'Normal','ExportFunctionCalls'})));
        p.addParameter('ExportFunctionFileName','',@ischar);
        p.addParameter('ExportFunctionInitializeFunctionName','',@iscvar);
        p.addParameter('CheckSimulationResults',false,@isCoercibleToLogical);
        p.addParameter('ReplaceSubsystem',false,@isCoercibleToLogical);
        p.addParameter('ExpandVirtualBusPorts',[],@isCoercibleToLogical);
        p.addParameter('ParallelBuildContext',[],@(x)isa(x,'coder.parallel.ParallelBuildContext'));
        p.addParameter('CalledFromInsideSimulink',false,@isCoercibleToLogical);
    end
    p.parse(varargin{:});
    args=p.Results;
end

function tf=isCoercibleToLogical(x)
    tf=isscalar(x)&&(islogical(x)||isnumeric(x));
end


