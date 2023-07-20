function[vp,totalMatrix]=combineTransforms(hCamera,aboveMatrix,hDataSpace,belowMatrix)










    I=eye(4);


    if isempty(hDataSpace)
        totalMatrix=I;
    else
        totalMatrix=hDataSpace.getMatrix;
    end

    if~isempty(aboveMatrix)&&~isequal(aboveMatrix,I)
        totalMatrix=aboveMatrix*totalMatrix;
    end

    vp=[0,0,1,1];
    if~isempty(hCamera)
        viewMatrix=hCamera.GetViewMatrix;
        if~isequal(viewMatrix,I)
            totalMatrix=viewMatrix*totalMatrix;
        end

        projectionMatrix=hCamera.GetProjectionMatrix;
        if~isequal(projectionMatrix,I)
            totalMatrix=projectionMatrix*totalMatrix;
        end

        vp=getCameraViewport(hCamera);
    end


    if~isempty(belowMatrix)&&~isequal(belowMatrix,I)...
        &&(isempty(hDataSpace)||strcmp(hDataSpace.isLinear,'on'))



        totalMatrix=totalMatrix*belowMatrix;
    end

    function pos=getCameraViewport(cam)
        vp=cam.Viewport;
        pos=vp.RenderingPosition;
