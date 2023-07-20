function[st,dcr]=sldvTestGeneratedCodeTestGen(~,~)




    dcr='not available when GeneratedCodeTestGen feature is OFF';

    try
        if sldv.code.internal.isXilFeatureEnabled()
            st=0;
            return
        end
    catch
    end

    st=3;
