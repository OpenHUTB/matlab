function enableActSrcDstInfo(model,mode,varargin)



























    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);%#ok<NASGU>
    switch mode
    case 'on'
        if~strcmp(get_param(model,'SimulationStatus'),'paused')
            if isempty(varargin)
                hBdObj=get_param(model,'Object');
                init(hBdObj,'COMMAND_LINE','UpdateBDOnly','on')
            else
                if strcmpi(varargin{1},'VariantMode')
                    hBdObj=get_param(model,'Object');
                    init(hBdObj,'RTW')
                else
                    error(['Incorrect flag supplied: ',varargin{1}]);
                end
            end
        else
            if~isempty(varargin)&&strcmp(varargin{1},'VariantMode')
                tstyle=get_param(model,'TargetStyle');
                if isempty(tstyle)...
                    ||~strcmpi(tstyle,'StandAloneTarget')
                    ME=MException('enableActSrcDstInfo:invalidmode',...
                    ['Model was not initiated for code generation. '...
                    ,'Use enableActSrcDstInfo(''%s'',''on'',''VariantMode'')'],...
                    model);
                    throw(ME);
                end
            end
        end
    case 'off'
        if strcmp(get_param(model,'SimulationStatus'),'paused')
            hBdObj=get_param(model,'Object');
            term(hBdObj)
        end
    otherwise
        error('enableActSrcDstInfo:invalidmode',...
        ['Unknown mode: ',mode])
    end
