function setLegacyAttenation(obj)







    strValue='';
    if~strcmp(obj.wintypeSpecScopeLocal,'unset')&&~strcmp(obj.betaSpecScopeLocal,'unset')&&~strcmp(obj.RsSpecScopeLocal,'unset')
        if strcmpi(obj.wintypeSpecScopeLocal,'Kaiser')
            strValue=obj.betaSpecScopeLocal;
        elseif strcmpi(obj.wintypeSpecScopeLocal,'Chebyshev')
            strValue=obj.RsSpecScopeLocal;
        end
        if~isempty(strValue)





            [value,variableUndefined]=evaluateString(obj,strValue,'SidelobeAttenuation');
            if~variableUndefined
                if value<45
                    strValue='45';
                end
            end
            obj.SidelobeAttenuation=strValue;
        end
    end
end
