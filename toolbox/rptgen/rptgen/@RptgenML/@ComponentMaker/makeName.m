function makeName(this)






    fName='getName.m';
    fid=this.openFile(fName);

    fprintf(fid,'function compName=getName(thisComp)\n');
    fprintf(fid,'%%GETNAME Declare the component''s display name\n');
    fprintf(fid,'%%  NAME = COMPONENT.GETNAME returns the name of the\n');
    fprintf(fid,'%%    component in the options palette.\n');
    fprintf(fid,'%%    \n');
    fprintf(fid,'%%  Note that this method does not control the \n');
    fprintf(fid,'%%  component name as displayed in the Report Explorer\n');
    fprintf(fid,'%%  hierarchy, which can change to reflect component\n');
    fprintf(fid,'%%  property settins.  See also GETOUTLINESTRING\n');
    fprintf(fid,'\n');
    fprintf(fid,'%%  This method is static and does not change \n');
    fprintf(fid,'%%  depending on component properties.\n');
    fprintf(fid,'\n');
    fprintf(fid,'%%  Note that NAME information is duplicated in\n');
    fprintf(fid,'%%  the file ../rptcomps2.xml.  Any changes here should\n');
    fprintf(fid,'%%  be updated there as well.\n\n');

    this.writeHeader(fid);
    fprintf(fid,'compName=''%s'';\n',...
    strrep(this.DisplayName,'''',''''''));
    fclose(fid);

    this.viewFile(fName,2);
