function[Hout,Aout,bout]=extractQuadraticCoefficientsForTimes(HLeft,HRight,ALeft,ARight,bLeft,bRight)















    zeroALeft=nnz(ALeft)<1;
    zeroHLeft=nnz(HLeft)<1;
    zeroARight=nnz(ARight)<1;
    zeroHRight=nnz(HRight)<1;











    if zeroHLeft
        if zeroHRight


            Hout=[];
        else

            Hout=Htimesb(HRight,bRight,bLeft);
        end
    elseif zeroHRight

        Hout=Htimesb(HLeft,bLeft,bRight);
    end


    if zeroALeft
        if zeroARight

            Aout=[];
        else

            Aout=ARight.*bLeft';
        end
    elseif zeroARight

        Aout=ALeft.*bRight';
    else


        if isscalar(bRight)





            Hout=ALeft(:)*ARight';
        elseif isscalar(bLeft)







            nExpr=size(ALeft,2);
            if nExpr==1

                nExpr=size(ARight,2);
            end
            Hout=kron(speye(nExpr),ALeft)*ARight';
        else





            ALMat=columns2blkdiag(ALeft);
            Hout=ALMat*ARight';
        end
        Aout=ALeft.*bRight'+ARight.*bLeft';
    end


    bout=bRight.*bLeft;

end

function Hout=Htimesb(H1,b1,b2)




    nVar=size(H1,2);
    nExpr=numel(b1);

    if nExpr==1
        nExpr=numel(b2);
    end

    if isscalar(b2)
        Hout=b2.*H1;
    elseif isscalar(b1)

        Hout=kron(b2(:),H1);
    else









        Hout=kron(spdiags(b2,0,speye(nExpr)),speye(nVar))*H1;
    end
end
