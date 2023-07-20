





































function net=loadDeepLearningNetwork(matfile,varargin)
%#codegen 
    coder.internal.prefer_const(matfile);
    coder.allowpcode('plain');
    coder.extrinsic('coder.checkNetworkType');
    coder.extrinsic('dlcoder_base.internal.getBuildWorkflow');
    coder.extrinsic('dlcoder_base.internal.checkForSupportPackages');
    matfile=convertStringsToChars(matfile);
    if coder.target('MATLAB')

        [~,returnNetwork]=iParseNVP(varargin{:});


        errorId='gpucoder:cnncodegen:invalid_filename';
        matfileToPrint=strrep(matfile,'\','\\');
        assert(exist(matfile,'file')==2,errorId,getString(message(errorId,matfileToPrint)));

        net=coder.internal.loadCachedDeepLearningObj(matfile,'',ReturnNetwork=returnNetwork,UseCache=false);

    else
        coder.internal.errorIf(~coder.internal.isConst(matfile),'gpucoder:cnncodegen:NetworkShouldBeCompiletimeConstant');

        [networkClassName,returnNetwork]=coder.const(@iParseNVP,varargin{:});

        dlTargetLib=coder.const(eml_option('DLTargetLib'));
        ctx=eml_option('CodegenBuildContext');
        iCheckDisabledTargetLibrary(dlTargetLib,ctx);

        buildWorkflow=coder.const(@dlcoder_base.internal.getBuildWorkflow,ctx);
        coder.const(@dlcoder_base.internal.checkForSupportPackages,dlTargetLib,buildWorkflow);


        resultStruct=coder.const(@coder.checkNetworkType,matfile,'',ReturnNetwork=returnNetwork);

        if coder.const(resultStruct.isYOLOv2)
            net=coder.internal.YOLOv2Network(coder.const(matfile),networkClassName);
        elseif coder.const(resultStruct.isYOLOv3)
            net=coder.internal.YOLOv3ObjectDetector(coder.const(matfile),networkClassName);
        elseif coder.const(resultStruct.isYOLOv4)
            net=coder.internal.YOLOv4ObjectDetector(coder.const(matfile),networkClassName);
        elseif coder.const(resultStruct.isSSD)
            net=coder.internal.ssdObjectDetector(coder.const(matfile),networkClassName);
        elseif coder.const(resultStruct.isPointPillars)
            net=coder.internal.pointPillarsObjectDetector(coder.const(matfile),networkClassName);
        elseif coder.const(resultStruct.isDLNetwork)
            if strcmp(dlTargetLib,'none')&&~coder.const(@feval,'dlcoderfeature','LibraryFreeCGIR')
                net=coder.internal.ctarget.dlnetwork(coder.const(matfile),coder.const(''),networkClassName);
            else
                net=coder.internal.dlnetwork(coder.const(matfile),coder.const(''),networkClassName);
            end
        elseif coder.const(resultStruct.isDAGNetwork)
            if strcmp(dlTargetLib,'none')&&~coder.const(@feval,'dlcoderfeature','LibraryFreeCGIR')
                net=coder.internal.ctarget.DeepLearningNetwork(coder.const(matfile),coder.const(''),networkClassName);
            else
                net=coder.internal.DeepLearningNetwork(coder.const(matfile),coder.const(''),networkClassName);
            end
        else



            coder.internal.assert(false,'gpucoder:cnncodegen:GenericNetworkWrapperNotSupportedLDN',...
            resultStruct.ClassName);
        end
    end


end

function[networkClassName,returnNetwork]=iParseNVP(varargin)
    coder.inline('always')
    coder.internal.prefer_const(varargin);

    possibleNameValues={'NetworkName',...
    'ReturnNetwork'};

    poptions=struct(...
    'CaseSensitivity',false,...
    'PartialMatching','unique',...
    'StructExpand',false,...
    'IgnoreNulls',true);

    defaults=struct('NetworkName','',...
    'ReturnNetwork',false);

    if(nargin==1)
        params=defaults;
    else
        pstruct=coder.internal.parseParameterInputs(possibleNameValues,poptions,varargin{:});
        networkClassName=coder.internal.getParameterValue(pstruct.NetworkName,defaults.NetworkName,varargin{:});
        returnNetwork=coder.internal.getParameterValue(pstruct.ReturnNetwork,defaults.ReturnNetwork,varargin{:});
        coder.internal.errorIf(~islogical(returnNetwork)||~isscalar(returnNetwork),"Coder:builtins:Explicit","The value of 'ReturnNetwork' must be a scalar logical.")
        coder.internal.errorIf(~ischar(networkClassName)&&~isstring(networkClassName),"Coder:builtins:Explicit","The value of 'NetworkName' must be a char or string.")

        params.NetworkName=convertStringsToChars(networkClassName);
        params.ReturnNetwork=returnNetwork;

    end
    networkClassName=coder.const(params.NetworkName);
    returnNetwork=coder.const(params.ReturnNetwork);
end



function iCheckDisabledTargetLibrary(targetLib,ctx)




    if~coder.target('MATLAB')

        eml_allow_mx_inputs;
    end

    coder.extrinsic('dlcoder_base.internal.errorForNoneTargetLib');







    if~coder.internal.isAmbiguousComplexity&&~coder.internal.isAmbiguousTypes



        coder.internal.assert(~isempty(targetLib),'gpucoder:cnncodegen:DLCoderInternalError');
        if strcmpi(targetLib,'disabled')
            if coder.target('Sfun')


                coder.internal.errorIf(~coder.const(feval('dlcoderfeature','LibraryFreeSimulinkSimulation')),...
                'gpucoder:cnnconfig:DLTargetLibUnsetSfun');
            else


                coder.const(@dlcoder_base.internal.errorForNoneTargetLib,ctx);
            end
        end
    end
end
