function varargout=setTextStepImpl(~,newValue)

    if newValue<0
        error(message('MATLAB:contour:DataMustBeNonNegative','TextStep'));
    end
    varargout{1}=newValue;
end
