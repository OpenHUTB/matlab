function dumpConfigStmtInfo(this,filename,implDB)







    fid=fopen(filename,'W');
    if~fid
        error(message('hdlcoder:engine:FileNotFound',filename));
    end

    str=this.dumpConfigStr(implDB);
    fprintf(fid,'%s',str);

    fclose(fid);

end


function printTopLevel(this,fid)

    hD=hdlcurrentdriver;
    this.HDLTopLevel=hD.getStartNodeName;
    if~isempty(this.HDLTopLevel)

        fprintf(fid,[repmat('%%',1,75),'\n']);
        fprintf(fid,'GenerateHDLFor : ''%s''\n',this.HDLTopLevel);
        fprintf(fid,[repmat('%%',1,75),'\n\n']);
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

    if length(this.statements)>1
        fprintf(fid,[repmat('%%',1,75),'\n']);
        fprintf(fid,'Block HDL Configuration Information\n');
        fprintf(fid,[repmat('%%',1,75),'\n\n']);
    end


    for ii=1:length(this.statements)
        stmt=this.statements(ii);
        blockType=stmt.BlockType;

        fprintf(fid,'Scope \t\t\t\t: ''%s''\n',stmt.Scope);

        fprintf(fid,'BlockType \t\t\t: ''%s''\n',blockType);

        fprintf(fid,'Architecture Name \t: ''%s''\n',getImplArchName(blockType,stmt.Implementation,implDB));
        fprintf(fid,'Architecture Params : ');
        fprintf(fid,'{\n');
        if length(stmt.ImplParams)>1



            if iscell(stmt.ImplParams{1})
                stmt.ImplParams(1)=[];
            end
            if iscell(stmt.ImplParams{1})
                stmt.ImplParams(1)=[];
            end

            for jj=1:2:length(stmt.ImplParams)
                fprintf(fid,'\t\t\t\t\t\t');
                paramName=stmt.ImplParams{jj};
                paramValue=stmt.ImplParams{jj+1};
                if ischar(paramName)
                    fprintf(fid,'''%s'', ',paramName);
                end

                if ischar(paramValue)
                    fprintf(fid,'''%s'' ',paramValue);
                elseif isnumeric(paramValue)
                    fprintf(fid,'%d ',paramValue);
                end
                fprintf(fid,'\n');
            end
        end
        fprintf(fid,'\t\t\t\t\t  }\n\n');

    end

end



