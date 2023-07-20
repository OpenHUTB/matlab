function tf=eq(asset1,asset2)





    asset1Handles=[asset1.Handles{:}];


    if isa(asset2,'matlabshared.satellitescenario.internal.ObjectArray')
        asset2Handles=[asset2.Handles{:}];
    else
        asset2Handles=asset2;
    end


    tf=isequal(asset1Handles,asset2Handles);
end

