function xformedBlks=trace(this,aBlk)



    this.clearAllHilite();
    xformedBlks=[];
    if isa(aBlk,'double')
        sid=Simulink.ID.getSID(aBlk);
    elseif isa(aBlk,'char')
        try
            sid=Simulink.ID.getSID(aBlk);
        catch
            sid=aBlk;
        end
    end
    for i=1:length(this.fTraceabilityMap)
        if~isempty(find(strcmpi(this.fTraceabilityMap(i).Before,sid),1))
            path=strsplit(this.fTraceabilityMap(i).After{1},':');
            if~bdIsLoaded(path{1})
                load_system([this.fXformDir,'/',path{1}]);
            end
            hilite_system(this.fTraceabilityMap(i).After,'user2');
            xformedBlks=this.fTraceabilityMap(i).After;
            break;
        elseif~isempty(find(strcmpi(this.fTraceabilityMap(i).After,sid),1))
            path=strsplit(this.fTraceabilityMap(i).Before{1},':');
            if~bdIsLoaded(path{1})
                load_system(path{1});
            end
            hilite_system(this.fTraceabilityMap(i).Before,'user2');
            xformedBlks=this.fTraceabilityMap(i).Before;
            break;
        end
    end
end
