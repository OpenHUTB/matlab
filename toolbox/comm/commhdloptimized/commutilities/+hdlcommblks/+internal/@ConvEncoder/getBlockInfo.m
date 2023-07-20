function blockInfo=getBlockInfo(~,hC)


















    bfp=hC.Simulinkhandle;

    str_trellis=get_param(bfp,'trellis');
    blockInfo.Comment=str_trellis;
    blockInfo.opMode=get_param(bfp,'opMode');


    blockInfo.hasResetPort=~isempty(strfind(blockInfo.opMode,'Reset on nonzero'));
    blockInfo.DelayedResetAction=strcmpi(get_param(bfp,'DelayedResetAction'),'on');


    blockInfo.hasFSt=strcmpi(get_param(bfp,'HasFinStPort'),'on');



    for valididx=1:length(str_trellis)
        if(str_trellis(valididx)~=' '),break;end
    end

    if(strncmpi(str_trellis(valididx:end),'poly2trellis',12))

        remain=str_trellis(valididx+12:end);
        stidx=strfind(remain,'(');
        endidx=strfind(remain,')');

        tmp=['{',remain(stidx+1:endidx-1),'}'];

        info=slResolve(tmp,bfp);

        fieldnum=length(info);
        if(fieldnum>=2)

            isSupportedTrellis=true;
            blockInfo.clength=info{1};
            blockInfo.gmatrix=info{2};
            if(fieldnum==3)

                fbmatrix=info{3};
            else
                fbmatrix=[];
            end
            blockInfo.fbmatrix=fbmatrix;

            [k,n]=size(blockInfo.gmatrix);
            blockInfo.k=k;
            blockInfo.n=n;

        else
            isSupportedTrellis=false;
        end
    else
        isSupportedTrellis=false;
    end

    blockInfo.isSupportedTrellis=isSupportedTrellis;

end

