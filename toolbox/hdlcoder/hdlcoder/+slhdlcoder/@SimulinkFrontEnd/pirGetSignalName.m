function[sigName,preserve]=pirGetSignalName(slbh,oportHandle)






    blkType=get_param(slbh,'BlockType');
    blkName=get_param(slbh,'Name');

    preserve=false;
    if strcmp(blkType,'Inport')

        sigName=get_param(oportHandle,'Name');
        if isempty(sigName)
            sigName=blkName;
        end
    elseif strcmp(blkType,'TriggerPort')||...
        strcmp(blkType,'ResetPort')
        sigName=blkName;
    elseif strcmp(blkType,'SimscapeBlock')
        sigName=blkName;
        preserve=true;
    else

        sigName=get_param(oportHandle,'Name');
        if isempty(sigName)
            sigName=get(get_param(oportHandle,'Object'),'CompiledRTWSignalIdentifier');
        end

        if~isempty(sigName)

            preserve=true;
        else
            ln=get_param(oportHandle,'Line');
            if~isempty(ln)
                if ln>0
                    sigName=get_param(ln,'Name');
                end
            end
            if isempty(sigName)
                oportName=get_param(oportHandle,'Name');

                if isempty(oportName)
                    portNum=get_param(oportHandle,'PortNumber');
                    oportName=['out',int2str(portNum)];
                end

                sigName=[blkName,'_',oportName];
            end
        end
    end

    if isequal(get_param(oportHandle,'TestPoint'),'on')
        preserve=true;
    end
