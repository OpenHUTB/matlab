


classdef(Sealed)VlogParser<eda.internal.hdlparser.HdlParser


    properties(Access=private)
        LineListPortId=[];
        HasListPortId=false;
    end

    methods

        function obj=VlogParser(filename,modulename)
            obj=obj@eda.internal.hdlparser.HdlParser(filename,modulename);
            identifier='[a-zA-Z_][a-zA-Z0-9_$]*';
            tmp=regexp(modulename,identifier,'match','once');
            assert(strcmp(tmp,modulename),'EDALink:VlogParser:InvalidModuleName',...
            'Invalid module name. It must be a valid Verilog identifier.');
        end

        function[moduleinfo,parserinfo,codeinfo]=parse(obj)






            moduleinfo=eda.internal.hdlparser.VlogModuleInfo;
            parserinfo=eda.internal.hdlparser.HdlParserInfo;
            codeinfo=RTW.ComponentInterface;

            obj.ModuleInfo=moduleinfo;
            obj.ParserInfo=parserinfo;
            obj.LineListPortId=[];
            obj.HasListPortId=false;
            obj.CodeInfo=codeinfo;

            try
                fid=fopen(obj.FileName,'r');
                assert(fid~=-1,'EDALink:VlogParser:OpenFileFailure',...
                'Cannot open file "%s"',obj.FileName);
                hdlText=fread(fid,'uint8=>char')';
                fclose(fid);

                obj.Lexer=eda.internal.hdlparser.VlogLexer(hdlText);





                obj.Lexer.preProcessing;

                obj.Lexer.findModule(obj.ModuleName);




                look=obj.Lexer.peek;
                switch(look.tag)
                case eda.internal.hdlparser.VlogToken.TAG_SEMICOLON
                    obj.ParserInfo.addInfoEntry('NoPortDeclar',...
                    sprintf('No list of port identifiers in module "%s"',obj.ModuleName));
                    return;
                case eda.internal.hdlparser.VlogToken.TAG_SHARP

                    obj.match(eda.internal.hdlparser.VlogToken.TAG_SHARP);
                    obj.match(eda.internal.hdlparser.VlogToken.TAG_LPAREN,true);
                    obj.Lexer.skipParameterDeclr;
                end


                obj.match(eda.internal.hdlparser.VlogToken.TAG_LPAREN);

                look=obj.Lexer.peek;
                obj.HasListPortId=false;
                switch(look.tag)
                case eda.internal.hdlparser.VlogToken.TAG_INPUT
                    obj.parseInputDecl;
                case eda.internal.hdlparser.VlogToken.TAG_OUTPUT
                    obj.parseOutputDecl;
                case eda.internal.hdlparser.VlogToken.TAG_INOUT
                    obj.parseInoutDecl;
                case eda.internal.hdlparser.VlogToken.TAG_RPAREN;
                    obj.ParserInfo.addInfoEntry('NoPortDeclar',...
                    sprintf('No list of port identifiers in module "%s"',obj.ModuleName));
                    return;
                otherwise
                    obj.parseListPortDecl;
                    obj.HasListPortId=true;
                end
                if(~obj.HasListPortId)
                    while(1)
                        look=obj.Lexer.peek;
                        switch(look.tag)
                        case eda.internal.hdlparser.VlogToken.TAG_INPUT
                            obj.parseInputDecl;
                        case eda.internal.hdlparser.VlogToken.TAG_OUTPUT
                            obj.parseOutputDecl;
                        case eda.internal.hdlparser.VlogToken.TAG_INOUT
                            obj.parseInoutDecl;
                        otherwise
                            obj.match(eda.internal.hdlparser.VlogToken.TAG_RPAREN);
                            break;
                        end
                    end
                    obj.match(eda.internal.hdlparser.VlogToken.TAG_SEMICOLON);
                else
                    r=obj.Lexer.scanPortDecl;
                    while(r)
                        look=obj.Lexer.peek;
                        switch(look.tag)
                        case eda.internal.hdlparser.VlogToken.TAG_INPUT
                            obj.parseInputDecl;
                        case eda.internal.hdlparser.VlogToken.TAG_OUTPUT
                            obj.parseOutputDecl;
                        case eda.internal.hdlparser.VlogToken.TAG_INOUT
                            obj.parseInoutDecl;
                        otherwise
                            error(message('EDALink:VlogParser:InvalidTag',look.tag));
                        end
                        obj.match(eda.internal.hdlparser.VlogToken.TAG_SEMICOLON);
                        r=obj.Lexer.scanPortDecl;
                    end

                    for m=1:obj.ModuleInfo.getNumOfPorts
                        if(isempty(obj.ModuleInfo.getPortDirection(m)))
                            error(message('EDALink:VlogParser:UndeclaredPortMode',obj.LineListPortId(m),obj.ModuleInfo.getPortName(m)));
                        end
                    end
                end


                codeinfo.Name=obj.ModuleName;
                numPorts=moduleinfo.getNumOfPorts;

                for m=1:numPorts
                    portName=moduleinfo.getPortName(m);
                    portDirection=moduleinfo.getPortDirection(m);
                    portBitwidth=moduleinfo.getPortBitWidth(m);
                    portRangeDescending=moduleinfo.isRangeDescending(m);

                    HDLType=embedded.numerictype;
                    HDLType.WordLength=portBitwidth;
                    HDLType.BinaryPoint=0;
                    HDLType.SignednessBool=false;
                    HDLType.Name='';
                    if(portRangeDescending)
                        HDLType.Identifier=sprintf('wire[%d:0]',portBitwidth);
                    else
                        HDLType.Identifier=sprintf('wire[0:%d]',portBitwidth);
                    end
                    cType=coder.types.Type.createCoderType(HDLType);
                    HDLImpl=RTW.Variable(cType,portName,obj.ModuleName);
                    dataInterface=RTW.DataInterface('',portName,HDLImpl,RTW.TimingInterface.empty);

                    if strcmp(portDirection,'input')
                        InportNum=length(codeinfo.Inports);
                        if InportNum==0
                            codeinfo.Inports=dataInterface;
                        else
                            codeinfo.Inports(InportNum+1)=dataInterface;
                        end
                    else
                        OutportNum=length(codeinfo.Outports);
                        if OutportNum==0
                            codeinfo.Outports=dataInterface;
                        else
                            codeinfo.Outports(OutportNum+1)=dataInterface;
                        end
                    end

                end

            catch ME
                if(isempty(strfind(ME.identifier,'hdlparser')))
                    rethrow(ME);
                else
                    obj.ParserInfo.addErrorEntry(ME.identifier,[obj.FileName,' : ',ME.message]);
                end
            end
        end
    end

    methods(Access=private)
        function new_id=addMessageID(~,id)

            new_id=['EDALink:VlogParser:',id];
        end

        function[r,tokenStr]=match(obj,tag,optional)







            if(nargin<3)
                optional=false;
            end

            look=obj.Lexer.peek;
            r=(look.tag==tag);

            if(r)
                token=obj.Lexer.scan;
                tokenStr=token.str;
            else
                tokenStr='';
            end

            if(~r&&~optional)
                token=obj.Lexer.getToken;
                error(message('EDALink:VlogParser:UnexpectedToken',obj.Lexer.getLineNumber,token.str,eda.internal.hdlparser.VlogToken.tag2str(tag)));
            end
        end

        function parseInputDecl(obj)

            obj.match(eda.internal.hdlparser.VlogToken.TAG_INPUT);
            obj.match(eda.internal.hdlparser.VlogToken.TAG_NET,true);
            obj.match(eda.internal.hdlparser.VlogToken.TAG_SIGNED,true);
            [bitwidth,isdescending]=obj.parseRange;
            idlist=obj.parseIdList;

            for m=1:numel(idlist)
                if(obj.HasListPortId)
                    obj.addPortDecl(idlist{m},'input',bitwidth,isdescending);
                else
                    obj.addNewPort(idlist{m},'input',bitwidth,isdescending);
                end
            end
        end

        function parseInoutDecl(obj)

            obj.match(eda.internal.hdlparser.VlogToken.TAG_INOUT);
            obj.match(eda.internal.hdlparser.VlogToken.TAG_NET,true);
            obj.match(eda.internal.hdlparser.VlogToken.TAG_SIGNED,true);
            [bitwidth,isdescending]=obj.parseRange;
            idlist=obj.parseIdList;

            for m=1:numel(idlist)
                if(obj.HasListPortId)
                    obj.addPortDecl(idlist{m},'inout',bitwidth,isdescending);
                else
                    obj.addNewPort(idlist{m},'inout',bitwidth,isdescending);
                end
            end
        end

        function parseOutputDecl(obj)

            obj.match(eda.internal.hdlparser.VlogToken.TAG_OUTPUT);

            [hasReg,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_REG,true);
            if(hasReg)
                obj.match(eda.internal.hdlparser.VlogToken.TAG_SIGNED,true);
                [bitwidth,isdescending]=obj.parseRange;
                idlist=obj.parseVarList;
            else
                obj.match(eda.internal.hdlparser.VlogToken.TAG_NET,true);
                obj.match(eda.internal.hdlparser.VlogToken.TAG_SIGNED,true);
                [bitwidth,isdescending]=obj.parseRange;
                idlist=obj.parseIdList;
            end

            for m=1:numel(idlist)
                if(obj.HasListPortId)
                    obj.addPortDecl(idlist{m},'output',bitwidth,isdescending);
                else
                    obj.addNewPort(idlist{m},'output',bitwidth,isdescending);
                end
            end
        end

        function[bitwidth,isdescending]=parseRange(obj)

            try
                [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_LBRK,true);
                if(r)
                    l_checkForParameter;
                    [~,tokenStr]=obj.match(eda.internal.hdlparser.VlogToken.TAG_NUMBER);
                    tmp=strrep(tokenStr,'_','');
                    msb=eval(tmp);
                    obj.match(eda.internal.hdlparser.VlogToken.TAG_COLON);
                    l_checkForParameter;
                    [~,tokenStr]=obj.match(eda.internal.hdlparser.VlogToken.TAG_NUMBER);
                    tmp=strrep(tokenStr,'_','');
                    lsb=eval(tmp);
                    obj.match(eda.internal.hdlparser.VlogToken.TAG_RBRK);
                    bitwidth=abs(msb-lsb)+1;
                    isdescending=(msb>=lsb);
                else
                    bitwidth=1;
                    isdescending=true;
                end
            catch ME
                obj.ParserInfo.addErrorEntry(ME.identifier,[obj.FileName,' : ',ME.message]);
                bitwidth=-1;
                isdescending=true;

                obj.Lexer.skipRange;
            end

            function l_checkForParameter


                look=obj.Lexer.peek;
                if(look.tag==eda.internal.hdlparser.VlogToken.TAG_ID)
                    lineNumber=obj.Lexer.getLineNumber;
                    error(message('EDALink:VlogParser:UnrecognizedSymbol',lineNumber,obj.Lexer.getToken.str,look.str));
                end
            end
        end

        function idlist=parseIdList(obj)

            [~,tokenStr]=obj.match(eda.internal.hdlparser.VlogToken.TAG_ID);
            [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_COMMA,true);
            idlist={tokenStr};
            while(r)
                [r,tokenStr]=obj.match(eda.internal.hdlparser.VlogToken.TAG_ID,true);
                if(~r)
                    break;
                else
                    idlist=[idlist,{tokenStr}];%#ok<AGROW>
                end
                [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_COMMA,true);
            end
        end


        function idlist=parseVarList(obj)
            [~,tokenStr]=obj.match(eda.internal.hdlparser.VlogToken.TAG_ID);
            idlist={tokenStr};

            [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_EQ,true);
            if(r)
                obj.Lexer.skipConstantExpr;
            end
            [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_COMMA,true);
            while(r)
                [r,tokenStr]=obj.match(eda.internal.hdlparser.VlogToken.TAG_ID,true);
                if(~r)
                    break;
                else
                    idlist=[idlist,{tokenStr}];%#ok<AGROW>
                end

                [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_EQ,true);
                if(r)
                    obj.Lexer.skipConstantExpr;
                end
                [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_COMMA,true);
            end
        end

        function parseListPortDecl(obj)
            [~,tokenStr]=obj.match(eda.internal.hdlparser.VlogToken.TAG_ID);
            obj.addNewPort(tokenStr,'',1,true);
            [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_COMMA,true);
            while(r)
                [~,tokenStr]=obj.match(eda.internal.hdlparser.VlogToken.TAG_ID);
                obj.addNewPort(tokenStr,'',1,true);
                [r,~]=obj.match(eda.internal.hdlparser.VlogToken.TAG_COMMA,true);
            end
            obj.match(eda.internal.hdlparser.VlogToken.TAG_RPAREN);
            obj.match(eda.internal.hdlparser.VlogToken.TAG_SEMICOLON);
        end





        function addNewPort(obj,name,direction,bitwidth,isdescending)
            lineNumber=obj.Lexer.getLineNumber;
            if(obj.ModuleInfo.findPort(name))
                obj.ParserInfo.addWarningEntry(...
                'EDALink:VlogParser:DuplicatePort',...
                sprintf('%s : line %d : Port "%s" has been declared',...
                obj.FileName,lineNumber,name));
                return;
            end

            obj.LineListPortId=[obj.LineListPortId,lineNumber];
            obj.ModuleInfo.addPort(name,direction,bitwidth,isdescending);
        end

        function addPortDecl(obj,name,direction,bitwidth,isdescending)
            indx=obj.ModuleInfo.findPort(name);
            if(indx)
                obj.ModuleInfo.setPortDirection(indx,direction);
                obj.ModuleInfo.setPortBitWidth(indx,bitwidth);
                obj.ModuleInfo.setRangeDescending(indx,isdescending);
            end

        end

    end

end

