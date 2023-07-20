function[Aout,bout]=extractLinearCoefficientsForSubsasgn(Aout,bout,Aright,bRight,linIdx,nVar)














    if~isempty(linIdx)
        if isempty(Aout)
            Aout=sparse(nVar,numel(bout));
        end

        if nnz(Aright)==0
            Aright=0;
        elseif size(Aright,2)==1&&~isscalar(linIdx)
            Aright=repmat(Aright,1,numel(linIdx));
        end

        Aout(:,linIdx)=Aright;
        bout(linIdx)=bRight(:);
        bout=bout(:);
    end
end
