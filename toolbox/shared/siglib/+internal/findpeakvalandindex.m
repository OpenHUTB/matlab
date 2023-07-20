function[max_val,max_index]=findpeakvalandindex(data,tol)



%#codegen
    coder.allowpcode('plain')
    [temp_max_val,temp_max_index]=max(data);

    if abs(temp_max_val-min(data))<0.1||isnan(abs(temp_max_val-min(data)))
        max_val=temp_max_val;
        max_index=temp_max_index;
        return;
    end
    tol=min([min(abs(diff(data))),tol]);
    data_ed=abs(data-temp_max_val);
    max_index=find(data_ed<=tol);
    max_val=data(max_index);
end