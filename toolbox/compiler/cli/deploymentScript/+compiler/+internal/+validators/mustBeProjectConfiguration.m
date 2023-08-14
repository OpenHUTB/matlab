function mustBeProjectConfiguration(data)
    if~compiler.internal.validators.isProjectConfiguration(data)
        eidType='mustBeProjectConfiguration:notProjectConfiguration';
        msgType='Input must be a valid Project Configuration';
        throwAsCaller(MException(eidType,msgType))
    end
end