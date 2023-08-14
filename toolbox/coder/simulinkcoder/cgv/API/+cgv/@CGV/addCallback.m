






















function this=addCallback(this,callback)

    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end
    if nargin~=2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end
    if~isa(callback,'function_handle')
        DAStudio.error('RTW:cgv:NotFunctionHandle');
    elseif nargin(callback)~=4
        stk=dbstack;
        DAStudio.error('RTW:cgv:CallbackNeedsNParams',stk(1).name,4,nargin(callback));
    else
        this.CallbackFcn=callback;
    end
