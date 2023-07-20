function td=getTraceabilityDriver(this,mdlName)


    narginchk(2,2);

    if isempty(this.TraceabilityDriver)

        td=slhdlcoder.HDLTraceabilityDriver(mdlName);
        this.TraceabilityDriver=containers.Map(mdlName,td);
    else
        if this.TraceabilityDriver.isKey(mdlName)

            td=this.TraceabilityDriver(mdlName);
        else

            td=slhdlcoder.HDLTraceabilityDriver(mdlName);
            this.TraceabilityDriver(mdlName)=td;
        end
    end
end
