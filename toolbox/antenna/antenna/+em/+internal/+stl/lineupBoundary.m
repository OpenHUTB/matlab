function b=lineupBoundary(fe)

    if size(unique(fe(:,1)),1)==size(unique(fe),1)
        b=fe(:,1);
        return;
    end
    b=ones(size(unique(fe),1),1);
    b(1)=fe(1,1);b(2)=fe(1,2);
    for i=2:size(fe,1)-1
        idx=fe(:,1)==b(i);
        if any(idx)
            if sum(idx)==2
                idxpt=fe(idx,2);
                [~,idxp]=setdiff(idxpt,b);
                b(i+1)=idxpt(idxp(1));
            elseif sum(idx)>2
                error('error');
            else
                b(i+1)=fe(idx,2);
            end

        else
            idx=fe(:,2)==b(i);

            if any(idx)
                if sum(idx)==2
                    idxpt=fe(idx,1);
                    [~,idxp]=setdiff(idxpt,b);
                    b(i+1)=idxpt(idxp(1));
                elseif sum(idx)>2
                    error('error');
                else
                    b(i+1)=fe(idx,1);
                end
            end
        end
    end
end