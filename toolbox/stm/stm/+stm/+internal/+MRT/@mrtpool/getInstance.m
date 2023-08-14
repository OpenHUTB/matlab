function singleObj=getInstance(createPool)




    if~exist('createPool','var')
        createPool=true;
    end

    mlock;
    persistent localObj;
    if(isempty(localObj)||~isvalid(localObj))&&createPool
        currentRelease=stm.internal.util.getReleaseInfo();
        poolInfo=stm.internal.MRT.mrtpool.getWorkerInfo();

        poolIsGood=false;
        if(exist(poolInfo.hostMsgCatalog,'file')&&exist(poolInfo.hostReleaseFile,'file'))
            poolIsGood=true;
        end

        if(~poolIsGood)
            if(exist(poolInfo.poolRoot,'dir'))
                count=0;
                while count<10
                    pause(0.1);
                    try
                        rmdir(poolInfo.poolRoot,'s');
                        count=11;
                    catch
                        count=count+1;
                    end
                end
            end
            mkdir(poolInfo.poolRoot);

            fid=fopen(poolInfo.hostReleaseFile,'w');
            fprintf(fid,'%s\n',currentRelease);
            fclose(fid);

            if(~exist(poolInfo.hostMsgCatalog,'file'))
                stm.internal.MRT.utility.genMessageCatalog();
            end
        end
        localObj=stm.internal.MRT.mrtpool(poolInfo.poolRoot);
    end
    singleObj=localObj;
end