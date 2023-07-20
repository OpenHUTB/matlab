function idx=subArray2Ind(s,sub)





    idx=[];
    if isequal(size(s),size(sub))&&all(s>=sub)
        args=num2cell(sub);
        idx=sub2ind(s,args{:});
    elseif numel(sub)==1&&sub<=prod(s)
        idx=sub;
    end

end