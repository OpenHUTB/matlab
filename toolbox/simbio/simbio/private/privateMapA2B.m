function out=privateMapA2B(A,B)












    out=NaN(numel(B),1);

    for i=1:numel(A)
        temp=find(strcmp(A,B{i}));
        if isempty(temp)

            error(message('SimBiology:Internal:InternalError'));
        else
            out(i)=temp;
        end
    end
end