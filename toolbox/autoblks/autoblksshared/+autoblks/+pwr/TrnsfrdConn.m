classdef(Hidden)TrnsfrdConn<handle




    properties
        PwrTrnsfrdData autoblks.pwr.Signal


        EnrgyBalanceRelTol=0.01;
        EnrgyBalanceAbsTol=0.01;
    end


    properties(SetAccess=private)
        PortName cell
        Parent autoblks.pwr.PlantInfo

        PwrChildSrc autoblks.pwr.TrnsfrdConn
        PwrPortConn autoblks.pwr.TrnsfrdConn
        PwrBlkConn autoblks.pwr.TrnsfrdConn
    end


    properties(Dependent=true)
PortHdl
OriginPortHdl
OriginPwrTrnsfrdConn
FinalDstPwrTrnsfrdConn
    end


    methods

        function obj=TrnsfrdConn(Parent,PortName)
            PortName=cellstr(PortName);
            obj.PortName=PortName;
            obj.Parent=Parent;
            obj.PwrChildSrc=autoblks.pwr.TrnsfrdConn.empty;
            obj.PwrPortConn=autoblks.pwr.TrnsfrdConn.empty;
            obj.PwrBlkConn=autoblks.pwr.TrnsfrdConn.empty;
        end


        function addPwrPortConn(obj,NewPwrConn)
            if~obj.isPwrConnListed(obj.PwrPortConn,NewPwrConn)
                obj.PwrPortConn(end+1)=NewPwrConn;
                NewPwrConn.addPwrChildSrc(obj);
                for i=1:length(NewPwrConn.PwrBlkConn)
                    obj.addPwrPortConn(NewPwrConn.PwrBlkConn(i));
                end
                obj.PwrPortConn=obj.uniqueTrnsfrdConn(obj.PwrPortConn);
            end
        end

        function addPwrBlkConn(obj,NewPwrConn)
            if~obj.isPwrConnListed(obj.PwrBlkConn,NewPwrConn)
                obj.PwrBlkConn(end+1)=NewPwrConn;
                NewPwrConn.addPwrBlkConn(obj);
                for i=1:length(NewPwrConn.PwrBlkConn)
                    obj.addPwrBlkConn(NewPwrConn.PwrBlkConn(i));
                end
                obj.PwrBlkConn=obj.uniqueTrnsfrdConn(obj.PwrBlkConn);
            end
        end


        function addPwrChildSrc(obj,NewPwrConn)
            if~obj.isPwrConnListed(obj.PwrChildSrc,NewPwrConn)
                obj.PwrChildSrc(end+1)=NewPwrConn;
                NewPwrConn.addPwrPortConn(obj);
                for i=1:length(NewPwrConn.PwrBlkConn)
                    obj.addPwrChildSrc(NewPwrConn.PwrBlkConn(i));
                end
                obj.PwrChildSrc=obj.uniqueTrnsfrdConn(obj.PwrChildSrc);
            end
        end


        function removeAllConns(obj)
            for i=1:length(obj.PwrChildSrc)
                obj.PwrChildSrc(i).removeSelectConn(obj);
            end
            for i=1:length(obj.PwrBlkConn)
                obj.PwrBlkConn(i).removeSelectConn(obj);
            end
            for i=1:length(obj.PwrPortConn)
                obj.PwrPortConn(i).removeSelectConn(obj);
            end
        end

        function flag=isConnEnrgyBalanced(obj)
            ConnPortData=[obj.OriginPwrTrnsfrdConn.PwrTrnsfrdData,obj.FinalDstPwrTrnsfrdConn.PwrTrnsfrdData];
            flag=autoblksIsEnrgyBalanced(obj.uniqueTrnsfrdConn(ConnPortData),[],obj.EnrgyBalanceRelTol,obj.EnrgyBalanceAbsTol);
        end


        function PortHdl=get.PortHdl(obj)

            PortInfo=autoblksgetportinfo(get_param(obj.Parent.SysName,'Handle'));
            AllPortNames={PortInfo.Inports.Name,PortInfo.Outports.Name,PortInfo.LConns.Name,PortInfo.RConns.Name};
            AllPortHdls=[PortInfo.Inports.Hdl,PortInfo.Outports.Hdl,PortInfo.LConns.Hdl,PortInfo.RConns.Hdl];
            [~,IA]=intersect(AllPortNames,obj.PortName);
            PortHdl=AllPortHdls(IA);
        end


        function PortHdl=get.OriginPortHdl(obj)
            PwrTrnsfrdConnObj=obj.OriginPwrTrnsfrdConn;
            PortHdl=[PwrTrnsfrdConnObj.PortHdl];
        end


        function PwrTrnsfrdConnObj=get.OriginPwrTrnsfrdConn(obj)
            if~isempty(obj.PwrChildSrc)
                PwrTrnsfrdConnObj=obj.getChildOriginPwrTrnsfrdConns;
            else
                PwrTrnsfrdConnObj=obj;
            end
        end


        function FinalDstPwrTrnsfrdConn=get.FinalDstPwrTrnsfrdConn(obj)
            FinalDstPwrTrnsfrdConn=obj.getAllFinalDstPwrTrnsfrdConn;
        end


        function set.PortName(obj,Name)
            obj.PortName=cellstr(Name);
        end


    end


    methods(Access=private)

        function isListed=isPwrConnListed(obj,ConnList,CompareConn)
            isListed=false;
            ConnList=[obj,ConnList];
            for i=1:length(ConnList)
                if isequal(ConnList(i),CompareConn)
                    isListed=true;
                    break;
                end
            end
        end


        function Val=uniqueTrnsfrdConn(obj,TrnsfrdConnVals)
            RemoveIdx=[];
            for i=1:length(TrnsfrdConnVals)
                if~ismember(i,RemoveIdx)
                    for j=(i+1):length(TrnsfrdConnVals)
                        if isequal(TrnsfrdConnVals(i),TrnsfrdConnVals(j))
                            RemoveIdx=[RemoveIdx,j];
                        end
                    end
                end
            end
            KeepIdx=setxor(1:length(TrnsfrdConnVals),RemoveIdx);
            Val=TrnsfrdConnVals(KeepIdx);
        end


        function PwrTrnsfrdConnObj=getChildOriginPwrTrnsfrdConns(obj)
            if~isempty(obj.PwrChildSrc)
                PwrTrnsfrdConnObj=obj.PwrChildSrc(1).getChildOriginPwrTrnsfrdConns;
                for i=2:length(obj.PwrChildSrc)
                    PwrTrnsfrdConnObj=[PwrTrnsfrdConnObj,obj.PwrChildSrc(i).getChildOriginPwrTrnsfrdConns];
                end
            else
                PwrTrnsfrdConnObj=obj;
            end
        end


        function removeSelectConn(obj,Conn)

            RemoveIdx=[];
            for i=1:length(obj.PwrChildSrc)
                for j=1:length(Conn)
                    if isequal(obj.PwrChildSrc(i),Conn(j))
                        RemoveIdx=[RemoveIdx,i];
                    end
                end
            end
            obj.PwrChildSrc=obj.PwrChildSrc(setxor(1:length(obj.PwrChildSrc),RemoveIdx));


            RemoveIdx=[];
            for i=1:length(obj.PwrBlkConn)
                for j=1:length(Conn)
                    if isequal(obj.PwrBlkConn(i),Conn(j))
                        RemoveIdx=[RemoveIdx,i];
                    end
                end
            end
            obj.PwrBlkConn=obj.PwrBlkConn(setxor(1:length(obj.PwrBlkConn),RemoveIdx));


            RemoveIdx=[];
            for i=1:length(obj.PwrPortConn)
                for j=1:length(Conn)
                    if isequal(obj.PwrPortConn(i),Conn(j))
                        RemoveIdx=[RemoveIdx,i];
                    end
                end
            end
            obj.PwrPortConn=obj.PwrPortConn(setxor(1:length(obj.PwrPortConn),RemoveIdx));
        end



        function FinalDstPwrTrnsfrdConn=getAllFinalDstPwrTrnsfrdConn(obj)
            FinalDstPwrTrnsfrdConn=obj.PwrBlkConn;
            if~isempty(obj.PwrBlkConn)
                FinalDstPwrTrnsfrdConn=[FinalDstPwrTrnsfrdConn.OriginPwrTrnsfrdConn];
            end
            for i=1:length(obj.PwrPortConn)
                FinalDstPwrTrnsfrdConn=[FinalDstPwrTrnsfrdConn,obj.PwrPortConn(i).getAllFinalDstPwrTrnsfrdConn];
            end
        end
    end
end
