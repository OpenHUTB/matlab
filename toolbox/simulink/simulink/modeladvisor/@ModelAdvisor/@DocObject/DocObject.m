function h=DocObject(arg,varargin)



    import matlab.io.xml.dom.*

    h=ModelAdvisor.DocObject;
    opts.forgive=true;
    opts=slprivate('parseArgs',opts,varargin{:});

    if isa(arg,'char')
        if arg(1)=='<'&&arg(end)=='>'
            s=arg;
        else

            fid=fopen(arg,'rt','n','UTF-8');
            s=fread(fid,'*char')';
            fclose(fid);
        end
        if opts.forgive

            s=strrep(s,'&nbsp;','&#160;');
            s=regexprep(s,'<br></br>','<br />','preservecase');
            s=regexprep(s,'<br>','<br />','preservecase');
            s=regexprep(s,'<hr></hr>','<hr />','preservecase');
            s=regexprep(s,'<hr>','<hr />','preservecase');
        end





        tmpFile=[tempname,'.xml'];
        fid=fopen(tmpFile,'w','n','UTF-8');
        fwrite(fid,s,'*char');
        fclose(fid);
        p=Parser;
        p.Configuration.AllowDoctype=true;
        p.Configuration.LoadExternalDTD=false;
        xDoc=parseFile(p,tmpFile);
        h.XDoc=xDoc.getDocumentElement;
    elseif isa(arg,'matlab.io.xml.dom.Element')
        h.XDoc=arg;
    else
        DAStudio.error('Simulink:utility:invalidInputArgs',char(arg));
    end
