



function out=getInstrumDataInfo(this,force)

    if nargin<2
        force=false;
    end
    out=this.InstrumImpl.getInstrumDataInfo(force);
end
