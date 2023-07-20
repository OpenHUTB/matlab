function STAWebScopeMessageHandler=initializeStaWebScope






    STAWebScopeMessageHandler=matlabshared.scopes.WebScopeMessageHandler;
    clientID='editor';
    STAWebScopeMessageHandler.ClientId='editor';
    uniqueClientID=matlabshared.scopes.WebScope.addClientInfo('webscope_default_clientInfo',clientID);
    STAWebScopeMessageHandler.updateClientId(uniqueClientID);

    matlabshared.scopes.WebScope.addMessageHandler('webscope_default_MsgHandler',uniqueClientID);

    matlabshared.scopes.WebScope.setClientID(uniqueClientID);
    builtin('registerSTAWebScopeMessageHandler',uniqueClientID);
    matlabshared.scopes.WebScope.startConsumingData();

end