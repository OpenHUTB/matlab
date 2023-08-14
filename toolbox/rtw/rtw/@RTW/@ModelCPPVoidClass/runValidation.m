function[status,msg]=runValidation(hSrc,varargin)
















    MSLDiagnostic('RTW:fcnClass:voidclassdeprecation').reportAsWarning;
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    status=1;
    msg='';

    if nargin==2
        callMode=varargin{1};
    else
        callMode='interactive';
    end

    hModel=hSrc.ModelHandle;
    if~ishandle(hModel)
        status=0;
        msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
        return;
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                status=0;
                msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
                return;
            end
        catch me
            status=0;
            msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
            return;
        end
    end

    fullname=getfullname(hModel);

    simStatus=get_param(hModel,'SimulationStatus');

    compileObj=coder.internal.CompileModel;

    if hSrc.needsCompilation()&&...
        ~strcmpi(simStatus,'paused')&&~strcmpi(simStatus,'initializing')&&...
        ~strcmpi(simStatus,'running')
        try
            if strcmpi(get_param(hModel,'SimulationMode'),'accelerator')
                DAStudio.error('RTW:fcnClass:accelSimForbiddenForCPP')
            end
            lastwarn('');

            compileObj.compile(hModel);

            if~isempty(lastwarn)
                disp([DAStudio.message('RTW:fcnClass:fcnProtoCtlWarn'),lastwarn]);
            end
        catch me
            status=0;
            msg=DAStudio.message('RTW:fcnClass:modelNotCompile',me.message);
            return;
        end
    end

    try
        configData=hSrc.syncWithModel();
        [status,msg]=hSrc.supValidation();

        if(~status)

            DAStudio.error('RTW:fcnClass:finish',msg);
        end


        if(strcmpi(callMode,'interactive')||strcmpi(callMode,'init'))
            for i=1:length(configData)
                if isscalar(configData)
                    entry=configData;
                else
                    entry=configData(i);
                end

                if~strcmp(entry.Category,'None')
                    msg=DAStudio.message('RTW:fcnClass:voidClassHasArgs',...
                    entry.SLObjectName);
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end
        end


        if(strcmpi(callMode,'interactive')||strcmpi(callMode,'finalValidation'))
            outBlks=find_system(hModel,'SearchDepth',1,'BlockType','Outport');

            for i=1:length(configData)
                if isscalar(configData)
                    entry=configData;
                else
                    entry=configData(i);
                end

                if~strcmp(get_param(hModel,'GenerateExternalIOAccessMethods'),'None')&&...
                    ~strcmp(callMode,'interactive')
                    normalizedName=entry.SLObjectName;
                    normalizedName=regexprep(normalizedName,'[^a-zA-Z0-9_]','_');
                    entry.NormalizedPortName=normalizedName;
                end
            end
        end

        hSrc.Data=configData;
    catch me %#ok
        status=0;
    end
    delete(sess);

