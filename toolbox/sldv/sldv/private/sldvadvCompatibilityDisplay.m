function result=sldvadvCompatibilityDisplay(varargin)



    ischarstring=@(x)ischar(x)||isstring(x);
    isSldvOptionObject=@(x)isa(x,'Sldv.Options');
    p=inputParser();
    p.addRequired('system',ischarstring);
    p.addParameter('sldvOpts',[],isSldvOptionObject);

    p.parse(varargin{:});

    system=p.Results.system;
    sldvOpts=p.Results.sldvOpts;

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    if mdladvObj.parallel
        backgroundTable=ModelAdvisor.FormatTemplate('TableTemplate');
        backgroundTable.setSubResultStatus('fail');
        backgroundTable.setSubResultStatusText(getString(message(...
        'Sldv:ModelAdvisor:Runtime_Error_Detection:BackgroundExecutionUnsupported')));
        mdladvObj.setCheckErrorSeverity(2);
        mdladvObj.setCheckResultStatus(false);
        result=backgroundTable;
        return;
    end

    if mdladvObj.cmdLine
        showUI=false;
    else
        showUI=true;
    end

    [status,res]=sldvadvCompatibilityBody(system,showUI,sldvOpts);
    modelName=bdroot(system);

    try

        handles=get_param(modelName,'AutoVerifyData');
        if isfield(handles,'ui')
            handles.ui.delete;
        end
    catch
    end

    htmlFormatTemplate=ModelAdvisor.FormatTemplate('TableTemplate');
    htmlFormatTemplate.setInformation(getString(message('Sldv:ModelAdvisor:Compatibility:SetInformation',getfullname(system))));



    isPartiallyCompatible=util_parse_IncompatMsg_to_HTML(res,htmlFormatTemplate,modelName);

    if status==1&&not(isPartiallyCompatible)

        htmlFormatTemplate.setSubResultStatus('pass');
        htmlFormatTemplate.setSubResultStatusText(getString(message('Sldv:ModelAdvisor:Compatibility:ResultCompatible',getfullname(system))));
        mdladvObj.setCheckResultStatus(true);
    else


        if isPartiallyCompatible
            htmlFormatTemplate.setSubResultStatus('warn');
        else
            htmlFormatTemplate.setSubResultStatus('fail');
        end

        if isPartiallyCompatible
            htmlFormatTemplate.setTableTitle(getString(message('Sldv:ModelAdvisor:Compatibility:PartiallyCompatTableDescription')));
            htmlFormatTemplate.setSubResultStatusText(getString(message('Sldv:ModelAdvisor:Compatibility:ResultPartiallyCompatible',getfullname(system))));

            if~isempty(sldvprivate('configcomp_get',get_param(modelName,'Handle')))


                if strcmp(get_param(modelName,'DVAutomaticStubbing'),'off')

                    link2ConfigSet=sprintf('<a href="matlab:modeladvisorprivate(''openCSAndHighlight'',''%s'',''%s'')">%s</a>'...
                    ,bdroot,'DVAutomaticStubbing'...
                    ,getString(message('Sldv:dialog:sldvDVOptionAutoStub')));
                    htmlFormatTemplate.setRecAction(getString(message('Sldv:ModelAdvisor:Compatibility:OpenDVConfigParam',link2ConfigSet)))
                end
            else


                recActionStr=getString(message('Sldv:ModelAdvisor:Compatibility:OpenDVConfigParam',getString(message('Sldv:dialog:sldvDVOptionAutoStub'))));
                htmlFormatTemplate.setRecAction(recActionStr)
            end
        else

            htmlFormatTemplate.setTableTitle(getString(message('Sldv:ModelAdvisor:Compatibility:IncompatTableDescription')));
            htmlFormatTemplate.setSubResultStatusText(getString(message('Sldv:ModelAdvisor:Compatibility:ResultIncompatible',getfullname(system))));
            mdladvObj.setCheckErrorSeverity(2);
        end

        mdladvObj.setCheckResultStatus(false);
    end


    result=htmlFormatTemplate;

