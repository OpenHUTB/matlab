function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)%#ok








    pathItems={};






    if blockOutportFixPtDTypeIsOnMaskDialog(blkObj,outportNum)
        sizeOutportNum=length(outportNum);
        if sizeOutportNum>0
            pathItems=cell(sizeOutportNum,1);
            for idxout=1:sizeOutportNum
                if outportNum(idxout)==1
                    pathItems{idxout}='Output';
                else

                    pathItems{idxout}=int2str(outportNum(idxout));
                end
            end
        end
    end



    function result=blockOutportFixPtDTypeIsOnMaskDialog(blkObj,outportNum)%#ok

        switch blkObj.ReferenceBlock
        case{'dspstat3/Histogram',...
            'dspstat3/Maximum',...
            'dspstat3/Minimum',...
            'dspstat3/Sort',...
            'vipobslib/2-D Histogram',...
            'vipobslib/2-D Maximum',...
            'vipobslib/2-D Minimum',...
            'vipstatistics/Histogram',...
            'viptransforms/Hough Lines',...
'visiontransforms/Hough Lines'
            }
            result=false;

        otherwise
            result=true;
        end



