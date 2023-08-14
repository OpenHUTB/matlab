function[cs,csr]=getConfigSetObject(csOrMdl)




    cs=[];

    if isempty(csOrMdl)
        return;
    end

    if isa(csOrMdl,'Simulink.ConfigSet')||isa(csOrMdl,'Simulink.ConfigSetRef')
        cs=csOrMdl;
    else
        try
            cs=getActiveConfigSet(csOrMdl);
        catch
            if ishandle(csOrMdl)
                error(message('Simulink:dialog:NoModelWithHandle',num2str(csOrMdl)));
            elseif ischar(csOrMdl)
                error(message('Simulink:dialog:ModelNotFound',csOrMdl));
            else
                error(message('Simulink:dialog:FirstInpArgMustBeValidModel','Simulink.ConfigSet'));
            end
        end
    end

    if isa(cs,'Simulink.ConfigSetRef')
        csr=cs;



        cs=configset.util.getSource(csr);

    else
        csr=[];


        cs=cs.getConfigSetSource;
    end

end

