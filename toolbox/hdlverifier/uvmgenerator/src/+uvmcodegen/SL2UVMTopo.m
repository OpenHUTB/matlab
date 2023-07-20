classdef(Hidden)SL2UVMTopo<handle


    properties(GetAccess=public,SetAccess=private)
        DG;
        Seq2ScrConnection;
        Seq2GldConnection;
        Gld2ScrConnection;
        slmodel;
        dut;
        seq;
        scr;
        drv;
        mon;
        gld;
    end

    properties(Access=private)
        SID2NodeName;
        NVPortMap;
        SeqInputRng;
    end

    properties(Access=private,Constant)




        UVMCompFcnInfo='UVMCompFcnInfo'
        ArgumentValues='ArgumentValues'
        ArgumentRanges='ArgumentRanges'
        OutputFunction='OutputFunction'
        UpdateFunction='UpdateFunction'

        ArgumentIdentifiers='ArgumentIdentifiers'
        ArgumentTypes='ArgumentTypes'
        ArgumentSizes='ArgumentSizes'
    end

    properties(Access=private,Constant)



        NoMon_W_Seq2Scr=[0,0,1,0;...
        0,0,1,1;...
        0,0,0,0;...
        1,0,0,0];

        NoMon=[0,0,1,0;...
        0,0,0,1;...
        0,0,0,0;...
        1,0,0,0];

        NoDrv_W_Seq2Scr=[0,0,0,1;...
        1,0,1,0;...
        0,0,0,0;...
        0,0,1,0];

        NoDrv=[0,0,0,1;...
        1,0,0,0;...
        0,0,0,0;...
        0,0,1,0];

        DrvMon_W_Seq2Scr=[0,0,0,0,1;...
        0,0,1,1,0;...
        0,0,0,0,0;...
        1,0,0,0,0;...
        0,0,1,0,0];


        DrvMon=[0,0,0,0,1;...
        0,0,0,1,0;...
        0,0,0,0,0;...
        1,0,0,0,0;...
        0,0,1,0,0];

        NoMon_m={{'dut','dut'},{'dut','seq'},{'dut','scr'},{'dut','drv'};...
        {'seq','dut'},{'seq','seq'},{'seq','scr'},{'seq','drv'};...
        {'scr','dut'},{'scr','seq'},{'scr','scr'},{'scr','drv'};...
        {'drv','dut'},{'drv','seq'},{'drv','scr'},{'drv','drv'}};
        NoDrv_m={{'dut','dut'},{'dut','seq'},{'dut','scr'},{'dut','mon'};...
        {'seq','dut'},{'seq','seq'},{'seq','scr'},{'seq','mon'};...
        {'scr','dut'},{'scr','seq'},{'scr','scr'},{'scr','mon'};...
        {'mon','dut'},{'mon','seq'},{'mon','scr'},{'mon','mon'}};
        DrvMon_m={{'dut','dut'},{'dut','seq'},{'dut','scr'},{'dut','drv'},{'dut','mon'};...
        {'seq','dut'},{'seq','seq'},{'seq','scr'},{'seq','drv'},{'seq','mon'};...
        {'scr','dut'},{'scr','seq'},{'scr','scr'},{'scr','drv'},{'scr','mon'};...
        {'drv','dut'},{'drv','seq'},{'drv','scr'},{'drv','drv'},{'drv','mon'};...
        {'mon','dut'},{'mon','seq'},{'mon','scr'},{'mon','drv'},{'mon','mon'}};

    end

    methods
        function obj=SL2UVMTopo(model)
            obj.slmodel=model;
            obj.dut='';
            obj.seq='';
            obj.scr='';
            obj.drv='';
            obj.mon='';
            obj.gld='';
        end

        function InitializeDG(obj,dut,seq,scr,varargin)
            p=inputParser;

            p.addRequired('dut');
            p.addRequired('seq');
            p.addRequired('scr');
            p.addParameter('drv','');
            p.addParameter('mon','');
            p.addParameter('gld','');

            p.parse(dut,seq,scr,varargin{:});
            obj.dut=p.Results.dut;
            obj.seq=p.Results.seq;
            obj.scr=p.Results.scr;
            obj.drv=p.Results.drv;
            obj.mon=p.Results.mon;
            obj.gld=p.Results.gld;
            OptionalComponents={obj.drv,obj.mon,obj.gld};
            OptionalComponents=OptionalComponents(cellfun(@(x)~isempty(x),OptionalComponents));
            [obj.DG,obj.NVPortMap]=obj.getSLTopo2UVMdigraph(dut,seq,scr,OptionalComponents{:});
            obj.SeqInputRng=obj.getSeqInputRngs(seq);

        end

        function SetNodeUVMCodeInfo(obj,NodeSID,UVMCodeInfo)


            if strcmp(Simulink.ID.getFullName(NodeSID),obj.seq)&&...
                ~isempty(obj.SeqInputRng)&&...
                all(arrayfun(@(x)~isempty(x.Min)||~isempty(x.Max),obj.SeqInputRng))&&...
                sum(strcmp('input',UVMCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentDirections))-1==numel(obj.SeqInputRng)

                UVMCodeInfo.UVMCodeInfo.SetFcnIfInfo(obj.UVMCompFcnInfo,...
                obj.ArgumentValues,[{nan},arrayfun(@(x)x.Min,obj.SeqInputRng,'UniformOutput',false)],...
                obj.OutputFunction);
                UVMCodeInfo.UVMCodeInfo.SetFcnIfInfo(obj.UVMCompFcnInfo,...
                obj.ArgumentRanges,[{struct('Min',[],'Max',[])},arrayfun(@(x)x,obj.SeqInputRng,'UniformOutput',false)],...
                obj.OutputFunction);
                UVMCodeInfo.UVMCodeInfo.SetFcnIfInfo(obj.UVMCompFcnInfo,...
                obj.ArgumentValues,[{nan},arrayfun(@(x)x.Min,obj.SeqInputRng,'UniformOutput',false)],...
                obj.UpdateFunction);
                UVMCodeInfo.UVMCodeInfo.SetFcnIfInfo(obj.UVMCompFcnInfo,...
                obj.ArgumentRanges,[{struct('Min',[],'Max',[])},arrayfun(@(x)x,obj.SeqInputRng,'UniformOutput',false)],...
                obj.UpdateFunction);
            end
            obj.DG.Nodes.UVMCodeInfo_Obj{strcmp(obj.SID2NodeName(NodeSID),obj.DG.Nodes.Name)}=UVMCodeInfo.UVMCodeInfo;
        end



        function[seqout,drvin,drvout,dutin,seqoutsz,drvinsz,drvoutsz,dutinsz]=getDriverConnectionSigId(obj)
            [seqout,drvin,drvout,dutin]=obj.getDriverConnection(obj.ArgumentIdentifiers);
            [seqoutsz,drvinsz,drvoutsz,dutinsz]=obj.getDriverConnection(obj.ArgumentSizes);
        end
        function[seqout,drvin,drvout,dutin]=getDriverConnection(obj,ValueType)
            if~isempty(obj.drv)


                Src2DstNVPortNum=obj.getSrc2DstIdx(obj.seq,obj.drv);
                [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.seq)),...
                obj.SID2NodeName(Simulink.ID.getSID(obj.drv)),...
                ValueType);
                seqout=SrcValList(Src2DstNVPortNum(:,1));
                drvin=DstValList(Src2DstNVPortNum(:,2));

                Src2DstNVPortNum=obj.getSrc2DstIdx(obj.drv,obj.dut);
                [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.drv)),...
                obj.SID2NodeName(Simulink.ID.getSID(obj.dut)),...
                ValueType);
                drvout=SrcValList(Src2DstNVPortNum(:,1));
                dutin=DstValList(Src2DstNVPortNum(:,2));
            else


                Src2DstNVPortNum=obj.getSrc2DstIdx(obj.seq,obj.dut);
                [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.seq)),...
                obj.SID2NodeName(Simulink.ID.getSID(obj.dut)),...
                ValueType);

                seqout=SrcValList(Src2DstNVPortNum(:,1));
                dutin=DstValList(Src2DstNVPortNum(:,2));

                drvin={};
                drvout={};
            end
        end




        function[dutout,monin,monout,scrin,dutoutsz,moninsz,monoutsz,scrinsz]=getMonitorConnectionSigId(obj)
            [dutout,monin,monout,scrin]=obj.getMonitorConnection(obj.ArgumentIdentifiers);
            [dutoutsz,moninsz,monoutsz,scrinsz]=obj.getMonitorConnection(obj.ArgumentSizes);
        end
        function[dutout,monin,monout,scrin]=getMonitorConnection(obj,ValueType)
            if~isempty(obj.mon)


                Src2DstNVPortNum=obj.getSrc2DstIdx(obj.dut,obj.mon);
                [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.dut)),...
                obj.SID2NodeName(Simulink.ID.getSID(obj.mon)),...
                ValueType);
                dutout=SrcValList(Src2DstNVPortNum(:,1));
                monin=DstValList(Src2DstNVPortNum(:,2));

                Src2DstNVPortNum=obj.getSrc2DstIdx(obj.mon,obj.scr);
                [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.mon)),...
                obj.SID2NodeName(Simulink.ID.getSID(obj.scr)),...
                ValueType);
                monout=SrcValList(Src2DstNVPortNum(:,1));
                scrin=DstValList(Src2DstNVPortNum(:,2));
            else


                Src2DstNVPortNum=obj.getSrc2DstIdx(obj.dut,obj.scr);
                [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.dut)),...
                obj.SID2NodeName(Simulink.ID.getSID(obj.scr)),...
                ValueType);
                dutout=SrcValList(Src2DstNVPortNum(:,1));
                scrin=DstValList(Src2DstNVPortNum(:,2));

                monin={};
                monout={};
            end
        end





        function[seqout,gldin,gldout,scrin,seqoutsz,gldinsz,gldoutsz,scrinsz]=getMonitorInputConnectionSigId(obj,type)
            [seqout,gldin,gldout,scrin]=obj.getMonitorInputConnection(obj.ArgumentIdentifiers,type);
            [seqoutsz,gldinsz,gldoutsz,scrinsz]=obj.getMonitorInputConnection(obj.ArgumentSizes,type);
        end




        function[seqoutDT,gldinDT,gldoutDT,scrinDT]=getMonitorInputConnectionDT(obj,type)
            [seqoutDT,gldinDT,gldoutDT,scrinDT]=obj.getMonitorInputConnection(obj.ArgumentTypes,type);
        end




        function[seqoutSZ,gldinSZ,gldoutSZ,scrinSZ]=getMonitorInputConnectionSZ(obj,type)
            [seqoutSZ,gldinSZ,gldoutSZ,scrinSZ]=obj.getMonitorInputConnection(obj.ArgumentSizes,type);
        end
        function res=IsScalarizePortsEnabled(obj)
            dut_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.dut))));
            res=dut_UVMCodeInfo{1}.CompPortInfo.ScalarizePortsEnabled;
        end

        function[dutDir,dutSVDT,dutSize,dutIfId]=getDutIfInfo(obj)
            dut_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.dut))));
            dutDir=dut_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end);
            dutSVDT=dut_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentTypes(2:end);
            dutSize=dut_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentSizes(2:end);
            dutIfId=dut_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(2:end);
        end

        function[gldDir,gldSVDT,gldSize,gldIfId]=getGldIfInfo(obj)
            gld_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.gld))));
            gldDir=gld_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end);
            gldSVDT=gld_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentTypes(2:end);
            gldSize=gld_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentSizes(2:end);
            gldIfId=gld_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(2:end);
        end

        function[scrDir,scrSVDT,scrSize,scrIfId]=getScrIfInfo(obj)
            scr_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.scr))));
            scrDir=scr_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end);
            scrSVDT=scr_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentTypes(2:end);
            scrSize=scr_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentSizes(2:end);
            scrIfId=scr_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(2:end);
        end


        function[seqDir,seqSVDT,seqSize,seqIfId]=getSeqIfInfo(obj)
            seq_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.seq))));
            seqDir=seq_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end);
            seqSVDT=seq_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentTypes(2:end);
            seqSize=seq_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentSizes(2:end);
            seqIfId=seq_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(2:end);
        end

        function[drvDir,drvSVDT,drvSize,drvIfId]=getDrvIfInfo(obj)
            drv_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.drv))));
            drvDir=drv_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end);
            drvSVDT=drv_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentTypes(2:end);
            drvSize=drv_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentSizes(2:end);
            drvIfId=drv_UVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentIdentifiers(2:end);
        end

        function str=getPackageNameSpace(obj,UVMComp)
            UVM_CI=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.(UVMComp)))));
            [~,str,~]=fileparts(UVM_CI{1}.UVMBuildInfo.DPIPkg);
        end

        function SeqBR=getSeqBR(obj)
            seq_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.seq))));
            SeqBR=seq_UVMCodeInfo{1}.TimingInfo.BaseRate;
        end

        function DutBR=getDutBR(obj)
            dut_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.dut))));
            DutBR=dut_UVMCodeInfo{1}.TimingInfo.BaseRate;
        end

        function ScrBR=getScrBR(obj)
            scr_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.scr))));
            ScrBR=scr_UVMCodeInfo{1}.TimingInfo.BaseRate;
        end

        function DrvBR=getDrvBR(obj)
            if isempty(obj.drv)
                DrvBR=[];
            else
                drv_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.drv))));
                DrvBR=drv_UVMCodeInfo{1}.TimingInfo.BaseRate;
            end
        end

        function MonBR=getMonBR(obj)
            if isempty(obj.mon)
                MonBR=[];
            else
                mon_UVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,obj.SID2NodeName(Simulink.ID.getSID(obj.mon))));
                MonBR=mon_UVMCodeInfo{1}.TimingInfo.BaseRate;
            end
        end
    end


    methods(Access=private)

        function Src2DstNVPortNum=getSrc2DstIdx(obj,Source,Destination)

            StartNode=obj.SID2NodeName(Simulink.ID.getSID(Source));

            EndNode=obj.SID2NodeName(Simulink.ID.getSID(Destination));


            Src2DstPortNum=[obj.DG.Edges.SrcPortNum(strcmp(obj.DG.Edges.EndNodes(:,1),StartNode)&strcmp(obj.DG.Edges.EndNodes(:,2),EndNode),:),...
            obj.DG.Edges.DstPortNum(strcmp(obj.DG.Edges.EndNodes(:,1),StartNode)&strcmp(obj.DG.Edges.EndNodes(:,2),EndNode),:)];

            if isempty(Src2DstPortNum)
                Src2DstNVPortNum=[];
            else
                Src2DstNVPortNum=obj.getSrc2DstNVPortNum(Source,Destination,Src2DstPortNum);
            end
        end


        function[SrcValList,DstValList]=getSrcAndDstValList(obj,Source,Destination,ValueType)

            SrcUVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,Source));

            SrcList=SrcUVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.(ValueType)(2:end);
            SrcDirList=SrcUVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end);


            DstUVMCodeInfo=obj.DG.Nodes.UVMCodeInfo_Obj(strcmp(obj.DG.Nodes.Name,Destination));

            DstList=DstUVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.(ValueType)(2:end);
            DstDirList=DstUVMCodeInfo{1}.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end);



            SrcValList=SrcList(strcmp(SrcDirList,'output'));
            DstValList=DstList(strcmp(DstDirList,'input'));
        end

        function[seqout,gldin,gldout,scrin]=getMonitorInputConnection(obj,ValueType,CmpType)
            seqout={};
            gldin={};
            gldout={};
            scrin={};
            switch CmpType
            case 'predictor'
                if~isempty(obj.gld)


                    Src2DstNVPortNum=obj.getSrc2DstIdx(obj.seq,obj.gld);
                    if isempty(Src2DstNVPortNum)
                        return;
                    end
                    [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.seq)),...
                    obj.SID2NodeName(Simulink.ID.getSID(obj.gld)),...
                    ValueType);
                    seqout=SrcValList(Src2DstNVPortNum(:,1));
                    gldin=DstValList(Src2DstNVPortNum(:,2));

                    Src2DstNVPortNum=obj.getSrc2DstIdx(obj.gld,obj.scr);


                    if isempty(Src2DstNVPortNum)
                        return;
                    end
                    [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.gld)),...
                    obj.SID2NodeName(Simulink.ID.getSID(obj.scr)),...
                    ValueType);
                    gldout=SrcValList(Src2DstNVPortNum(:,1));
                    scrin=DstValList(Src2DstNVPortNum(:,2));
                end
            case 'scoreboard'


                Src2DstNVPortNum=obj.getSrc2DstIdx(obj.seq,obj.scr);
                if isempty(Src2DstNVPortNum)
                    return;
                end
                [SrcValList,DstValList]=obj.getSrcAndDstValList(obj.SID2NodeName(Simulink.ID.getSID(obj.seq)),...
                obj.SID2NodeName(Simulink.ID.getSID(obj.scr)),...
                ValueType);
                seqout=SrcValList(Src2DstNVPortNum(:,1));
                scrin=DstValList(Src2DstNVPortNum(:,2));

                gldin={};
                gldout={};
            end
        end
    end

    methods(Access=private)
        function[DG,NVPortMap]=getSLTopo2UVMdigraph(obj,dut,seq,scr,varargin)
            model=obj.slmodel;

            IS='->';


            keySet=[{Simulink.ID.getSID(dut),Simulink.ID.getSID(seq),Simulink.ID.getSID(scr)},...
            cellfun(@(x)Simulink.ID.getSID(x),varargin,'UniformOutput',false)];

            valueSet=[{['DUT',IS,Simulink.ID.getSID(dut)],['SEQ',IS,Simulink.ID.getSID(seq)],['SCR',IS,Simulink.ID.getSID(scr)]},...
            cellfun(@(x)[get_param(x,'Name'),IS,Simulink.ID.getSID(x)],varargin,'UniformOutput',false)];

            obj.SID2NodeName=containers.Map(keySet,valueSet);


            g=Simulink.internal.extractBDTopoGraph(model);



            NVPortMap=obj.getNVPortNumMap(g);



            Supported_BlkNodeIdx=l_getSupportedBlkNodeIdx(g,keySet);




            NodeNames=valueSet';
            NodeTable=table(NodeNames,cell(length(obj.SID2NodeName),1),'VariableNames',...
            {'Name','UVMCodeInfo_Obj'});



            SrcPortNum2DstPortNum=[];
            EndNodesVar=cell(0);

            for SID_idx_c=keys(obj.SID2NodeName)
                SID_idx=SID_idx_c{1};

                BlkNodeIdx=l_getBlkNodeIdxFromBlkSID(g,SID_idx);















                BlkNodeIdx2PortOutIdx=g.Edges.EndNodes(strcmpi(g.Edges.Type,'BlockPortOut')&g.Edges.EndNodes(:,1)==BlkNodeIdx,:);


                PortOutIdx2PortInIdx=g.Edges.EndNodes(any(strcmpi(g.Edges.Type,'Signal')&g.Edges.EndNodes(:,1)==BlkNodeIdx2PortOutIdx(:,2)',2),:);


                PortInIdx2BlkNodeDstIdx=g.Edges.EndNodes(any(strcmpi(g.Edges.Type,'BlockPortIn')&g.Edges.EndNodes(:,1)==PortOutIdx2PortInIdx(:,2)',2),:);



                PortInIdx2BlkNodeDstIdx_f=PortInIdx2BlkNodeDstIdx(any(PortInIdx2BlkNodeDstIdx(:,2)==Supported_BlkNodeIdx,2),:);


                SrcPortNum2DstPortNum_l=zeros(length(PortInIdx2BlkNodeDstIdx_f(:,1)),2);
                EndNodesVar_l=cell(length(PortInIdx2BlkNodeDstIdx_f(:,1)),2);
                for idx_f=1:length(PortInIdx2BlkNodeDstIdx_f(:,1))


                    EndNodesVar_l{idx_f,1}=obj.SID2NodeName(SID_idx);
                    EndNodesVar_l{idx_f,2}=obj.SID2NodeName(l_getSIDFromBlkNodeIdx(g,PortInIdx2BlkNodeDstIdx_f(idx_f,2)));


                    PortInIdx2PortOutIdx_f=PortOutIdx2PortInIdx(PortOutIdx2PortInIdx(:,2)==PortInIdx2BlkNodeDstIdx_f(idx_f,1),:);
                    assert(~isempty(PortInIdx2PortOutIdx_f));
                    assert(strcmpi(get_param(g.Nodes.Handle(PortInIdx2PortOutIdx_f(1,1)),'Type'),'port'));
                    assert(strcmpi(get_param(g.Nodes.Handle(PortInIdx2PortOutIdx_f(1,2)),'Type'),'port'));
                    SrcPortNum2DstPortNum_l(idx_f,1)=get_param(g.Nodes.Handle(PortInIdx2PortOutIdx_f(1,1)),'PortNumber');
                    SrcPortNum2DstPortNum_l(idx_f,2)=get_param(g.Nodes.Handle(PortInIdx2PortOutIdx_f(1,2)),'PortNumber');

                end

                EndNodesVar=[EndNodesVar;EndNodesVar_l];%#ok<AGROW>
                SrcPortNum2DstPortNum=[SrcPortNum2DstPortNum;SrcPortNum2DstPortNum_l];%#ok<AGROW>
            end


            EdgeTable=table(EndNodesVar,SrcPortNum2DstPortNum(:,1),SrcPortNum2DstPortNum(:,2),'VariableNames',{'EndNodes','SrcPortNum','DstPortNum'});


            DG=digraph(EdgeTable,NodeTable);


            dut_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.dut));
            seq_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.seq));
            scr_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.scr));
            if~isempty(obj.drv)&&~isempty(obj.mon)&&~isempty(obj.gld)
                drv_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.drv));
                mon_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.mon));
                gld_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.gld));
            elseif~isempty(obj.drv)&&~isempty(obj.mon)&&isempty(obj.gld)
                drv_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.drv));
                mon_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.mon));
                gld_node_id='';
            elseif~isempty(obj.drv)&&isempty(obj.mon)&&~isempty(obj.gld)
                drv_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.drv));
                mon_node_id='';
                gld_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.gld));
            elseif isempty(obj.drv)&&~isempty(obj.mon)&&~isempty(obj.gld)
                drv_node_id='';
                mon_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.mon));
                gld_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.gld));
            elseif~isempty(obj.drv)&&isempty(obj.mon)&&isempty(obj.gld)
                drv_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.drv));
                mon_node_id='';
                gld_node_id='';
            elseif isempty(obj.drv)&&~isempty(obj.mon)&&isempty(obj.gld)
                drv_node_id='';
                mon_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.mon));
                gld_node_id='';
            elseif isempty(obj.drv)&&isempty(obj.mon)&&~isempty(obj.gld)
                drv_node_id='';
                mon_node_id='';
                gld_node_id=obj.SID2NodeName(Simulink.ID.getSID(obj.gld));
            else
                drv_node_id='';
                mon_node_id='';
                gld_node_id='';
            end
            obj.Seq2ScrConnection=DG.distances(seq_node_id,scr_node_id)==1;
            if isempty(gld_node_id)
                obj.Seq2GldConnection=0;
                obj.Gld2ScrConnection=0;
            else
                obj.Seq2GldConnection=DG.distances(seq_node_id,gld_node_id)==1;
                obj.Gld2ScrConnection=DG.distances(gld_node_id,scr_node_id)==1;
            end
            l_CheckBasicDGConnectivity(DG,{dut_node_id,seq_node_id,scr_node_id,drv_node_id,mon_node_id,gld_node_id});

            [vt,idx2sl]=obj.getVTopo();
            if~isempty(vt)




                gld_dc=full(adjacency(DG));
                if~isempty(obj.gld)
                    gld_dc=gld_dc(1:end-1,1:end-1);
                end
                assert(all(gld_dc==vt,'all'),...
                message('HDLLink:uvmgenerator:InvalidDrvMonTopo',...
                sprintf(['\n',char(join(arrayfun(@(x)n_getInvTopErrMsg(idx2sl{x},vt(x)),...
                find(gld_dc~=vt),...
                'UniformOutput',false),''))])));
            end

            function e_str=n_getInvTopErrMsg(sl_pair,exp)
                if exp==1


                    e_str=['\t-Direct connection between ''',...
                    obj.(sl_pair{1}),''' and ''',obj.(sl_pair{2}),''' was expected, but not found.\n'];
                else


                    e_str=['\t-Direct connection between ''',...
                    obj.(sl_pair{1}),''' and ''',obj.(sl_pair{2}),''' was not expected, but was found.\n'];
                end
            end
        end

        function[vt,idx2sl]=getVTopo(obj)
            vt=[];
            idx2sl={};
            if~isempty(obj.drv)&&~isempty(obj.mon)&&obj.Seq2ScrConnection
                vt=obj.DrvMon_W_Seq2Scr;
                idx2sl=obj.DrvMon_m;
            elseif~isempty(obj.drv)&&~isempty(obj.mon)
                vt=obj.DrvMon;
                idx2sl=obj.DrvMon_m;
            elseif~isempty(obj.drv)&&obj.Seq2ScrConnection
                vt=obj.NoMon_W_Seq2Scr;
                idx2sl=obj.NoMon_m;
            elseif~isempty(obj.mon)&&obj.Seq2ScrConnection
                vt=obj.NoDrv_W_Seq2Scr;
                idx2sl=obj.NoDrv_m;
            elseif~isempty(obj.drv)
                vt=obj.NoMon;
                idx2sl=obj.NoMon_m;
            elseif~isempty(obj.mon)
                vt=obj.NoDrv;
                idx2sl=obj.NoDrv_m;
            end
        end


        function SeqRng=getSeqInputRngs(obj,seq)

            feval(obj.slmodel,[],[],[],'compileForSizes');
            onCleanupObj=onCleanup(@()feval(obj.slmodel,[],[],[],'term'));

            ph=get_param(seq,'PortHandles');
            iph=ph.Inport;



            SeqRng=arrayfun(@(s,h)n_get_filtered_struct(s,...
            get_param(h,'CompiledPortWidth')>1,...
            strcmp(get_param(h,'CompiledBusType'),'NON_VIRTUAL_BUS'),...
            strcmp(get_param(h,'CompiledBusType'),'VIRTUAL_BUS'),...
            get_param(h,'CompiledPortComplexSignal'),...
            get_param(h,'PortNumber')),...
            struct('Min',arrayfun(@(x)n_getMinMaxValWCorrectDT(get_param(x,'CompiledPortDesignMin'),get_param(x,'CompiledPortDataType')),iph,'UniformOutput',false),...
            'Max',arrayfun(@(x)n_getMinMaxValWCorrectDT(get_param(x,'CompiledPortDesignMax'),get_param(x,'CompiledPortDataType')),iph,'UniformOutput',false)),...
            iph);

            function val=n_getMinMaxValWCorrectDT(value,dt)
                if any(strcmp(dt,{'single','double','int8','int16','int32','int64','uint8','uint16','uint32','uint64','logical'}))
                    val=cast(value,dt);
                elseif strcmp(dt,'boolean')
                    val=cast(value,'logical');
                elseif~isempty(regexp(dt,'fixdt\s*\(.*\)','once'))
                    val=fi(value,eval(dt));
                elseif contains(dt,'fix')
                    val=fi(value,fixdt(dt));
                else
                    val=value;
                end
            end

            function n_seqrng=n_get_filtered_struct(n_orig_seqrng,n_isvec,n_isnvbus,n_isvbus,n_iscmplx,n_prt_num)
                n_seqrng=n_orig_seqrng;
                if n_isvec||n_isnvbus||n_isvbus||n_iscmplx


                    if~isempty(n_seqrng.Min)||~isempty(n_seqrng.Max)



                        warning(message('HDLLink:uvmgenerator:InputPortCntrWillBeIgnored',num2str(n_prt_num)));
                    end
                    n_seqrng.Min=[];n_seqrng.Max=[];
                end
            end
        end


        function NVPortNumMap=getNVPortNumMap(obj,g)

            feval(obj.slmodel,[],[],[],'compileForSizes');
            onCleanupObj=onCleanup(@()feval(obj.slmodel,[],[],[],'term'));
            structEnabled=strcmp(get_param(obj.slmodel,'DPICompositeDataType'),'Structure');


            NVPortNumMap=containers.Map;
            for SID_idx_c=keys(obj.SID2NodeName)
                SID_idx=SID_idx_c{1};
                BlkNodeIdx=l_getBlkNodeIdxFromBlkSID(g,SID_idx);



                PortInIdx2BlkNodeIdx=g.Edges.EndNodes(strcmpi(g.Edges.Type,'BlockPortIn')&g.Edges.EndNodes(:,2)==BlkNodeIdx,:);
                if isempty(PortInIdx2BlkNodeIdx)
                    PortInIdx_It=[];
                else
                    PortInIdx_It=PortInIdx2BlkNodeIdx(:,1);
                end
                InputPortWidthArr=zeros(numel(PortInIdx_It),1);
                for inIdx=PortInIdx_It'
                    if strcmp(get_param(g.Nodes.Handle(inIdx),'CompiledBusType'),'VIRTUAL_BUS')
                        busStruct=get_param(g.Nodes.Handle(inIdx),'CompiledBusStruct');
                        BusSignals=busStruct.signals;
                        cumDim=0;
                        arrayfun(@(x)n_CalculateVirtualBusDim(x),BusSignals);
                        InputPortWidthArr(get_param(g.Nodes.Handle(inIdx),'PortNumber'))=cumDim;
                    elseif get_param(g.Nodes.Handle(inIdx),'CompiledPortComplexSignal')&&~structEnabled


                        InputPortWidthArr(get_param(g.Nodes.Handle(inIdx),'PortNumber'))=2;
                    elseif strcmp(get_param(g.Nodes.Handle(inIdx),'CompiledBusType'),'NON_VIRTUAL_BUS')&&~structEnabled

                        busObjName=get_param(g.Nodes.Handle(inIdx),'CompiledPortDataType');
                        busStruct=l_getNVBusStruct(obj.slmodel,busObjName);

                        InputPortWidthArr(get_param(g.Nodes.Handle(inIdx),'PortNumber'))=l_getNumElementForNVBus(busStruct);
                    else
                        InputPortWidthArr(get_param(g.Nodes.Handle(inIdx),'PortNumber'))=1;
                    end
                end

                InputPortWidthArr_cs=[0;cumsum(InputPortWidthArr)];



                BlkNodeIdx2PortOutIdx=g.Edges.EndNodes(strcmpi(g.Edges.Type,'BlockPortOut')&g.Edges.EndNodes(:,1)==BlkNodeIdx,:);
                if isempty(BlkNodeIdx2PortOutIdx)
                    PortOutIdx_It=[];
                else
                    PortOutIdx_It=BlkNodeIdx2PortOutIdx(:,2);
                end
                OutputPortWidthArr=zeros(numel(PortOutIdx_It),1);
                for outIdx=PortOutIdx_It'
                    if strcmp(get_param(g.Nodes.Handle(outIdx),'CompiledBusType'),'VIRTUAL_BUS')
                        busStruct=get_param(g.Nodes.Handle(outIdx),'CompiledBusStruct');
                        BusSignals=busStruct.signals;
                        cumDim=0;
                        arrayfun(@(x)n_CalculateVirtualBusDim(x),BusSignals);
                        OutputPortWidthArr(get_param(g.Nodes.Handle(outIdx),'PortNumber'))=cumDim;
                    elseif get_param(g.Nodes.Handle(outIdx),'CompiledPortComplexSignal')&&~structEnabled


                        OutputPortWidthArr(get_param(g.Nodes.Handle(outIdx),'PortNumber'))=2;
                    elseif strcmp(get_param(g.Nodes.Handle(outIdx),'CompiledBusType'),'NON_VIRTUAL_BUS')&&~structEnabled

                        busObjName=get_param(g.Nodes.Handle(outIdx),'CompiledPortDataType');
                        busStruct=l_getNVBusStruct(obj.slmodel,busObjName);

                        OutputPortWidthArr(get_param(g.Nodes.Handle(outIdx),'PortNumber'))=l_getNumElementForNVBus(busStruct);
                    else
                        OutputPortWidthArr(get_param(g.Nodes.Handle(outIdx),'PortNumber'))=1;
                    end
                end

                OutputPortWidthArr_cs=[0;cumsum(OutputPortWidthArr)];





                NVPortNumMap(SID_idx)=struct('input',{arrayfun(@(x)(InputPortWidthArr_cs(x)+1:InputPortWidthArr_cs(x+1))',(1:numel(PortInIdx_It)),'UniformOutput',false)},...
                'output',{arrayfun(@(x)(OutputPortWidthArr_cs(x)+1:OutputPortWidthArr_cs(x+1))',(1:numel(PortOutIdx_It)),'UniformOutput',false)});

            end

            function n_CalculateVirtualBusDim(n_sig)

                leafObj=get_param(n_sig.src,'Object');
                leafOutport=leafObj.PortHandles.Outport(n_sig.srcPort+1);
                if isempty(n_sig.signals)
                    if get_param(leafOutport,'CompiledPortComplexSignal')&&~structEnabled
                        cumDim=cumDim+2;
                    else
                        cumDim=cumDim+1;
                    end
                elseif~isempty(n_sig.signals)&&~isempty(n_sig.busObjectName)&&...
                    strcmp(get_param(leafOutport,'CompiledBusType'),'NON_VIRTUAL_BUS')

                    if structEnabled
                        cumDim=cumDim+1;
                    else
                        cumDim=cumDim+l_getNumElementForNVBus(l_getNVBusStruct(obj.slmodel,n_sig.busObjectName));
                    end
                else

                    NV_BusStruct=get_param(leafOutport,'CompiledBusStruct');
                    NV_BusSignals=NV_BusStruct.signals;
                    arrayfun(@(n_x)n_CalculateVirtualBusDim(n_x),NV_BusSignals);
                end
            end
        end

        function Src2DstNVPortNum=getSrc2DstNVPortNum(obj,src,dst,Src2DstPortNum)



            SrcNVPortNums_ca=obj.NVPortMap(Simulink.ID.getSID(src)).output(Src2DstPortNum(:,1)');

            DstNVPortNums_ca=obj.NVPortMap(Simulink.ID.getSID(dst)).input(Src2DstPortNum(:,2)');

            Src2DstNVPortNum=[vertcat(SrcNVPortNums_ca{:}),vertcat(DstNVPortNums_ca{:})];
        end

    end

end

function SID=l_getSIDFromBlkNodeIdx(g,BlkNodeIdx)
    SID=Simulink.ID.getSID(g.Nodes.Handle(BlkNodeIdx));
end

function Supported_BlkNodeIdx=l_getSupportedBlkNodeIdx(g,keySet)
    Supported_BlkNodeIdx=cellfun(@(x)l_getBlkNodeIdxFromBlkSID(g,x),keySet);
end

function BlkNodeIdx=l_getBlkNodeIdxFromBlkSID(g,SID_idx)
    BlkNodeIdx=find(g.Nodes.Handle==Simulink.ID.getHandle(Simulink.ID.getSID(SID_idx)));
end

function l_CheckBasicDGConnectivity(DG,slsys)

    slsysIO=cellfun(@(x)n_getslsysIO(x),slsys,'Uniformoutput',false);


    assert(all(cellfun(@(x)n_getFieldFromIO(x,'numOfGotoBlks'),slsysIO)==0)&&...
    all(cellfun(@(x)n_getFieldFromIO(x,'numOfFromBlks'),slsysIO)==0),...
    message('HDLLink:uvmgenerator:VirtualPortGoToFromNotsupported',...
    sprintf(['\n',char(join([arrayfun(@(x)getfullname(x),cell2mat(cellfun(@(x)n_getFieldFromIO(x,'gotoBlks'),slsysIO,'UniformOutput',false)),'UniformOutput',false),...
    arrayfun(@(x)getfullname(x),cell2mat(cellfun(@(x)n_getFieldFromIO(x,'fromBlks'),slsysIO,'UniformOutput',false)),'UniformOutput',false),...
    ],',\n')),'\n'])));

    function sio=n_getslsysIO(s)
        if isempty(s)
            sio=[];
        else
            sio=coder.internal.IOUtils.GetSubsystemIOPorts(Simulink.ID.getHandle(extractAfter(s,'->')));
        end
    end
    function o=n_getFieldFromIO(io,f)
        if~isempty(io)
            o=io.(f);
        elseif any(strcmp(f,{'numOfGotoBlks','numOfFromBlks'}))


            o=0;
        else


            o=[];
        end
    end



    if~isempty(slsys{4})||~isempty(slsys{5})
        return;
    end
    dut_node_id=slsys{1};
    seq_node_id=slsys{2};
    scr_node_id=slsys{3};

    [i,j,~]=find(adjacency(DG));


    seqCandidate=setdiff(i,j);
    scrCandidate=setdiff(j,i);


    if numel(seqCandidate)==1&&numel(scrCandidate)==1&&numel(i)>1
        AbleToSuggestTopo=true;
        SpecifiedTopo=sprintf('\n\tsequence: %s\n\tscoreboard: %s\n',Simulink.ID.getFullName(extractAfter(seq_node_id,'->')),Simulink.ID.getFullName(extractAfter(scr_node_id,'->')));
        SuggestedTopo=sprintf('\n\tsequence: %s\n\tscoreboard: %s\n',Simulink.ID.getFullName(extractAfter(DG.Nodes.Name{seqCandidate},'->')),Simulink.ID.getFullName(extractAfter(DG.Nodes.Name{scrCandidate},'->')));
    else
        AbleToSuggestTopo=false;
    end


    if AbleToSuggestTopo

        assert(~isempty(DG.shortestpath(seq_node_id,dut_node_id)),message('HDLLink:uvmgenerator:SeqNotConnectedToDUTSuggestTopo',SpecifiedTopo,SuggestedTopo));

        assert(~isempty(DG.shortestpath(dut_node_id,scr_node_id)),message('HDLLink:uvmgenerator:DutNotConnectedToScrSuggestTopo',SpecifiedTopo,SuggestedTopo));
    else

        assert(~isempty(DG.shortestpath(seq_node_id,dut_node_id)),message('HDLLink:uvmgenerator:SeqNotConnectedToDUT'));

        assert(~isempty(DG.shortestpath(dut_node_id,scr_node_id)),message('HDLLink:uvmgenerator:DutNotConnectedToScr'));
    end

    assert(DG.isdag(),message('HDLLink:uvmgenerator:NoFeedbackLoopsAllowed'));
end

function num=l_getNumElementForNVBus(busStruct)

    num=0;
    if numel(busStruct)>1

        busStruct=busStruct(1);
    end
    fieldNames=fieldnames(busStruct);
    for idx=1:numel(fieldNames)
        c_fieldname=fieldNames{idx};
        if isstruct(busStruct.(c_fieldname))
            num_temp=l_getNumElementForNVBus(busStruct.(c_fieldname));
        elseif~isreal(busStruct.(c_fieldname))

            num_temp=2;
        else
            num_temp=1;
        end
        num=num+num_temp;
    end
end

function struct=l_getNVBusStruct(model,busObjName)
    scope=Simulink.data.BaseWorkspace;

    if scope.exist(busObjName)
        struct=Simulink.Bus.createMATLABStruct(busObjName);
    else


        ddName=get_param(model,'DataDictionary');
        if~isempty(ddName)
            scope=Simulink.data.DataDictionary(ddName);
            if scope.exist(busObjName)
                struct=Simulink.Bus.createMATLABStruct(busObjName,[],[1,1],scope);
            else
                error(message('HDLLink:uvmgenerator:MissBusObj',busObjName));
            end
        else
            error(message('HDLLink:uvmgenerator:MissBusObj',busObjName));
        end
    end
end



