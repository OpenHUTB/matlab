



function handle=getBlockHandle(block)

    len=length(block);
    if len==1||ischar(block)

        if iscell(block)
            block=block{1};
        end

        if isa(block,'Simulink.BlockPath')
            block=block.getBlock(block.getLength);
        end
        handle=get_param(block,'Handle');
    else

        handle=zeros(1,len);
        if iscell(block)
            for i=1:len
                handle(1,i)=sltrace.utils.getBlockHandle(block{i});
            end
        else
            for i=1:len
                handle(1,i)=sltrace.utils.getBlockHandle(block(i));
            end
        end
    end
end