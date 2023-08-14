function out=supportTargetServicesFeature(hObj,aFeatureName,varargin)







    out=false;
    if slfeature('ToAsyncQueueAppSvcForCoderTarget')&&...
        codertarget.target.isCoderTarget(hObj)
        if isa(hObj,'Simulink.ConfigSet')||isa(hObj,'Simulink.ConfigSetRef')
            hCS=hObj;
        elseif isa(hObj,'double')
            hCS=getActiveConfigSet(hObj);
        elseif isa(hObj,'char')
            if bdIsLoaded(hObj)
                hCS=getActiveConfigSet(hObj);
            else
                out=false;
                return
            end
        else
            assert(false,...
            'The first input argument to codertarget.attributes.supportTargetServicesFeature must be either a model name or a Config Set handle');
        end
        validateattributes(aFeatureName,{'char'},{'nonempty'});
        assert(ismember(aFeatureName,{'ToAsyncQueueAppSvc','RTIOStreamAppSvc','ParamTuningAppSvc','StreamingProfilerAppSvc'}),...
        'The input argument specified is not a supported target application service name');
        attributes=codertarget.attributes.getTargetHardwareAttributes(hObj);





        out=attributes.supportsAppService(hCS.getModel,aFeatureName);
        extmodeSupport=attributes.EnableOneClick&&...
        codertarget.data.isParameterInitialized(hCS,'ExtMode.Running');
        otherSupport=codertarget.data.isParameterInitialized(hCS,'TargetServices.Running')&&isequal(codertarget.data.getParameterValue(hCS,'TargetServices.Running'),1);
        out=out&&(extmodeSupport||otherSupport);
        if nargin>2&&isequal(aFeatureName,'ToAsyncQueueAppSvc')&&ismember('CheckIfToAsynqBlocksPresent',varargin)&&out



            instrumentedSignals=get_param(hCS.getModel,'InstrumentedSignals');
            hasTAQBlocks=false;
            if~isempty(instrumentedSignals)&&instrumentedSignals.Count>0
                hasTAQBlocks=true;
            else


                [allMdls,~]=find_mdlrefs(hCS.getModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                for ii=1:(numel(allMdls)-1)
                    if bdIsLoaded(allMdls{ii})
                        instrumentedSignals=get_param(allMdls{ii},'InstrumentedSignals');
                        if~isempty(instrumentedSignals)&&instrumentedSignals.Count>0
                            hasTAQBlocks=true;
                            break;
                        end
                    else


                        hasTAQBlocks=true;
                    end
                end
            end
            out=hasTAQBlocks;
        end
    end

    if isequal(aFeatureName,'StreamingProfilerAppSvc')
        out=out&&codertarget.utils.isMdlConfiguredForSoC(hCS);
    end
end
