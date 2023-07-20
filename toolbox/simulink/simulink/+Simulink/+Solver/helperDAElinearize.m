function[status,mLinJacobian,DirectFeedthrough,other]=helperDAElinearize(in,blkh)








    n_cstate=in(1).NRow;

    tM=Simulink.Solver.hDAESparseToFull(in(1),n_cstate,n_cstate);
    tA=hDAESparseToMatlabSparse(in(2));
    tB=hDAESparseToMatlabSparse(in(3));
    tC=hDAESparseToMatlabSparse(in(4));
    tD=hDAESparseToMatlabSparse(in(5));

    clear in



    isLincompile=get_param(bdroot,'AnalyticLinearization');
    blkSetting=get_param(blkh,'SCDEnableBlockLinearizationSpecification');
    blks=get_param(bdroot,'SCDLinearizationBlocksToRemove');
    customJacobian=false;
    if strcmp(isLincompile,'on')
        if strcmp(blkSetting,'on')
            customJacobian=true;
        else
            for i=1:length(blks)
                if get_param(blks{i},'Handle')==blkh
                    customJacobian=true;
                    break;
                end
            end
        end
    end

    if customJacobian

        status=1;


        if(nnz(tD)~=0)
            DirectFeedthrough=1;
        else
            DirectFeedthrough=0;
        end

        other.Wad=sparse(0);
        other.Wau=sparse(0);
        other.Txw=sparse(0);
        other.Twx=sparse(0);
        mLinJacobian=[tA,tB;tC,tD];
    else
        [status,mLinJacobian,DirectFeedthrough,other]=Simulink.Solver.helperDAElinearize_math(tM,tA,tB,tC,tD);
    end

end



function matSparse=hDAESparseToMatlabSparse(s)
    mIr=zeros(length(s.Pr),1);
    mJc=zeros(length(s.Pr),1);
    mPr=s.Pr;
    cnt=1;
    for i=1:length(s.Ir)-1
        for jidx=s.Ir(i):1:s.Ir(i+1)-1
            mIr(cnt)=i;
            mJc(cnt)=s.Jc(jidx+1)+1;
            cnt=cnt+1;
        end
    end
    matSparse=sparse(mIr,mJc,mPr,s.NRow,s.NCol);
end























