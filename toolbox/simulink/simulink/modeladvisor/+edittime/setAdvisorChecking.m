
function setAdvisorChecking(model,value,studio)

    dbStackInfo=dbstack('-completenames');
    for i=2:length(dbStackInfo)
        [~,fName,~]=fileparts(dbStackInfo(i).file);
        if strcmp(fName,'setAdvisorChecking')
            return;
        end
    end

    if ishandle(model)
        model=get_param(model,'Name');
    end
    p=inputParser;
    addRequired(p,'model',@(x)validateattributes(x,{'char','string'},...
    {'nonempty'}));
    addRequired(p,'value',@(x)validateattributes(x,{'char','string'},...
    {'nonempty'}));
    p.parse(model,value);

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if nargin>2
        isInCodePerspective=cp.isInPerspective(studio);
    else
        isInCodePerspective=cp.isInPerspective(model);
    end

    editControl=edittimecheck.EditTimeEngine.getInstance();

    settingFlag=strcmpi(value,'on');
    Simulink.DDUX.logData('ET','etonoff',settingFlag);


    cs=getActiveConfigSet(model);
    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet;
    end
    if~cs.isValidParam('ShowAdvisorChecksEditTime')

        if strcmp(get_param(model,'Lock'),'on')
            set_param(model,'Lock','off');
        end
        maconfigset=ModelAdvisor.ConfigsetCC;
        cs.attachComponent(maconfigset);
    end

    if settingFlag
        if~license('checkout','sl_verification_validation')
            return;
        end
        set_param(model,'ShowAdvisorChecksEditTime','on');

        editControl.loadCheckModule(model);
        if isInCodePerspective
            editControl.switchConfiguration(model,edittimecheck.config.Type.CODE_GENERATION);
        else
            editControl.enableMA(model);
        end
        edittime.EditTimeCheckingSetup.systemcomposersetup(model);
    else


        if(strcmpi(get_param(model,'ShowEditTimeAdvisorChecks'),'on'))
            set_param(model,'ShowEditTimeAdvisorChecks','off');
        end
        cs.set_param('ShowAdvisorChecksEditTime','off');
        editControl.disableMA(model);
    end

    root=sfroot;
    machine=root.find('-isa','Stateflow.Machine','Name',model);
    if~isempty(machine)
        sf('SetMALintStatus',settingFlag,machine.Id);
    end
end

