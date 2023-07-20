function[ctrlstmt,implchoices,implpvpairs]=privhdlnewblackbox(block)




    ctrlstmt='';
    implchoices={};
    implpvpairs={};

    if ischar(block)
        block={block};
    end


    for ii=1:length(block)

        bdr=bdroot(block{ii});


        if~strcmpi(get_param(bdr,'LibraryType'),'None')
            error(message('hdlcoder:makehdl:blockinlibrary'))
        end

        try
            hC=hdlmodeldriver(bdr);
        catch me %#ok<NASGU>
            warning(message('hdlcoder:makehdl:NoHDLCoder'))
            return;
        end

        if isempty(hC.ImplDB)
            hC.buildDatabase;
        end


        blkObj=get_param(block{ii},'Object');

        modelScope=[blkObj.path,'/',blkObj.name];
        modelScope=strrep(modelScope,char(10),' ');
        [blockScope,isInvalid]=hdlgetblocklibpath(block{ii});
        blockScope=strrep(blockScope,char(10),' ');

        if isInvalid
            error(message('hdlcoder:makehdl:invalid',block{ii}));
        end

        if isempty(hC.getConfigManager)
            warning(message('hdlcoder:makehdl:NoConfigManager'))

            return;
        end
        try
            defaultImpl=hdldefaults.SubsystemBlackBoxHDLInstantiation;
            currentImpl=defaultImpl;%#ok<NASGU>
        catch me %#ok<NASGU>

            return;
        end

        if isempty(defaultImpl)&&...
            any(strmatch(blockScope,...
            {'built-in/SubSystem'},'exact'))
            newImpls=hC.ImplDB.getImplementationsFromBlock(blockScope);
            implchoices={implchoices{:},newImpls};%#ok<CCAT>

            for jj=1:length(newImpls)
                impl=eval(newImpls{jj});
                newPVPairs=impl.implParamNames;
                implpvpairs={implpvpairs{:},newPVPairs};%#ok<CCAT>
            end




        elseif~(isempty(defaultImpl)||...
            any(strmatch(blockScope,...
            {'built-in/Inport',...
            'built-in/Outport'},...
            'exact')))

            newImpls=hC.ImplDB.getImplementationsFromBlock(blockScope);
            implchoices={implchoices{:},newImpls};%#ok<CCAT>
            oneMatched=false;
            implchoices=implchoices{1};
            for i=1:length(implchoices)
                if strcmp(implchoices{i},'hdldefaults.SubsystemBlackBoxHDLInstantiation')
                    oneMatched=true;
                end
                impl=eval(implchoices{i});
                archName=impl.ArchitectureNames(1);
                if iscell(archName)
                    archName=archName{1};
                end
                implchoices{i}=archName;
            end
            if~oneMatched
                error(message('hdlcoder:makehdl:notBlackBoxable',blockScope));
            end

            archName=defaultImpl.ArchitectureNames(1);
            if iscell(archName)
                archName=archName{1};
            end

            ctrlstmt=[ctrlstmt,sprintf('c.forEach(''%s'',...\n ''%s'', {},...\n ''%s'', {});\n\n',...
            modelScope,...
            blockScope,...
            archName)];%#ok<AGROW>
            for jj=1:length(newImpls)
                impl=eval(newImpls{jj});
                newPVPairs=impl.implParamNames;
                implpvpairs={implpvpairs{:},newPVPairs};%#ok<CCAT>
            end
        end

    end



