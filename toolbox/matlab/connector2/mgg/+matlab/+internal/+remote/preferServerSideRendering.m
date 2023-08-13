function preferServerSideRendering(value)

    if(nargin<1)
        value=true;
    end


    if strcmp(mls.internal.feature('graphicsAndGuis'),'off')
        return;
    end

    isWebGraphicsOn=strcmp(mls.internal.feature('webGraphics'),'on');
    if(value&&isWebGraphicsOn)

        setenv('capabilities_avoidWebGraphics','true');

        mls.internal.feature('webGraphics','off');
    else


        setenv('capabilities_avoidWebGraphics','false');
        mls.internal.feature('webGraphics','on');
    end
end
