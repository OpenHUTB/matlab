function fName=cbkSelectFile(this)





    if isempty(this.SrcFileName)
        startFile=fullfile(pwd,'*.xml');
    else
        startFile=this.SrcFileName;
    end

    [fName,pName,filterIdx]=uigetfile(...
    {'*.xml',getString(message('rptgen:RptgenML_FileConverter:xmlFiles'));...
    '*.*',getString(message('rptgen:RptgenML_FileConverter:allFiles'))},...
    getString(message('rptgen:RptgenML_FileConverter:selectRGSourceFile')),startFile);

    if isequal(fName,0)||isequal(pName,0)
        fName='';
    else
        fName=fullfile(pName,fName);
        this.SrcFileName=fName;
    end
