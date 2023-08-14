function deleteSignals(this,traceIndex)



    if~Simulink.scopes.LAScope.isLogicAnalyzerAvailable()
        return;
    end
    msg.action=['deleteSignals',this.ClientID];
    msg.params.path=this.getURL(this.ClientID);
    msg.params.method='deleteSignals';
    msg.params.signals=traceIndex;
    message.publish('/logicanalyzer',msg);
end

