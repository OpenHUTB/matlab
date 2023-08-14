classdef syncAssembler<handle

    properties(Access=private)
        m_format;
    end

    properties(Access=public)
        m_code;
        m_maxPCNum;
    end

    methods(Access=public,Hidden=true)
        function obj=syncAssembler(format,maxPCNum)
            obj.m_format=format;
            obj.m_code=[];
            obj.m_maxPCNum=maxPCNum;
        end
    end

    methods(Access=public)
        function out=buildFromFile(this,fileName)
            out=this.build(fileread(fileName));
        end

        function out=build(this,scripts)
            this.m_code=[];
            lines=strsplit(scripts,'\n');
            parsedLines=struct('label',{},'code',{});

            symbolMap=containers.Map('KeyType','char','ValueType','any');

            for i=1:length(lines)
                line=lines{i};

                t=regexpi(line,'\s*');
                if(isempty(t))
                    continue;
                end



                t=regexpi(line,'\s*def\s+([a-zA-Z_]+\w*)\s+([+-]?\w+)\s*(\\\\(.*))*','tokens');
                if(~isempty(t))
                    symbolMap(t{1}{1})=dnnfpga.processorbase.syncAssembler.parseNum(t{1}{2});
                    continue;
                end



                t=regexpi(line,'(\s*[a-zA-Z_]+\w*\s*:)?\s*([a-zA-Z]+\(.*\))?\s*(\\\\(.*))*','tokens');
                assert(~isempty(t),'incorrect script: %s',line);
                l.label=strip(t{1}{1}(1:end-1));
                l.code=t{1}{2};
                if(~isempty(l.code))
                    parsedLines(end+1)=l;
                    if(~isempty(l.label))
                        symbolMap(l.label)=length(parsedLines)-1;
                    end
                end
            end



            if length(parsedLines)>this.m_maxPCNum
                msg=message('dnnfpga:dnnfpgacompiler:SyncInstNumExceedMaxValue',...
                length(parsedLines),...
                this.m_maxPCNum);
                error(msg);
            end

            instIR=struct('cmd',{},'pv',{});
            for i=1:length(parsedLines)
                code=parsedLines(i).code;



                t=regexpi(code,'([a-zA-Z]+)\((.*)\)','tokens');
                assert(~isempty(t),'incorrect script: %s',code);
                inst.cmd=t{1}{1};
                args=t{1}{2};




                t=regexpi(args,'(''[\w%]+''),*','tokens');
                assert(mod(length(t),2)==0,'incorrect script: %s',code);
                pv=struct('p',{},'v',{});
                for j=1:length(t)/2
                    pv(j).p=t{(j-1)*2+1}{1};
                    v=t{j*2}{1};
                    [tt,~]=regexpi(v,'\s*%([a-zA-Z]+\w*)','tokens');
                    if(~isempty(tt))
                        v=dnnfpga.processorbase.syncAssembler.resolve(v,symbolMap);
                    end
                    pv(j).v=v;
                end
                inst.pv=pv;
                instIR(i)=inst;
            end

            for i=1:length(instIR)
                inst=instIR(i);













                evalStr=sprintf('this.emit_%s(',inst.cmd);
                for j=1:length(inst.pv)
                    pv=inst.pv(j);
                    v=pv.v;
                    if(isnumeric(v))
                        assert(v==floor(v),'value (%f) is not an integer.',v);
                        v=num2str(v);
                    end
                    assert(ischar(v));
                    if(j==1)
                        evalStr=sprintf('%s%s, %s',evalStr,pv.p,v);
                    else
                        evalStr=sprintf('%s, %s, %s',evalStr,pv.p,v);
                    end
                end
                evalStr=sprintf('%s);',evalStr);
                eval(evalStr);
            end
            out=this.m_code;
        end

        function instruction=emit_Call(this,varargin)
            p=inputParser;
            addParameter(p,'func',[]);
            parse(p,varargin{:});
            func=dnnfpga.processorbase.syncAssembler.parseNum(p.Results.func);
            assert(~isempty(func),'func is not specified');
            format=this.m_format;

            opBits=fi(format.opCodeCall,0,format.opMax-format.opMin,0);
            funcBits=fi(func,0,format.funcMax-format.funcMin,0);
            sw0=bitconcat(funcBits,opBits);
            sw1=fi(0,0,format.instructionW-format.funcMax,0);
            instruction=bitconcat(sw1,sw0);
            this.m_code(end+1)=instruction.uint32;
        end

        function instruction=emit_Goto(this,varargin)
            p=inputParser;
            addParameter(p,'id',[]);
            addParameter(p,'delta',[]);
            addParameter(p,'newpc',[]);
            parse(p,varargin{:});
            id=dnnfpga.processorbase.syncAssembler.parseNum(p.Results.id);
            assert(~isempty(id),'id is not specified');
            delta=dnnfpga.processorbase.syncAssembler.parseNum(p.Results.delta);
            assert(~isempty(delta),'delta is not specified');
            newpc=dnnfpga.processorbase.syncAssembler.parseNum(p.Results.newpc);
            assert(~isempty(newpc),'newpc is not specified');
            format=this.m_format;

            opBits=fi(format.opCodeGoto,0,format.opMax-format.opMin,0);
            idBits=fi(id,0,format.idMax-format.idMin,0);
            deltaBits=fi(delta,0,format.deltaMax-format.deltaMin,0);
            newPCBits=fi(newpc,0,format.newPCMax-format.newPCMin,0);
            sw0=bitconcat(idBits,opBits);
            sw1=deltaBits;
            sw2=bitconcat(sw1,sw0);
            sw3=fi(0,0,format.instructionW-format.newPCMax,0);
            sw4=bitconcat(sw3,newPCBits);
            instruction=bitconcat(sw4,sw2);
            this.m_code(end+1)=instruction.uint32;
        end

        function instruction=emit_Return(this,varargin)
            p=inputParser;
            format=this.m_format;

            opBits=fi(format.opCodeReturn,0,format.opMax-format.opMin,0);
            sw1=fi(0,0,format.instructionW-format.opMax,0);
            instruction=bitconcat(sw1,opBits);
            this.m_code(end+1)=instruction.uint32;
        end

        function instruction=emit_Reset(this,varargin)
            p=inputParser;
            format=this.m_format;

            opBits=fi(format.opCodeReset,0,format.opMax-format.opMin,0);
            sw1=fi(0,0,format.instructionW-format.opMax,0);
            instruction=bitconcat(sw1,opBits);
            this.m_code(end+1)=instruction.uint32;
        end

        function instruction=emit_Set(this,varargin)
            p=inputParser;
            addParameter(p,'id',[]);
            addParameter(p,'limit',[]);
            parse(p,varargin{:});
            id=dnnfpga.processorbase.syncAssembler.parseNum(p.Results.id);
            assert(~isempty(id),'id is not specified');
            limit=dnnfpga.processorbase.syncAssembler.parseNum(p.Results.limit);
            assert(~isempty(limit),'limit is not specified');
            format=this.m_format;

            opBits=fi(format.opCodeSet,0,format.opMax-format.opMin,0);
            idBits=fi(id,0,format.idMax-format.idMin,0);
            limitBits=fi(limit,0,format.limitMax-format.limitMin,0);
            sw0=bitconcat(idBits,opBits);
            sw1=fi(0,0,format.limitMin-format.idMax,0);
            sw2=bitconcat(limitBits,sw1);
            sw3=fi(0,0,format.instructionW-format.limitMax,0);
            sw4=bitconcat(sw2,sw0);
            instruction=bitconcat(sw3,sw4);
            this.m_code(end+1)=instruction.uint32;
        end

        function instruction=emit_SW(this,varargin)

            p=inputParser;
            addParameter(p,'s',[]);
            addParameter(p,'w',[]);

            addParameter(p,'wlogic','and',@(x)assert(strcmpi(x,'and')||strcmpi(x,'or'),'wlogic must be either ''and'' or ''or''.'));
            parse(p,varargin{:});
            s=dnnfpga.processorbase.syncAssembler.parseNum(p.Results.s);
            assert(~isempty(s),'s is not specified');
            w=dnnfpga.processorbase.syncAssembler.parseNum(p.Results.w);
            assert(~isempty(w),'w is not specified');
            wlogic=p.Results.wlogic;


            format=this.m_format;

            sBits=fi(s,0,format.sMax-format.sMin,0);
            wBits=fi(w,0,format.wMax-format.wMin,0);
            switch(upper(wlogic))
            case 'AND'
                op2c='0';
            case 'OR'
                op2c='1';
            otherwise
                assert(false);
            end
            op2Bits=fi(dnnfpga.processorbase.syncAssembler.parseNum(op2c),0,format.op2Max-format.op2Min,0);
            opBits=fi(format.opCodeSW,0,format.opMax-format.opMin,0);
            sw0=bitconcat(sBits,opBits);
            sw1=bitconcat(op2Bits,wBits);
            sw2=bitconcat(sw1,sw0);
            sw3=fi(0,0,format.instructionW-format.op2Max,0);
            instruction=bitconcat(sw3,sw2);
            this.m_code(end+1)=instruction.uint32;
        end








    end

    methods(Access=public,Static=true)
        function out=parseNum(in)
            if(isnumeric(in)&&(in==floor(in)))
                out=in;
            elseif(ischar(in))
                in=strip(in);
                in=strrep(in,'_','');
                if(regexpi(in,'^0(x|X)[a-fA-F0-9]+$'))
                    in=in(3:end);
                    out=hex2dec(in);
                elseif(regexpi(in,'^[0-9]+$'))
                    in=str2double(in);
                    if(in==floor(in))
                        out=in;
                    else
                        assert(false,'input must be integer instead of %f.',in);
                    end
                else
                    assert(false,'input must be integer or decimal/hex integer string rather than ''%s''.',in);
                end
            else
                assert(false,'input must be integer or decimal/hex integer string.');
            end
        end

        function v=resolve(v,symbolMap)
            t=regexpi(v,'''%([a-zA-Z]+\w*)''','tokens');
            if(~isempty(t))
                s=t{1}{1};
                assert(symbolMap.isKey(s),'symbol ''%s'' hasn''t been defined',s);
                v=symbolMap(s);
            end
        end

        function str2file(str,fileName)
            fid=fopen(fileName,'w');

            if fid==-1
                error(message('dnnfpga:workflow:FileOpenFail',string(fileName)));
            end
            fprintf(fid,'%s',str);
            fclose(fid);
        end
    end

end