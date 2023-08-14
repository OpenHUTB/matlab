function makeDescription(h)




    fName='getDescription.m';
    fid=h.openFile(fName);

    fprintf(fid,'function compDesc=getDescription(thisComp)\n');
    fprintf(fid,'%%GETDESCRIPTION Return a short description of the component\n');
    fprintf(fid,'%%  DESC = COMPONENT.GETDESCRIPTION returns a short description\n');
    fprintf(fid,'%%    of the component for display in help.\n');
    fprintf(fid,'%%    \n');
    fprintf(fid,'\n');
    fprintf(fid,'%%  This method is static and does not change \n');
    fprintf(fid,'%%  depending on component properties.\n');
    fprintf(fid,'\n');
    fprintf(fid,'%%  The description should be between one and three sentences.\n');

    h.writeHeader(fid);


    fprintf(fid,'compDesc = ''%s'';\n',...
    strrep(h.Description,'''',''''''));

    fclose(fid);

    h.viewFile(fName,2);
