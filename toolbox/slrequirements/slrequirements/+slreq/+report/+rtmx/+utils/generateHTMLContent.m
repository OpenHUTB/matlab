function out=generateHTMLContent(htmlString,filePath)
    templateFile=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','slrtmx_exported');
    templateContent=fileread(templateFile);

    jsFile=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','slrtmx_exported_js');
    jsContent=fileread(jsFile);
    out=true;
    fid=fopen(filePath,'w');
    htmlStringSurfix='</body></html>';
    fprintf(fid,'%s\n%s\n%s\n%s',templateContent,htmlString,jsContent,htmlStringSurfix);
    fclose(fid);
    web(filePath,'-browser')
end