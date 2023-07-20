function enumList=getEnumerationsFromLinkedDictionary(~,archName)
    enumList={};

    try
        bdH=get_param(archName,'handle');
        ddName=get_param(bdH,'DataDictionary');

        if(isempty(ddName))
            return
        end

        ddConn=Simulink.data.dictionary.open(ddName);
        enumList=systemcomposer.getEnumerationsFromDictionary(ddConn);
        ddConn.close();
    catch
    end
end
