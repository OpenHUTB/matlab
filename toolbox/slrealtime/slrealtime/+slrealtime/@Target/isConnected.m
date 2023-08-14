function connected=isConnected(this)












    connected=~startsWith(this.stateChartGetActiveState(),'Status.Disconnected');

end
