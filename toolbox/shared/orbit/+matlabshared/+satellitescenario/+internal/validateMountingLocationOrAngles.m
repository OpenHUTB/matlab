function mounting=validateMountingLocationOrAngles(mountingIn,numAssets,functionName,isInputMountingLocation)






%#codegen

    coder.allowpcode('plain');

    if isInputMountingLocation
        inputName='MountingLocation';
    else
        inputName='MountngAngles';
    end


    if coder.target('MATLAB')
        vectorOr2D='2d';
    else
        vectorOr2D='vector';
    end
    validateattributes(mountingIn,...
    {'numeric'},...
    {'nonempty','finite','real',vectorOr2D},...
    functionName,inputName);


    if isvector(mountingIn)
        validateattributes(mountingIn,...
        {'numeric'},...
        {'numel',3},...
        functionName,inputName);
        mounting=reshape(mountingIn,3,1);
    else
        validateattributes(mountingIn,...
        {'numeric'},...
        {'nrows',3},...
        functionName,inputName);
        mounting=mountingIn;
    end




    if numAssets>1&&~isvector(mounting)
        validateattributes(mounting,...
        {'numeric'},...
        {'ncols',numAssets},...
        functionName,inputName);
    end
end

