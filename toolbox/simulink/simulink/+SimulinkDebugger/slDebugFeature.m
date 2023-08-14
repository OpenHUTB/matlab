
function ret=slDebugFeature(val)
    if isequal(nargin,0)
        ret=slfeature('slDebuggerSimStepperIntegration');
    else
        ret=slfeature('slDebuggerSimStepperIntegration',val);
        c=dig.Configuration.get();c.reload;
    end
end