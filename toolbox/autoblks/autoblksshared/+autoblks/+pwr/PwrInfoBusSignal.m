classdef(Hidden)PwrInfoBusSignal<autoblks.pwr.Signal




    properties(SetAccess=private,Hidden=true)
        ParentPwrInfoBus autoblks.pwr.PwrInfoBus


        NameLineHdl double

    end



    methods


        function obj=PwrInfoBusSignal(DestPortHdl,Parent)


            if~isa(Parent,'autoblks.pwr.PwrInfoBus')
                obj.ParentPwrInfoBus=Parent.ParentPwrInfoBus;
                obj.Parent=Parent;
            else
                obj.ParentPwrInfoBus=Parent;
                obj.Parent=Parent;
            end


            SignalHierarchy=obj.GetSignalHierarchy(DestPortHdl);
            if~isempty(SignalHierarchy)
                ChildSignalHierarchy=SignalHierarchy.Children;
                obj.Name=SignalHierarchy.SignalName;

                LineHdl=get_param(DestPortHdl,'Line');
                SrcPortHdl=get_param(LineHdl,'SrcPortHandle');
                SearchSrcPorts=get_param(get_param(SrcPortHdl,'Line'),'SourceOutputPorts');
                DestPorts=-ones(size(SearchSrcPorts));
                SrcPorts=DestPorts;
                SrcBlks=get_param(SearchSrcPorts,'Parent');
                idx=1;
                for i=1:(length(SearchSrcPorts)-1)
                    LineHdl=get_param(SearchSrcPorts(i),'Line');
                    NewDestPorts=get_param(LineHdl,'DstPortHandle');
                    DestBlks=get_param(NewDestPorts,'Parent');
                    [~,IA]=intersect(DestBlks,SrcBlks);
                    NewDestPorts=NewDestPorts(IA);
                    for j=1:length(NewDestPorts)
                        DestPorts(idx)=NewDestPorts(j);
                        SrcPorts(idx)=SearchSrcPorts(i);
                        idx=idx+1;
                    end
                end
                DestPorts(idx)=DestPortHdl;
                SrcPorts(idx)=SrcPortHdl;
                DestPorts=DestPorts(ishandle(DestPorts));
                SrcPorts=SrcPorts(ishandle(SrcPorts));

                CurrHierarchyMatch=false(size(SrcPorts));
                CurrNameMatch=false(size(SrcPorts));
                ChildHierarchyMatch=false(length(SrcPorts),length(ChildSignalHierarchy));
                ChildNameMatch=ChildHierarchyMatch;

                for i=1:length(DestPorts)
                    DestLineHdl(i)=get_param(DestPorts(i),'Line');
                    SrcLineNames=get_param(DestLineHdl(i),'Name');
                    DestSignalHierarchy=obj.GetSignalHierarchy(DestPorts(i));
                    if isequal(DestSignalHierarchy,SignalHierarchy)
                        CurrHierarchyMatch(i)=true;
                        if strcmp(SrcLineNames,obj.Name)
                            CurrNameMatch(i)=true;
                        end
                    end

                    for j=1:length(ChildSignalHierarchy)
                        if isequal(DestSignalHierarchy,ChildSignalHierarchy(j))
                            ChildHierarchyMatch(i,j)=true;
                            if strcmp(SrcLineNames,ChildSignalHierarchy(j).SignalName)
                                ChildNameMatch(i,j)=true;
                            end

                        end
                    end
                end


                if any(CurrNameMatch)
                    obj.NameLineHdl=DestLineHdl(CurrNameMatch);
                    obj.NameLineHdl=obj.NameLineHdl(end);
                else
                    MatchDestLineHdl=DestLineHdl(CurrHierarchyMatch);
                    if~isempty(MatchDestLineHdl)
                        obj.NameLineHdl=MatchDestLineHdl(end);
                    end
                end


                obj.Children=eval([class(obj),'.empty']);
                idxChild=1;
                for j=1:length(ChildSignalHierarchy)
                    if any(ChildNameMatch(:,j))
                        ChildDestPortHdl=DestPorts(ChildNameMatch(:,j));
                        if~isempty(ChildDestPortHdl)
                            ChildDestPortHdl=ChildDestPortHdl(end);
                        end
                    else
                        ChildDestPortHdl=DestPorts(ChildHierarchyMatch(:,j));
                        if~isempty(ChildDestPortHdl)
                            ChildDestPortHdl=ChildDestPortHdl(end);
                        end
                    end
                    if~isempty(ChildDestPortHdl)
                        obj.Children(idxChild)=feval(eval(['@',class(obj)]),ChildDestPortHdl,obj);
                        idxChild=idxChild+1;
                    end
                end


                if ishandle(obj.NameLineHdl)
                    obj.Description=obj.getDescLine(1);
                else
                    obj.Description='';
                end
            end
        end


        function SignalSummary=getSignalSummary(obj)
            if isempty(obj)
                SignalSummary=struct('FullName',{},'Name',{},'Description',{},'NameLineHdl',{});
            else
                SignalSummary.FullName=obj.FullSignalName;
                SignalSummary.Name=obj.Name;
                SignalSummary.Description=obj.Description;
                SignalSummary.NameLineHdl=obj.NameLineHdl;

                for i=1:length(obj.Children)
                    SignalSummary=[SignalSummary;obj.Children(i).getSignalSummary];
                end
            end
        end


        function Val=getDataObj(obj)
            Val=autoblks.pwr.Signal;
            Val.Name=obj.Name;
            Val.Description=obj.Description;
            Val.FullSignalName=obj.FullSignalName;
            Val.PwrData=obj.PwrData;
            Val.EnrgyData=obj.EnrgyData;
            Val.FinalEnrgyData=obj.FinalEnrgyData;
            Val.Children=autoblks.pwr.Signal.empty;
            for i=1:length(obj.Children)
                Val.Children(i)=obj.Children(i).getDataObj;
            end
            Val.PwrUnits=obj.PwrUnits;
            Val.EnrgyUnits=obj.EnrgyUnits;
            Val.Parent=autoblks.pwr.PlantInfo.empty;
        end


        function saveSignalInfo(obj,FullSignalNames,SignalDesc,SignalName)
            if nargin<4
                SignalName=[];
            end
            SignalSummary=obj.getSignalSummary;
            [~,IA,IB]=intersect({SignalSummary.FullName},FullSignalNames,'stable');
            for i=1:length(IA)
                LineHdl=SignalSummary(IA(i)).NameLineHdl;
                if ishandle(LineHdl)
                    if~isempty(SignalName)
                        set_param(LineHdl,'Description',[SignalDesc{IB(i)},newline,SignalName{IB(i)}]);
                    else
                        set_param(LineHdl,'Description',SignalDesc{IB(i)});
                    end
                end
            end
        end


        function s=getDescLine(obj,LineNum)
            if nargin<2
                LineNum=[];
            end
            s='';
            DescVal=get_param(obj.NameLineHdl,'Description');
            if isempty(LineNum)
                s=DescVal;
            else
                NewLineLoc=[0,strfind(DescVal,newline),length(DescVal)+1];
                if length(NewLineLoc)>LineNum
                    StrLoc=[NewLineLoc(LineNum)+1,NewLineLoc(LineNum+1)-1];
                    if StrLoc(2)>=StrLoc(1)
                        s=DescVal(StrLoc(1):StrLoc(2));
                    end
                end
            end
        end

    end
end

