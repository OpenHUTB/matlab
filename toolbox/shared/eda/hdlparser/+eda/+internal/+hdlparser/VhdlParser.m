


classdef(Sealed)VhdlParser<eda.internal.hdlparser.HdlParser


    properties

    end

    methods

        function obj=VhdlParser(filename,entityname)


            obj=obj@eda.internal.hdlparser.HdlParser(filename,entityname);
            identifier='[a-zA-Z][a-zA-Z0-9_]*';
            tmp=regexp(entityname,identifier,'match','once');
            assert(strcmp(tmp,entityname),'EDALink:VHDLParser:InvalidEntityName','Invalid entity name. It must be a valid VHDL identifier.');
        end

        function[moduleinfo,parserinfo,codeinfo]=parse(obj)



            import eda.internal.hdlparser.*



            moduleinfo=VhdlEntityInfo;
            parserinfo=HdlParserInfo;
            codeinfo=RTW.ComponentInterface;


            obj.ModuleInfo=moduleinfo;
            obj.ParserInfo=parserinfo;
            obj.CodeInfo=codeinfo;

            try

                fid=fopen(obj.FileName,'r');
                assert(fid~=-1,'EDALink:VHDLParser:OpenFileFailure',...
                'Cannot open file %s',obj.FileName);
                hdlText=fread(fid,'uint8=>char')';
                fclose(fid);
                obj.Lexer=VhdlLexer(hdlText);





                obj.Lexer.preProcessing;

                obj.Lexer.findEntity(obj.ModuleName);





                obj.match(VhdlToken.TAG_IS);


                look=obj.Lexer.peek;
                if(look.tag==VhdlToken.TAG_GENERIC)
                    genericStartIndx=look.endindx-6;
                    obj.match(VhdlToken.TAG_GENERIC);
                    obj.match(VhdlToken.TAG_LPAREN);
                    genericDeclr=obj.Lexer.skipGenericDeclr(genericStartIndx);
                    obj.ModuleInfo.setGenericDeclr(genericDeclr);
                    obj.match(VhdlToken.TAG_SEMICOLON);
                end


                look=obj.Lexer.peek;
                if(look.tag==VhdlToken.TAG_END)
                    obj.ParserInfo.addInfoEntry('NoPortClause',...
                    sprintf('No port clause in entity declaration "%s"',obj.ModuleName));
                    return;
                end


                obj.match(VhdlToken.TAG_PORT);
                obj.match(VhdlToken.TAG_LPAREN);


                obj.parseInterfaceElement;
                r=true;
                while(r)
                    [r,~]=obj.match(VhdlToken.TAG_SEMICOLON,true);

                    if(r)
                        obj.parseInterfaceElement;
                    end
                end

                obj.match(VhdlToken.TAG_RPAREN);
                obj.match(VhdlToken.TAG_SEMICOLON);


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
                        HDLType.Identifier=sprintf('std_logic_vector(%d DOWNTO 0)',portBitwidth);
                    else
                        HDLType.Identifier=sprintf('std_logic_vector(0 DOWNTO %d)',portBitwidth);
                    end
                    cType=coder.types.Type.createCoderType(HDLType);
                    HDLImpl=RTW.Variable(cType,portName,obj.ModuleName);
                    dataInterface=RTW.DataInterface('',portName,HDLImpl,RTW.TimingInterface.empty);

                    if strcmp(portDirection,'in')
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
                    obj.ParserInfo.addErrorEntry(ME.identifier,...
                    sprintf('File %s: %s',obj.FileName,ME.message));
                end
            end
        end
    end

    methods(Access=private)

        function new_id=addMessageID(~,id)
            new_id=['EDALink:VHDLParser:',id];
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
                lineNumber=obj.Lexer.getLineNumber;

                error(message('EDALink:VHDLParser:UnexpectedToken',lineNumber,token.str,eda.internal.hdlparser.VhdlToken.tag2str(tag)));
            end
        end

        function parseInterfaceElement(obj)
            import eda.internal.hdlparser.VhdlToken

            obj.match(VhdlToken.TAG_SIGNAL,true);

            [~,portId]=obj.match(VhdlToken.TAG_ID,false);
            portIdList={portId};
            r=true;

            while(r)
                [r,~]=obj.match(VhdlToken.TAG_COMMA,true);
                if(r)

                    [~,portId]=obj.match(VhdlToken.TAG_ID,false);
                    portIdList=[portIdList,{portId}];%#ok<AGROW>
                end
            end

            obj.match(eda.internal.hdlparser.VhdlToken.TAG_COLON);


            look=obj.Lexer.peek;
            switch(look.tag)
            case{VhdlToken.TAG_IN,VhdlToken.TAG_OUT,VhdlToken.TAG_INOUT,VhdlToken.TAG_BUFFER,VhdlToken.TAG_LINKAGE}
                mode=look.str;
                obj.match(look.tag);
            otherwise
                mode='in';
            end

            [subtype,bitwidth,isdescending]=parseSubtype(obj);
            for m=1:numel(portIdList)
                obj.addNewPort(portIdList{m},subtype,mode,bitwidth,isdescending);
            end
        end

        function[subtype,bitwidth,isdescending]=parseSubtype(obj)
            bitwidth=-1;
            isdescending=true;


            [~,subtype]=obj.match(eda.internal.hdlparser.VhdlToken.TAG_ID);

            switch(subtype)
            case{'std_logic','bit'}
                bitwidth=1;
                isdescending=true;

            case{'std_logic_vector','bit_vector','signed','unsigned'}
                [bitwidth,isdescending]=parseRange(obj);
            otherwise
                token=obj.Lexer.getToken;
                lineNumber=obj.Lexer.getLineNumber;
                obj.ParserInfo.addErrorEntry(...
                'EDALink:VHDLParser:UnexpectedToken',...
                sprintf('line %d: near "%s", found unsupported data-type "%s"',...
                lineNumber,token.str,subtype));
                obj.Lexer.skipStaticExpr;
                return;
            end

            obj.match(eda.internal.hdlparser.VhdlToken.TAG_BUS,true);

            [r,~]=obj.match(eda.internal.hdlparser.VhdlToken.TAG_COLONEQ,true);
            if(r)
                obj.Lexer.skipStaticExpr;
            end
        end

        function[bitwidth,isdescending]=parseRange(obj)
            isdescending=true;
            bitwidth=-1;

            obj.match(eda.internal.hdlparser.VhdlToken.TAG_LPAREN);

            try
                l_checkForGeneric;

                [~,tokenStr]=obj.match(eda.internal.hdlparser.VhdlToken.TAG_NUMBER);
                tmp=strrep(tokenStr,'_','');
                msb=eval(tmp);

                [r,~]=obj.match(eda.internal.hdlparser.VhdlToken.TAG_TO,true);

                if(~r)
                    obj.match(eda.internal.hdlparser.VhdlToken.TAG_DOWNTO);
                    isdescending=true;
                else
                    isdescending=false;
                end
                l_checkForGeneric;

                [~,tokenStr]=obj.match(eda.internal.hdlparser.VhdlToken.TAG_NUMBER);
                tmp=strrep(tokenStr,'_','');
                lsb=eval(tmp);

                if(((msb<lsb)&&isdescending)||((msb>lsb)&&~isdescending))
                    if(isdescending)
                        rangedirection='downto';
                    else
                        rangedirection='to';
                    end
                    lineNumber=obj.Lexer.getLineNumber;
                    obj.ParserInfo.addWarningEntry('EDALink:VHDLParser:NullRange',...
                    sprintf('File %s: line %d: range "%d %s %d" defines a null range',...
                    obj.FileName,lineNumber,msb,rangedirection,lsb));
                    bitwidth=0;
                else
                    bitwidth=abs(msb-lsb)+1;
                end

                obj.match(eda.internal.hdlparser.VhdlToken.TAG_RPAREN);
            catch ME
                if(strfind(ME.identifier,'hdlparser'))
                    obj.ParserInfo.addErrorEntry(ME.identifier,...
                    sprintf('%s : %s',obj.FileName,ME.message));

                    obj.Lexer.skipStaticExpr(1);
                else
                    rethrow(ME);
                end
            end

            function l_checkForGeneric


                look=obj.Lexer.peek;
                if(look.tag==eda.internal.hdlparser.VhdlToken.TAG_ID)
                    lineNumber=obj.Lexer.getLineNumber;
                    error(message('EDALink:VHDLParser:UnrecognizedSymbol',obj.FileName,lineNumber,obj.Lexer.getToken.str,look.str));
                end
            end
        end







        function addNewPort(obj,name,type,direction,bitwidth,isdescending)
            if(obj.ModuleInfo.findPort(name))
                obj.ModuleInfo=obj.ModuleInfo.addErrorEntry(...
                'EDALink:VHDLParser:DuplicatePort',...
                sprintf('File %s : line %d : Port %s has been declared',...
                obj.FileName,obj.Lexer.getLineNumber,name));
                return;
            end
            obj.ModuleInfo.addPort(name,type,direction,bitwidth,isdescending);
        end

    end
end

