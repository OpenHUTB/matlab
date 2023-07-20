function showDiff(h)



    try
        [cs1,~]=resolveConfigSet(h.PostCS,h.Name);
        [cs2,~]=resolveConfigSet(h.PreCS,h.Name);

        name1=message('configset:util:CurrentValue').getString;
        name2=message('configset:util:PreviousValue').getString;

        configset.internal.util.showDiff(cs1,cs2,name1,name2);
    catch e
        disp(e.message);
    end
