function checkUnsupportedSystem(sysH,varargin)





    if nargin==1
        nonCompileCheck=false;
    elseif nargin>1
        nonCompileCheck=varargin{1};
    end

    blockType=get_param(sysH,'BlockType');
    if~strcmp(blockType,'SubSystem')
        error('Sldv:SubsystemLogger:UnsportedBlockType',...
        getString(message('Sldv:SubsystemLogger:SpecifiedBlockHas',blockType)));
    end


    ssType=Simulink.SubsystemType(sysH);
    if~(ssType.isAtomicSubsystem...
        ||ssType.isEnabledSubsystem...
        ||ssType.isEnabledAndTriggeredSubsystem...
        ||ssType.isTriggeredSubsystem)
        error('Sldv:SubsystemLogger:UnspportedSubsystemType',...
        getString(message('Sldv:SubsystemLogger:SubsystemIs'...
        ,getfullname(sysH),ssType.getType)));
    end

    if nonCompileCheck

        return;
    end

    model=get_param(bdroot(sysH),'Name');

    try
        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>


        compiledHere=false;
        if strcmp(get_param(model,'SimulationStatus'),'stopped')
            str=evalc('feval(model,''init'');');%#ok<NASGU>
            compiledHere=true;
        end


        ts=get_param(sysH,'CompiledSampleTime');
        if iscell(ts)
            if length(ts)>=3
                error('Sldv:SubsystemLogger:MultiRateNotSupported',...
                getString(message('Sldv:SubsystemLogger:MultiRateNotSupported',...
                getfullname(sysH))));
            end
            SampleTime=ts{1}(1);
        else
            SampleTime=ts;
        end
        if SampleTime(1)==0
            error('Sldv:SubsystemLogger:ContinuousSampleTimeNotSupported',...
            getString(message('Sldv:SubsystemLogger:SubsystemHasA',...
            getfullname(sysH))));
        elseif isinf(SampleTime(1))
            error('Sldv:SubsystemLogger:InfSampleTimeNotSupported',...
            getString(message('Sldv:SubsystemLogger:SubsystemHasInf',...
            getfullname(sysH))));
        end

        if SampleTime(1)==-1
            error('Sldv:SubsystemLogger:NotSupported',...
            getString(message('Sldv:SubsystemLogger:InheritNotSupported',...
            getfullname(sysH))));
        end


        arrayOfBussesMsg=Sldv.utils.containsArrayOfBuses(sysH);
        if~isempty(arrayOfBussesMsg)
            error('Sldv:SubsystemLogger:ArrayOfBusNotSupported',...
            getString(message('Sldv:SubsystemLogger:ArrayOfBusesIs')));
        end

        if compiledHere
            feval(model,'term')
        end
    catch ex
        if compiledHere
            feval(model,'term')
        end
        throw(ex)
    end
end
