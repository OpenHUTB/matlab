function out=getReferenceBlock(blockH)




    ref=get_param(blockH,'ReferenceBlock');
    if ref==""
        out=[];
    else
        out=get_param(ref,'Handle');
    end
