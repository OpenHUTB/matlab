function TF=isViewer3DSupported()








    info=rendererinfo;

    if~isempty(info)&&isfield(info,'Details')

        if info.Details.HardwareSupportLevel=="Full"

            TF=true;

        else

            if ispc()
                TF=false;
            else
                TF=true;
            end

        end

    else
        TF=false;
    end

end