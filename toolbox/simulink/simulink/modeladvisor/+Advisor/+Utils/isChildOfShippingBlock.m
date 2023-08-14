function bResult=isChildOfShippingBlock(handle)
    bResult=false;

    linkStatus=get_param(handle,'LinkStatus');
    if strcmp(linkStatus,'implicit')
        referenceBlock=get_param(handle,'ReferenceBlock');
        libraryName=strtok(referenceBlock,'/');
        if strcmp(libraryName,'simulink')||strcmp(libraryName,'sflib')||strcmp(libraryName,'hdlsllib')
            bResult=true;
        end
    end

end