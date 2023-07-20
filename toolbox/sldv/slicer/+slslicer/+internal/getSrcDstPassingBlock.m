function[srcp,dstp]=getSrcDstPassingBlock(srcP,dstP,blk)




    allbdroot=unique([bdroot(blk),bdroot(srcP)',bdroot(dstP)']);

    allindex=arrayfun(@(x)~strcmp(get_param(x,'SimulationStatus'),'stopped'),allbdroot);


    assert(all(allindex));

    utils=SystemsEngineering.SEUtil;
    srcp=[];
    dstp=[];
    for sindex=1:length(srcP)
        tempsrc=srcP(sindex);
        if ishandle(tempsrc)
            for dindex=1:length(dstP)

                tempdst=dstP(dindex);
                if ishandle(tempdst)
                    [handles,vBlks,gSrc,gDst]=utils.getAllSegmentsInPath(tempsrc,tempdst);%#ok<ASGLU>
                    if ismember(blk,vBlks)
                        srcp(end+1)=tempsrc;%#ok<AGROW>
                        dstp(end+1)=tempdst;%#ok<AGROW>
                    end
                else

                    Mex=MException('ModelSlicer:Internal:NoDestForVirtual',...
                    getString(message('Sldv:ModelSlicer:Analysis:NoDestOrSrcForVirtual')));
                    modelslicerprivate('MessageHandler','error',Mex);
                end
            end
        else

            Mex=MException('ModelSlicer:Internal:NoSrcForVirtual',...
            getString(message('Sldv:ModelSlicer:Analysis:NoDestOrSrcForVirtual')));
            modelslicerprivate('MessageHandler','error',Mex);

        end

    end
end