function str=dumpConfigStr(this,implDB)







    str=[printStatements(this,implDB)];

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


function str=printStatements(this,implDB)

    str=[];
    if length(this.statements)>1
        str=[str,repmat('%%',1,35),sprintf('\n')];
        str=[str,sprintf('HDL Block Configuration Information\n')];
        str=[str,repmat('%%',1,35),sprintf('\n\n')];
    end


    for ii=1:length(this.statements)
        stmt=this.statements(ii);
        blockType=stmt.BlockType;

        str=[str,sprintf('Scope \t\t\t\t: ''%s''\n',stmt.Scope)];%#ok<*AGROW>

        str=[str,sprintf('BlockType \t\t\t: ''%s''\n',blockType)];

        str=[str,sprintf('Architecture Name \t: ''%s''\n',getImplArchName(blockType,stmt.Implementation,implDB))];
        str=[str,sprintf('Architecture Params : ')];
        str=[str,sprintf('{\n')];
        if length(stmt.ImplParams)>1


            if mod(length(stmt.ImplParams),2)~=0
                stmt.ImplParams(1)=[];
            end

            for jj=1:2:length(stmt.ImplParams)
                str=[str,sprintf('\t\t\t\t\t\t')];
                paramName=stmt.ImplParams{jj};
                paramValue=stmt.ImplParams{jj+1};
                if ischar(paramName)
                    str=[str,sprintf('''%s'', ',paramName)];
                end

                if ischar(paramValue)
                    str=[str,sprintf('''%s'' ',paramValue)];
                elseif isnumeric(paramValue)
                    str=[str,sprintf('%d ',paramValue)];
                end
                str=[str,sprintf('\n')];
            end
        end
        str=[str,sprintf('\t\t\t\t\t  }\n\n')];

    end

end



