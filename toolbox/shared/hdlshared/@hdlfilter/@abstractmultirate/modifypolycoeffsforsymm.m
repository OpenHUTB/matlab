function[mod_polycoeffs,indx_symm]=modifypolycoeffsforsymm(this,polycoeffs)






    mod_polycoeffs=polycoeffs;
    indx_symm=zeros(size(polycoeffs));

    for row=1:size(polycoeffs,1)
        phasecoeffs=polycoeffs(row,:);
        phasecoeffs=abs(phasecoeffs);
        uniqcoeffs=unique(phasecoeffs);
        if length(uniqcoeffs)<length(phasecoeffs)
            num_uniqs=1;
            for col=1:length(uniqcoeffs);
                indx1=find(phasecoeffs==uniqcoeffs(col));
                if length(indx1)>1&&uniqcoeffs(col)~=0
                    mod_polycoeffs(row,indx1(2:end))=0;
                    asymmindx=indx1(find((polycoeffs(row,indx1)+polycoeffs(row,indx1(1)))==0));
                    symmindx=setdiff(indx1,asymmindx);
                    if~isempty(asymmindx)
                        indx_symm(row,asymmindx)=num_uniqs*-1;
                    end
                    if~isempty(symmindx)
                        indx_symm(row,symmindx)=num_uniqs;
                    end
                    num_uniqs=num_uniqs+1;
                end
            end
        end
    end


