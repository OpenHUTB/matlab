function ref=getRootOfReferenceBlock(blockH)



    ref='';
    while(1)
        [otherBlockH,isLink]=local_is_link(blockH);
        if strcmp(blockH,otherBlockH)

            ref='';
            break
        end
        if~isLink
            break
        end
        blockH=otherBlockH;
        ref=blockH;
    end

    function[ref,isLink]=local_is_link(blockH)

        if ischar(blockH)


            blockH=getSimulinkBlockHandle(blockH,true);
        end
        if(blockH)>0
            ref=get_param(blockH,'ReferenceBlock');
        else
            ref='';
        end
        isLink=~isempty(ref);
