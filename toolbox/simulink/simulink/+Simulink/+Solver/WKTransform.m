function[status,directFeedthrough,nilpotencyIndex,other]=WKTransform(in)




    M=Simulink.Solver.hDAESparseToFull(in(1),in(1).NRow,in(1).NCol);
    A=Simulink.Solver.hDAESparseToFull(in(2),in(2).NRow,in(2).NCol);
    B=hDAESparseToMatlabSparse(in(3));
    C=hDAESparseToMatlabSparse(in(4));
    D=hDAESparseToMatlabSparse(in(5));


    [status,directFeedthrough,nilpotencyIndex,other]=Simulink.Solver.helperDAEWK(M,A,B,C,D);


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
end