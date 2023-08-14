function instantiateLinkedBlock(mySys)




    if~isempty(mySys)
        try
            find_system(mySys,'SearchDepth',0);

        catch
            rptgen_sl.instantiateLinkedBlock(findParentSys(mySys));





        end
    end



    function parentSys=findParentSys(mySys)

        charIdx=length(mySys);
        slashCount=0;
        firstSlashIdx=[];
        while charIdx>1
            if mySys(charIdx)=='/';
                if slashCount==0
                    firstSlashIdx=charIdx;
                end
                slashCount=slashCount+1;
            else
                if slashCount>0

                    if rem(slashCount,2)==0

                        slashCount=0;
                    else
                        parentSys=mySys(1:firstSlashIdx-1);
                        return;
                    end
                end
            end
            charIdx=charIdx-1;
        end

        parentSys='';













