function[hNewNet,hNewC]=addHDLComp(this,varargin)








    arg=hdlCompArg(varargin{:});

    hN=arg.Network;
    hC=arg.Component;
    Name=arg.HDLComponentName;
    HDLComp=arg.HDLComponent;
    BlockParam=arg.BlockParam;
    input=arg.Input;
    output=arg.Output;
    SLHandle=arg.GenerateModel;
    AddHierarchy=arg.AddHierarchy;
    HDLCompType=arg.HDLCompType;
    SimModel=arg.SimModel;
    blkComment=arg.BlockComment;

    if isa(HDLComp,'hdlcoder.network')
        if isempty(HDLComp.FullPath)
            HDLComp.Name=[hN.FullPath,'/',HDLComp.Name];
            HDLComp.FullPath=hN.FullPath;
        end
        hNetworkComp=hN.addComponent('ntwk_instance_comp',HDLComp);
        hNetworkComp.Name=Name;
        hNetworkComp.SimulinkHandle=hC.SimulinkHandle;
        this.connectHDLBlk(hNetworkComp,input,output);
    else

        if isa(HDLComp,'hdlbuiltinimpl.HDLDirectCodeGen')
            codeGenMode=HDLComp.getCodeGenMode;
        elseif~isempty(HDLCompType)
            codeGenMode=HDLCompType;
        else
            codeGenMode='emission';
        end


        if~strcmpi(codeGenMode,'instantiation')&&AddHierarchy
            [hNewNet,input,output]=this.addNewNetwork(hN,Name,input,output,hC,SLHandle);
            hNewNet.addComment(hdlformatcomment(blkComment));
            hNewNet.Name=[hN.FullPath,'/',Name];
            hNewNet.FullPath=hN.FullPath;
        else
            hNewNet=hN;
        end


        if strcmpi(codeGenMode,'cgirelaboration')
            hNewC=hNewNet.addComponent2(...
            'kind','cgireml',...
            'InputSignals',input,...
            'OutputSignals',output,...
            'Name',Name,...
            'SimulinkHandle',hC.SimulinkHandle);
            HDLComp.elaborate(hNewNet,hNewC);
        elseif strcmpi(codeGenMode,'hdlelaboration')
            block=hdlgetblocklibpath(hC.SimulinkHandle);
            hNewC=hNewNet.addComponent('block_comp',length(input),length(output),block);
            hNewC.SimulinkHandle=hC.SimulinkHandle;
            hNewC.Name=hdluniquename(Name);
            hNewC.addComment(hdlformatcomment(blkComment));

            this.connectHDLBlk(hNewC,input,output);

            if isa(HDLComp,'hdlbuiltinimpl.HDLDirectCodeGen')
                BlockParam.Name=hNewC.Name;
                HDLComp.elaborate(hNewNet,hNewC,BlockParam);
            elseif~isempty(BlockParam)
                BlockParam.Name=hNewC.Name;
                feval(HDLComp,this,hNewC,hNewNet,BlockParam);
            else
                feval(HDLComp,this,hNewC,hNewNet);
            end

        else
            if isa(HDLComp,'hdlbuiltinimpl.HDLDirectCodeGen')
                bbxStrategyType=HDLComp.getCodeGenMode;
            else
                bbxStrategyType='emission';
            end
            hNewC=hNewNet.addComponent('black_box_comp',bbxStrategyType,length(input),length(output));
            hNewC.SimulinkHandle=hC.SimulinkHandle;
            hNewC.addComment(hdlformatcomment(blkComment));

            this.initHDLComp(hNewC,Name,HDLComp,BlockParam,input,output);
        end

    end



    function compArg=hdlCompArg(varargin)

        persistent p;
        if isempty(p)
            p=inputParser;
            p.addParamValue('Network','',@isaNetWork);
            p.addParamValue('Component','',@isaComponent);
            p.addParamValue('HDLComponentName','',@isaChar);
            p.addParamValue('HDLComponent','',@isaHandle);
            p.addParamValue('Input',[],@isaSignal);
            p.addParamValue('Output',[],@isaSignal);
            p.addParamValue('HDLCompType','');
            p.addParamValue('BlockParam',[]);
            p.addParamValue('AddHierarchy',false);
            p.addParamValue('GenerateModel',-1);
            p.addParamValue('SimModel','');
            p.addParamValue('BlockComment','');
        end

        p.parse(varargin{:});
        compArg=p.Results;

        function status=isaNetWork(in)
            if isempty(in)
                status=false;
                error(message('hdlcoder:addHDLComp:NetworkRequiredArgument'));
            elseif~isa(in,'hdlcoder.network')
                status=false;
                error(message('hdlcoder:addHDLComp:NetworkTypeMismatch'));
            else
                status=true;
            end

            function status=isaComponent(in)
                if isempty(in)
                    status=false;
                    error(message('hdlcoder:addHDLComp:CompRequiredArgument'));
                elseif~(isa(in,'hdlcoder.ntwk_instance_comp')||isa(in,'hdlcoder.black_box_comp')||isa(in,'hdlcoder.block_comp'))
                    status=false;
                    error(message('hdlcoder:addHDLComp:CompTypeMismatch'));
                else
                    status=true;
                end

                function status=isaSignal(in)
                    if isempty(in)
                        status=false;
                        error(message('hdlcoder:addHDLComp:SigRequiredArgument'));
                    elseif~isa(in,'hdlcoder.signal')
                        status=false;
                        error(message('hdlcoder:addHDLComp:SigTypeMismatch'));
                    else
                        status=true;
                    end

                    function status=isaChar(in)
                        if isempty(in)
                            status=false;
                            error(message('hdlcoder:addHDLComp:CharRequiredArgument'));
                        elseif~ischar(in)
                            status=false;
                            error(message('hdlcoder:addHDLComp:CharTypeMismatch'));
                        else
                            status=true;
                        end

                        function status=isaHandle(in)
                            if isempty(in)
                                status=false;
                                error(message('hdlcoder:addHDLComp:HandleRequiredArgument'));
                            elseif~(isa(in,'function_handle')||isa(in,'hdlbuiltinimpl.HDLDirectCodeGen')||isa(in,'hdlcoder.network'))
                                status=false;
                                error(message('hdlcoder:addHDLComp:HandleTypeMismatch'));
                            else
                                status=true;
                            end
