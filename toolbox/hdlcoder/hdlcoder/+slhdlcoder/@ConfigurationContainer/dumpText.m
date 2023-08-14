function dumpText(this,filename,implDB,nondefault)







    if nargin<2
        filename='hdlcontrolfile.m';
        nondefault=false;
    elseif nargin<3
        nondefault=false;
    end

    fid=fopen(filename,'W');
    if~fid
        error(message('hdlcoder:engine:FileNotFound',filename));
    end

    printHeader(this,fid,filename);
    printTopLevel(this,fid);
    printSettings(this,fid,nondefault);
    printStatements(this,implDB,fid);

    fclose(fid);

end


function printHeader(~,fid,filename)

    [path,funcname,exten]=fileparts(filename);%#ok

    fprintf(fid,'function c = %s\n\n',funcname);
    fprintf(fid,'%% \n\n');
    fprintf(fid,'c = hdlnewcontrol(mfilename);\n\n');

end


function printTopLevel(this,fid)

    hD=hdlcurrentdriver;
    if(isempty(hD.getStartNodeName))
        this.HDLTopLevel='';
    else
        this.HDLTopLevel=hD.getStartNodeName;
    end

    if~isempty(this.HDLTopLevel)
        fprintf(fid,'c.generateHDLFor(''%s'');\n\n',this.HDLTopLevel);
    end

end

function printSettings(~,fid,nondefault)


    nonSetables='SetupTime';
    hD=hdlcurrentdriver;
    cli=hD.getCLI;
    if nondefault
        pvcell=cli.createmstr('nondefault');
    else
        pvcell=cli.createmstr;
    end

    if~isempty(pvcell)
        fprintf(fid,'c.set( ...\n');
        for ii=1:length(pvcell)-1
            if isempty(findstr(pvcell{ii},nonSetables))
                fprintf(fid,'\t%s,...\n',pvcell{ii});
            end
        end
        fprintf(fid,'\t%s);\n\n',pvcell{end});
    end

end


function archName=getImplArchName(blockType,className,implDB)

    archName='';
    try
        if strcmpi(className,'default')
            archName=className;
            return;
        end


        impl=implDB.getImplementationForArch(blockType,className);
        if~isempty(impl)
            impl=eval(impl);
            archNames=impl.ArchitectureNames;
            if~isempty(archNames)
                archName=archNames{1};
            else
                archName='default';
            end
        else

            if~isempty(className)
                archName=className;
            else

                archName='default';
            end
        end
    catch me %#ok<NASGU>
        warning(message('hdlcoder:engine:badimplname',className,blockType));
    end
end


function printStatements(this,implDB,fid)

    for ii=1:length(this.statements)
        stmt=this.statements(ii);
        blockType=stmt.BlockType;

        fprintf(fid,'c.forEach( ...\n');
        fprintf(fid,'\t''%s'', ...\n',stmt.Scope);

        fprintf(fid,'\t''%s'', ',blockType);
        fprintf(fid,'{');
        for jj=1:length(stmt.BlockParams)
            fprintf(fid,'''%s'', ',stmt.BlockParams{jj});
        end
        fprintf(fid,'}, ...\n');

        fprintf(fid,'\t''%s'', ',getImplArchName(blockType,stmt.Implementation,implDB));
        fprintf(fid,'{');
        if length(stmt.ImplParams)>1
            for jj=2:length(stmt.ImplParams)-1
                if ischar(stmt.ImplParams{jj})
                    fprintf(fid,'''%s'', ',stmt.ImplParams{jj});
                elseif isnumeric(stmt.ImplParams{jj})
                    fprintf(fid,'%d, ',stmt.ImplParams{jj});
                end
            end
            if ischar(stmt.ImplParams{end})
                fprintf(fid,'''%s''',stmt.ImplParams{end});
            elseif isnumeric(stmt.ImplParams{end})
                fprintf(fid,'%d',stmt.ImplParams{end});
            end
        end
        fprintf(fid,'});\n\n');

    end

end



