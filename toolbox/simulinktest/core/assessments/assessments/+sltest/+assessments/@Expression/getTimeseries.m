function ts=getTimeseries(self)


    if isa(self,'sltest.assessments.Signal')

        ts=self.timeseries;
    else
        self.internal.verify();
        res=self.internal.results();
        ts=timeseries(res.Value,res.Time,'Name',res.Name).setinterpmethod(res.Interpolation);
    end
end


