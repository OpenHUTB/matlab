function[st,dcr]=sldvRebuildModelRepresentation(~,~)




    dcr='not available when Rebuild Model Representation is disabled';

    try
        if slavteng('feature','ReuseTranslation')
            st=0;
            return
        end
    catch
    end

    st=3;