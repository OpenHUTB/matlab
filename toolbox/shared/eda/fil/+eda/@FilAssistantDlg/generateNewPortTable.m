function generateNewPortTable(this,dlg)




    hdlTopFileName=this.BuildInfo.TopLevelSourceFile;


    this.Status=sprintf('Parsing interface of design unit ''%s'' in file ''%s''. Please wait ...',this.TopModuleName,hdlTopFileName);
    dlg.refresh;


    fileType=this.BuildInfo.SourceFiles.FileType{this.BuildInfo.TopLevelIndex};


    switch(fileType)
    case 'VHDL'
        [hdlinfo,parserinfo,codeinfo]=eda.internal.hdlparser.parseVhdlEntity(hdlTopFileName,this.TopModuleName);
    otherwise
        [hdlinfo,parserinfo,codeinfo]=eda.internal.hdlparser.parseVlogModule(hdlTopFileName,this.TopModuleName);
    end


    l_constructPortTable(this,parserinfo,codeinfo);


    this.HasParsingError=~isempty(parserinfo.getErrorId);

end

function l_constructPortTable(this,parserinfo,codeinfo)

    this.NewPortTableData=cell(0,4);
    this.Status='';

    for ii=1:numel(codeinfo.Inports)
        Impl=codeinfo.Inports(ii).Implementation;
        portName=Impl.Identifier;
        portDirection='in';
        if Impl.Type.isNumeric
            portBitwidth=Impl.Type.WordLength;
        else
            parserinfo.addErrorEntry('DataType',...
            sprintf('Port "%s" is declared with an unsupported data type.',portName));
        end


        if(~isempty(strfind(Impl.Type.Identifier,'(0 DOWNTO'))||...
            ~isempty(strfind(Impl.Type.Identifier,'(0 downto'))||...
            ~isempty(strfind(Impl.Type.Identifier,'[0:')))
            parserinfo.addErrorEntry('AscendingRange',...
            sprintf(['Port "%s" is declared as array with ascending range, which is currently unsupported. '...
            ,'Please use array with descending range.'],portName));
        end

        this.addNewPort(portName,portDirection,portBitwidth,-1,true);
    end

    for ii=1:numel(codeinfo.Outports)
        Impl=codeinfo.Outports(ii).Implementation;
        portName=Impl.Identifier;
        portDirection='out';
        if Impl.Type.isNumeric
            portBitwidth=Impl.Type.WordLength;
        else
            parserinfo.addErrorEntry('DataType',...
            sprintf('Port "%s" is declared with an unsupported data type.',portName));
        end


        if(~isempty(strfind(Impl.Type.Identifier,'(0 DOWNTO'))||...
            ~isempty(strfind(Impl.Type.Identifier,'(0 downto'))||...
            ~isempty(strfind(Impl.Type.Identifier,'[0:')))
            parserinfo.addErrorEntry('AscendingRange',...
            sprintf(['Port "%s" is declared as array with ascending range, which is currently unsupported. '...
            ,'Please use array with descending range.'],portName));
        end

        this.addNewPort(portName,portDirection,portBitwidth,-1,true);
    end

    if(parserinfo.hasMessage)
        this.Status=sprintf('Message reported by HDL parser:\n%s',parserinfo.getAllMessage);


        if(any(strcmpi('hdlparser:VlogLexer:ModuleNotFound',parserinfo.getErrorId))||...
            any(strcmpi('hdlparser:VhdlLexer:EntityNotFound',parserinfo.getErrorId)))
            this.Status=[this.Status...
            ,sprintf('Please go back to the previous step and make sure that\n(1) The top-level file selection is correct.\n(2) The top-level module "%s" exists in file "%s".\n(3) There are no syntax errors in the module interface declaration.\n',...
            this.TopModuleName,this.BuildInfo.TopLevelSourceFile)];
        end

        this.lastErrorID=parserinfo.getErrorId;
        this.lastWarningID=parserinfo.getWarningId;
    end
end
