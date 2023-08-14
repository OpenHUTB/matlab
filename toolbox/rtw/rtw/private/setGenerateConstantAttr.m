





function sharedHdrInfo=setGenerateConstantAttr(sharedutils,checkSumList)



    sharedHdrInfo.numGeneratedFiles=0;


    fileName=fullfile(sharedutils,'shared_file.dmr');
    if exist(fileName,'file')==2

        scm_db=SharedCodeManager.SharedCodeManagerInterface(fileName);
    else
        return;
    end



    sharedConstIdentities=scm_db.retrieveAllIdentities('SCM_SHARED_CONSTANTS');

    for idx=1:length(checkSumList)
        thisCheckSum=checkSumList(idx);
        cs=thisCheckSum{1};
        for idy=1:length(sharedConstIdentities)
            if((uint32(cs(1))==sharedConstIdentities{idy}.ChecksumElement1)&&...
                (uint32(cs(2))==sharedConstIdentities{idy}.ChecksumElement2)&&...
                (uint32(cs(3))==sharedConstIdentities{idy}.ChecksumElement3)&&...
                (uint32(cs(4))==sharedConstIdentities{idy}.ChecksumElement4)...
                )

                thisConstIdentity=sharedConstIdentities{idy};
                break;
            end
        end


        thisConstData=scm_db.retrieveData(thisConstIdentity);

        if(~thisConstData.GenerateConstant)
            thisConstData.GenerateConstant=true;
            scm_db.registerData(thisConstIdentity,thisConstData);
        end
    end
end


