classdef AuthManager<handle

    methods(Static)

        function obj=AuthManager()
            settingsTree=settings;
            if(~settingsTree.hasGroup('sim3dgeospatial'))
                settingsTree.addGroup('sim3dgeospatial','hidden',true);
                if(~settingsTree.sim3dgeospatial.hasGroup('accesstokens'))
                    settingsTree.sim3dgeospatial.addGroup('accesstokens','hidden',true);
                end
            end
        end


        function tokenVal=getTokenValue(tokenID)
            tokenVal="";
            settingsTree=settings;
            accessTokens=settingsTree.sim3dgeospatial.accesstokens;
            if(accessTokens.hasSetting(tokenID))
                tokenVal=accessTokens.(tokenID).ActiveValue;
            end
        end


        function addToken(tokenID,tokenVal)
            settingsTree=settings;
            accessTokens=settingsTree.sim3dgeospatial.accesstokens;
            accessTokens.addSetting(tokenID);
            accessTokens.(tokenID).PersonalValue=tokenVal;
        end


        function updateToken(tokenID,tokenVal)
            settingsTree=settings;
            accessTokens=settingsTree.sim3dgeospatial.accesstokens;
            if(~accessTokens.hasSetting(tokenID))
                sim3d.geospatial.AuthManager.addToken(tokenID,tokenVal);
            else
                accessTokens.(tokenID).PersonalValue=tokenVal;
            end
        end


        function removeToken(tokenID)
            settingsTree=settings;
            accessTokens=settingsTree.sim3dgeospatial.accesstokens;
            if(accessTokens.hasSetting(tokenID))
                accessTokens.removeSetting(tokenID);
            end
        end


        function tokenList=getAvailableTokenIDs()
            settingsTree=settings;
            accessTokens=settingsTree.sim3dgeospatial.accesstokens;
            tokenList=properties(accessTokens);
        end
    end
end

