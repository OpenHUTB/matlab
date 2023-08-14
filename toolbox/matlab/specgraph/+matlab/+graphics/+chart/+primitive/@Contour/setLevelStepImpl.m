function varargout=setLevelStepImpl(~,newValue)

    if newValue<0||~isfinite(newValue)
        error(message('MATLAB:contour:DataMustBeNonNegative','LevelStep'));
    end
    varargout{1}=newValue;
end
