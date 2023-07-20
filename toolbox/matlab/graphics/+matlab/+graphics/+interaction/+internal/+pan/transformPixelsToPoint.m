function trans_point=transformPixelsToPoint(t,orig_pt)

    if isequal(t(4,:),[0,0,0,1])

        trans_pt=[(t\[orig_pt,0,1]')';...
        (t\[orig_pt,1,1]')'];
    else

        trans_pt=[(t\[orig_pt*10,1,10]')';...
        (t\[orig_pt,1,1]')'];
    end

    trans_point=trans_pt(:,1:3);

