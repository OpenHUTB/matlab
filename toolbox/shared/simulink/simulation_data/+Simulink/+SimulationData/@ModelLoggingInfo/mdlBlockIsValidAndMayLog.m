function bRet=mdlBlockIsValidAndMayLog(~,block)







    try
        bType=get_param(block,'BlockType');
        if~strcmpi(bType,'ModelReference')
            DAStudio.error(...
            'Simulink:Logging:MdlLogInfoGetInstanceBlkType',...
            block,...
            bType);
        end
    catch me
        warning(me.identifier,me.message);
        bRet=false;
        return;
    end


    bRet=~strcmpi(get_param(block,'ProtectedModel'),'on');

end
