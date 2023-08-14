function body=privhdlnewcontrolfile(block)







    narginchk(1,1);
    if ischar(block)
        block={block};
    end
    bdr=bdroot(block{1});


    if~strcmpi(get_param(bdr,'LibraryType'),'None')
        error(message('hdlcoder:makehdl:blockinlibrary'))
    end


    try
        c=hdlmodeldriver(bdr);
    catch me
        error(message('hdlcoder:makehdl:NoHDLCoder'))
    end

    try
        snn=c.getStartNodeName;
        nondefault=createmstr(c.getCLI,'nondefault');
    catch
        snn=bdr;
        nondefault=[];
    end

    separatorline=[repmat('%',1,32),newline];

    body=['function c = controlfilename',hdl.newline(2),...
    '% Control file for ',bdr,hdl.newline(2),...
    'c = hdlnewcontrol(mfilename);',hdl.newline(2),...
    'c.generateHDLFor(''',snn,''');',hdl.newline(2)];

    if~isempty(nondefault)
        nondefault=strcat({'    '},nondefault,{',...'},{hdl.newline});
        nondefault=[nondefault{:}];
        body=[body,separatorline,...
        'c.set( ...',hdl.newline,...
        nondefault(1:end-5),...
        ');',hdl.newline(2)];
    end

    for ii=1:length(block)
        [~,implchoices,implparams,currentstmt]=privhdlnewforeach(block{ii});
        if~isempty(implchoices)&&~isempty(implparams)&&~isempty(currentstmt)
            body=[body,...
            separatorline,...
            formatimpl(implchoices,implparams),...
            currentstmt,...
            hdl.newline];%#ok<*AGROW>
        end
    end
end

function body=formatimpl(implchoices,implparams)
    body='';
    ic=implchoices{1};
    for ii=1:length(ic)
        body=[body,'% ',ic{ii}];
        ip=implparams{ii};
        for jj=1:length(implparams{ii})
            body=[body,' : ',ip{jj},' '];
        end
        body=[body,hdl.newline];
    end
    body=[body,hdl.newline];
end


