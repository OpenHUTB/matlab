function[hNewNet,hNewC]=defHDLComp(this,varargin)






    arg=defCompArg(varargin{:});

    Name=arg.HDLComponentName;
    HDLComp=arg.HDLComponent;
    BlockParam=arg.BlockParam;
    input=arg.Input;
    output=arg.Output;
    SLHandle=arg.GenerateModel;
    blkComment=arg.BlockComment;


    if isa(HDLComp,'hdlbuiltinimpl.HDLDirectCodeGen')
        bbxStrategyType=HDLComp.getCodeGenMode;
    else
        bbxStrategyType='emission';
    end


    input=createPort(input);
    output=createPort(output);

    [hNewNet,input,output]=this.addNewNetwork([],Name,input,output,[],-1,'declare');
    hNewNet.addComment(hdlformatcomment(blkComment));


    if strcmpi(bbxStrategyType,'cgirelaboration')

        hNewC=hNewNet.addComponent2(...
        'kind','cgir',...
        'InputSignals',input,...
        'OutputSignals',output,...
        'Name',Name,...
        'SimulinkHandle',SLHandle);
        HDLComp.elaborate(hNewNet,hNewC);

    elseif strcmpi(bbxStrategyType,'hdlelaboration')

        block='';
        hNewC=hNewNet.addComponent('block_comp',length(input),length(output),block);
        hNewC.Name=hdluniquename(Name);
        hNewC.addComment(hdlformatcomment(blkComment));
        hNewC.SimulinkHandle=SLHandle;
        BlockParam.Name=hNewC.Name;
        this.connectHDLBlk(hNewC,input,output);
        HDLComp.elaborate(hNewNet,hNewC,BlockParam);

    else

        hNewC=hNewNet.addComponent('black_box_comp',bbxStrategyType,length(input),length(output));
        hNewC.SimulinkHandle=-1;
        hNewC.addComment(hdlformatcomment(blkComment));

        this.initHDLComp(hNewC,[Name,'Inst'],HDLComp,BlockParam,input,output);
    end


    function port=createPort(port)

        portStruct=struct('Name','',...
        'Type',[],...
        'VType','',...
        'Imag','',...
        'SimulinkHandle',-1,...
        'SimulinkRate',-1);
        tmp(1:length(port)/2)=portStruct;
        for i=1:2:length(port)
            k=floor(i/2)+1;
            tmp(k).Name=port{i};
            tmp(k).Type=port{i+1};
            tmp(k).VType='';
            tmp(k).Imag='';
        end

        for i=1:length(tmp)
            if isa(tmp(i).Type,'hdlcoder.signal')
                hT=tmp(i).Type.Type;
                tmp(i).VType=tmp(i).Type.VType;
                tmp(i).Imag=tmp(i).Type.Imag;
                tmp(i).SimulinkHandel=tmp(i).Type.SimulinkHandle;
                tmp(i).SimulinkRate=tmp(i).Type.SimulinkRate;
                tmp(i).Type=hT;
            else
                type=hdlgetallfromsltype(tmp(i).Type.type);
                hT=getpirsignaltype(type.sltype,tmp(i).Type.complex,tmp(i).Type.dim);
                tmp(i).VType=type.vtype;
                tmp(i).Imag=[];
                tmp(i).Type=hT;
            end
        end
        port=tmp;



        function compArg=defCompArg(varargin)

            persistent p;
            if isempty(p)
                p=inputParser;
                p.addParameter('HDLComponentName','',@isaChar);
                p.addParameter('HDLComponent','',@isaHandle);
                p.addParameter('Input',[],@isaSignal);
                p.addParameter('Output',[],@isaSignal);
                p.addParameter('BlockParam',[]);
                p.addParameter('GenerateModel',-1);
                p.addParameter('BlockComment','');
            end

            p.parse(varargin{:});
            compArg=p.Results;

            function status=isaSignal(in)
                if isempty(in)
                    status=false;
                    error(message('hdlcoder:defHDLComp:SigRequiredArgument'));
                elseif~isa(in,'cell')
                    status=false;
                    error(message('hdlcoder:defHDLComp:SigTypeMismatch'));
                else
                    status=true;
                end

                function status=isaChar(in)
                    if isempty(in)
                        status=false;
                        error(message('hdlcoder:defHDLComp:CharRequiredArgument'));
                    elseif~ischar(in)
                        status=false;
                        error(message('hdlcoder:defHDLComp:CharTypeMismatch'));
                    else
                        status=true;
                    end

                    function status=isaHandle(in)
                        if isempty(in)
                            status=false;
                            error(message('hdlcoder:defHDLComp:HandleRequiredArgument'));
                        elseif~(isa(in,'function_handle')||isa(in,'hdlbuiltinimpl.HDLDirectCodeGen'))
                            status=false;
                            error(message('hdlcoder:defHDLComp:HandleTypeMismatch'));
                        else
                            status=true;
                        end
