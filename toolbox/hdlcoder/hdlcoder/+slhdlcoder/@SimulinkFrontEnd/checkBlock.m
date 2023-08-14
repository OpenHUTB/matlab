function checkBlock(this,blockOrBlockHandle)





    if isa(blockOrBlockHandle,'double')
        block=get_param(blockOrBlockHandle,'Object');
    else
        block=blockOrBlockHandle;
    end

    if~isprop(block,'BlockType')
        return;
    end



    portHandles=block.PortHandles;
    if~isempty(portHandles.State)
        msgobj=message('hdlcoder:engine:StatePort',block.Path);
        this.updateChecks(block.Path,'block',msgobj,'Error');
    end

    switch block.BlockType
    case 'SubSystem'

        if strcmp(block.PropExecContextOutsideSubsystem,'on')
            msgobj=message('hdlcoder:engine:executeContext',block.Path);
            this.updateChecks(block.Path,'block',msgobj,'Error');
        end


        if minAlgebraicLoopOccurences(block)
            msgobj=message('hdlcoder:engine:MinAlgLoops',block.Path);
            this.updateChecks(block.Path,'block',msgobj,'Error');
            error(msgobj);
        end


        if~isempty(strfind(block.DataTypeOverride,'Double'))||...
            ~isempty(strfind(block.DataTypeOverride,'Single'))
            msgobj=message('hdlcoder:validate:DTOonSubsystem',block.Path);
            this.updateChecks(block.Path,'block',msgobj,'Error');
        end
    otherwise

    end


    function flag=minAlgebraicLoopOccurences(block)


        flag=false;
        if strcmp(hdlfeature('CheckMinAlgLoopOccurrences'),'off')
            return;
        end

        if strcmpi(block.MinAlgLoopOccurrences,'on')
            atomic=strcmpi(block.TreatAsAtomicUnit,'on');
            if atomic
                flag=true;
            else
                enbblk=find_system(block.getFullName,'SearchDepth',1,'BlockType','EnablePort');
                trgblk=find_system(block.getFullName,'SearchDepth',1,'BlockType','TriggerPort');
                rstblk=find_system(block.getFullName,'SearchDepth',1,'BlockType','ResetPort');
                if~isempty([enbblk;trgblk;rstblk])
                    flag=true;
                end
            end
        end
    end
end





