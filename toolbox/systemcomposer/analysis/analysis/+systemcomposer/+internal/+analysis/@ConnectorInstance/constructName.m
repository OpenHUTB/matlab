function constructName(this)



    sourceName=[this.connectorEnds(1).parent.getName,':',this.connectorEnds(1).getName];
    destName=[this.connectorEnds(2).parent.getName,':',this.connectorEnds(2).getName];
    this.setName([sourceName,'->',destName]);
end

