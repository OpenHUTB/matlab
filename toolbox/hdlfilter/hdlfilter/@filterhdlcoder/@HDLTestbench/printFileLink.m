function printFileLink(this)



    if strcmpi(this.testBenchPackageFile,'on')
        fullfilename=fullfile(this.CodeGenDirectory,...
        [this.TestBenchName,hdlgetparameter('package_suffix'),this.TBFileNameSuffix]);
        fullfilename=appendPath(fullfilename);
        s=['Generating Test bench package:  <a href="matlab:edit(''',fullfilename,''')">',fullfilename,'</a>'];
        hdldisp(s,1);
    end

    if strcmpi(this.TestBenchdataFile,'on')
        fullfilename=fullfile(this.CodeGenDirectory,...
        [this.TestBenchName,this.TestBenchDataPostfix,this.TBFileNameSuffix]);
        fullfilename=appendPath(fullfilename);
        s=['Generating Test bench data file: <a href="matlab:edit(''',fullfilename,''')">',fullfilename,'</a>'];
        hdldisp(s,1);
    end


    nameforuser=[this.TestBenchName,this.TBFileNameSuffix];
    fullfilename=fullfile(this.CodeGenDirectory,nameforuser);
    fullfilename=appendPath(fullfilename);
    s=['Generating Test bench: <a href="matlab:edit(''',fullfilename,''')">',fullfilename,'</a>'];
    hdldisp(s,1);

    function nameforuser=appendPath(tbfilename)

        [pathstr,fname,exten]=fileparts(tbfilename);
        fullfilename=[fname,exten];
        nameforuser=fullfile(pathstr,fullfilename);
        if~isempty(pathstr)
            whatstruct=what(pathstr);
            whatstruct=whatstruct(end);
            if~isempty(whatstruct)
                nameforuser=fullfile(whatstruct.path,fullfilename);
            end
        end
