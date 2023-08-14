
function compile=isCompileNeeded(allPortH,modelName)





    compile=0;

    if strcmpi(get_param(modelName,'SimulationStatus'),'paused')||...
        strcmpi(get_param(modelName,'SimulationStatus'),'running')||...
        strcmpi(get_param(modelName,'SimulationStatus'),'compiled')

        return;
    end

    for inportIndex=1:length(allPortH)













        isDataTypeInherit=strcmp(get_param(allPortH(inportIndex),'OutDataTypeStr'),'Inherit: auto');
        if isDataTypeInherit

            compile=1;
            break;
        end

        portDimStr=get_param(allPortH(inportIndex),'PortDimensions');

        try
            portDimValue=eval(portDimStr);
        catch


            baseWS_Val=evalin('base',portDimStr);
            if ischar(baseWS_Val)||isstring(baseWS_Val)
                portDimValue=str2num(baseWS_Val);
            elseif isnumeric(baseWS_Val)
                portDimValue=baseWS_Val;
            else


                compile=1;
                break
            end
        end

        isDimensionInherit=portDimValue==-1;
        if isDimensionInherit

            compile=1;
            break;
        end

        if strcmp(get_param(allPortH(inportIndex),'BlockType'),'Inport')


            isSignalTypeInherit=strcmp(get_param(allPortH(inportIndex),'SignalType'),'auto');
            if isSignalTypeInherit

                compile=1;
                break;
            end












        end
    end
