function[reuse_ss,checksumStr,hChildNetwork]=isHandledReusableSS(this,blockPath)



    reuse_ss=false;
    hChildNetwork=[];
    checksumStr='';


    if this.CheckSumInfo.isKey(blockPath)

        checksumStr=this.CheckSumInfo(blockPath);


        foundNtwk=this.CheckSumNtwkMap.isKey(checksumStr);
        if foundNtwk
            reuse_ss=true;
            hChildNetwork=this.CheckSumNtwkMap(checksumStr);
        end
    end

end
