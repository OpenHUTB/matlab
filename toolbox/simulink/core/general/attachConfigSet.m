function attachConfigSet(model,cs,allowRename)









































    narginchk(2,3);


    mode=false;

    if(nargin==3)
        if(isequal(allowRename,0))
            mode=false;
        elseif(isequal(allowRename,1))

            mode=true;
        else
            DAStudio.error('Simulink:utility:slAttachConfigSetInvalidModeArg');
        end
    end

    hMdl=get_param(model,'Object');
    hMdl.attachConfigSet(cs,mode);
