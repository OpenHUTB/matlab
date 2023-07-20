function printFileLink(this)



    if strcmpi(this.testBenchPackageFile,'on')
        fullfilename=fullfile(this.CodeGenDirectory,...
        [this.TestBenchName,hdlgetparameter('package_suffix'),this.TBFileNameSuffix]);
        msg=message('HDLShared:hdlshared:gentbpackage',hdlgetfilelink(fullfilename));
        hdldisp(msg.getString,1);
    end

    if strcmpi(this.TestBenchdataFile,'on')
        fullfilename=fullfile(this.CodeGenDirectory,...
        [this.TestBenchName,this.TestBenchDataPostfix,this.TBFileNameSuffix]);
        msg=message('HDLShared:hdlshared:gentbdatafile',hdlgetfilelink(fullfilename));
        hdldisp(msg.getString,1);
    end


    nameforuser=[this.TestBenchName,this.TBFileNameSuffix];
    fullfilename=fullfile(this.CodeGenDirectory,nameforuser);
    msg=message('HDLShared:hdlshared:gentbfile',hdlgetfilelink(fullfilename));
    hdldisp(msg.getString,1);
end

