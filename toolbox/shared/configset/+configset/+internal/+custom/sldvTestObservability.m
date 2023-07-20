function[st,dcr]=sldvTestObservability(~,~)




    dcr='not available when PathBasedTestgen feature is OFF';

    try
        if slavteng('feature','PathBasedTestgen')~=0
            st=0;
        else
            st=3;
        end
    catch
        st=3;
    end
