function makeRegistry(this)






    fName=fullfile(this.PkgDir,['@',this.PkgName],'rptcomps2.xml');

    if isempty(this.v1ClassName)
        v1Name=[];
    else
        v1Name={this.v1ClassName};
    end

    mlreportgen.re.internal.tools.RptComponentParser.appendComponent(fName,...
    [this.PkgName,'.',this.ClassName],...
    this.DisplayName,...
    this.Type,...
    v1Name,...
    strrep(this.TypeHelpFile,matlabroot,'$matlabroot'));

    this.viewFile(fName,3);
