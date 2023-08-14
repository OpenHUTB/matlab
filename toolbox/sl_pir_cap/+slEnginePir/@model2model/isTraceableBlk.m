function isTraceable=isTraceableBlk(this,aBlk)



    isTraceable=0;
    sid=Simulink.ID.getSID(aBlk);
    for i=1:length(this.fTraceabilityMap)
        if~isempty(find(strcmpi(this.fTraceabilityMap(i).Before,sid),1))
            isTraceable=1;
            break;
        elseif~isempty(find(strcmpi(this.fTraceabilityMap(i).After,sid),1))
            isTraceable=2;
            break;
        end
    end
end
