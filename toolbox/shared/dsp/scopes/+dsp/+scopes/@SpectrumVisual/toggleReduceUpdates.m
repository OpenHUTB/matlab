function toggleReduceUpdates(this)




    val=getPropertyValue(this,'ReduceUpdates');
    setPropertyValue(this,'ReduceUpdates',~val);
    this.ReduceUpdates=~val;
end
