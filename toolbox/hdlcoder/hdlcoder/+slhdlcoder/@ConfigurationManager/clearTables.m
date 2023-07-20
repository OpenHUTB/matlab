function clearTables(this)


    this.MergedConfigContainer=slhdlcoder.ConfigurationContainer('default');

    this.DefaultTable=slhdlcoder.HDLImplementationTable(this.ImplDB);
    this.HereOnlyComponentTable=slhdlcoder.HDLImplementationTable(this.ImplDB);
    this.FrontEndStopTable=slhdlcoder.HDLImplementationTable(this.ImplDB);
end
