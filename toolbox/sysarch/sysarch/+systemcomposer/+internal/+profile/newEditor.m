function state=newEditor(inState)




    persistent isEnabledNewEditor;
    if nargin==1&&inState
        isEnabledNewEditor=1;
    elseif nargin==1
        isEnabledNewEditor=0;
    end
    state=isEnabledNewEditor;
end

