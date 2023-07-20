function flag=isMatchingBlock(this,blkh)%#ok<INUSL>



    flag=false;

    archImpl_TargetLanguage=hdlget_param(getfullname(blkh),'TargetLanguage');


    flag=strcmpi(archImpl_TargetLanguage,hdlgetparameter('target_language'));

    return
end
