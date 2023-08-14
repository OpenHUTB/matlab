function subsysCap=bcstCreateCap(block,capString,trans)











































    hasDepends=isfield(trans,'depends');
    if hasDepends
        depends=trans.depends;
        trans=rmfield(trans,'depends');
    end
    flds=fields(trans);
    legalCaps=sprintf('%s|',flds{:});
    legalCaps(end)=[];




    if~iscell(capString)
        capString={capString};
    end

    subsysCap=[];

    for strIdx=1:length(capString)

        oneString=capString{strIdx};
        oneMode=regexp(oneString,'^\((\<.*\>)\)','tokens');
        if isempty(oneMode)
            oneMode='';
        else
            oneMode=oneMode{1}{1};
        end
        oneString=regexprep(oneString,'^\(.*\)','');

        if strcmp(oneString,'+')
            parseString=sprintf('%s;',flds{:});
        else
            parseString=oneString;
        end


        caps=getInitialCap(trans);


        while~isempty(parseString)
            [split]=regexp(...
            parseString,...
            ['^\<(',legalCaps,')\>'...
            ,'(-|\.|)'...
            ,'(([a-zA-Z][a-zA-Z0-9_]+(,|))+|)'...
            ,'(;|)'...
            ,'(.*)$'],...
            'tokens');
            try
                cap=split{1}{1};
                div=split{1}{2};
                note=split{1}{3};
            catch %#ok<CTCH>

                blockName=regexprep([get_param(block,'Parent'),'/',get_param(block,'Name')],'\s',' ');
                DAStudio.error('Simulink:bcst:ErrCannotParse',blockName,oneString);
            end

            parseString=split{1}{5};
            if isfield(trans,cap)
                if~strcmp(div,'-')
                    suppStr='Yes';
                    hasSupp=true;
                else
                    suppStr='No';
                    hasSupp=false;
                end
                if isempty(note)
                    caps.(trans.(cap))=CapStruct(trans.(cap),suppStr);
                else
                    caps.(trans.(cap))=CapStruct(trans.(cap),suppStr,note);
                end
                if hasDepends&&hasSupp&&isfield(depends,cap)
                    dependent=trans.(depends.(cap));
                    if strcmp(caps.(dependent).Support,'No')&&...
                        isempty(caps.(dependent).Footnotes)
                        caps.(dependent).Support='Yes';
                    end
                end
            else
                blockName=regexprep([get_param(block,'Parent'),'/',get_param(block,'Name')],'\s',' ');
                DAStudio.error('Simulink:bcst:ErrIllegalCapStr',blockName,capString);
            end
        end


        cellCaps=struct2cell(caps);


        if isempty(subsysCap)
            subsysCap=Capabilities(CapSet(cellCaps{:}));
        else
            newSet=CapSet(cellCaps{:});
            newSet.ModeName=oneMode;
            subsysCap=subsysCap.addSet(newSet);
        end
    end



    function initialCap=getInitialCap(trans)

        caps=struct2cell(trans);
        for capIdx=1:length(caps)
            capName=caps{capIdx};
            initialCap.(capName)=CapStruct(capName,'no');
        end


