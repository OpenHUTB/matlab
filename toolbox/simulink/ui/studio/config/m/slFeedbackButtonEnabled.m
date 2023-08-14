function on=slFeedbackButtonEnabled(value)
    persistent realOn;
    if isempty(realOn)
        realOn=true;
    end
    on=realOn;
    if nargin==1&&islogical(value)&&length(value)==1
        realOn=value;
    end
end