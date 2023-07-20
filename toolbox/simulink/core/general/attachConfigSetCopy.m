function new_configset=attachConfigSetCopy(model,cs,allowRename)








































    narginchk(2,3);


    mode=false;

    if(nargin==3)
        if(isequal(allowRename,0))
            mode=false;
        elseif(isequal(allowRename,1))

            mode=true;
        else
            DAStudio.error('Simulink:utility:slAttachConfigSetCopyInvalidModeArg');
        end
    end

    hMdl=get_param(model,'Object');
    new_configset=hMdl.attachConfigSetCopy(cs,mode);
