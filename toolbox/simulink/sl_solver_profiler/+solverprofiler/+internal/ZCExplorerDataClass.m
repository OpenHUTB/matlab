classdef ZCExplorerDataClass<handle
    properties(SetAccess=private)
Model
TBound
ZcInfo
RankedSigIdx
ZcEventsNumber
SigSelected
TLeft
TRight
HiliteTraceBlock
HJTableCallback
    end

    methods


        function obj=ZCExplorerDataClass(mdl,zcInfo,tSpan,tBound)
            obj.Model=mdl;
            obj.TBound=tBound;
            obj.ZcInfo=zcInfo;
            obj.RankedSigIdx=[];
            obj.SigSelected=1;
            obj.TLeft=tSpan(1);
            obj.TRight=tSpan(2);
            obj.HiliteTraceBlock=[];
            obj.HJTableCallback=[];
        end


        function delete(~)
        end


        function resetData(obj,zcInfo,tSpan,tBound)
            obj.TBound=tBound;
            obj.ZcInfo=zcInfo;
            obj.TLeft=tSpan(1);
            obj.TRight=tSpan(2);
        end


        function value=getData(obj,name)
            value=obj.(name);
        end

        function setData(obj,name,value)
            try
                obj.(name)=value;
            catch
            end
        end



        function tag=getLocationTagOfSelectedSignal(obj)
            sigIdx=obj.RankedSigIdx(obj.SigSelected);
            tag=obj.ZcInfo.getLocationTagFromSigIdx(sigIdx);
        end



        function blockName=getBlockNameOfSelectedSignal(obj)
            sigIdx=obj.RankedSigIdx(obj.SigSelected);
            blockName=obj.ZcInfo.getBlockNameFromSigIdx(sigIdx);
        end


        function sortSignals(obj)

            if obj.TLeft<obj.TBound(1)
                obj.TLeft=obj.TBound(1);
            end
            if obj.TRight>obj.TBound(2)
                obj.TRight=obj.TBound(2);
            end


            [obj.RankedSigIdx,obj.ZcEventsNumber]=...
            obj.ZcInfo.sortSignals(obj.TLeft,obj.TRight);
        end


        function tableContent=createTableContent(obj)
            tableContent=cell(length(obj.RankedSigIdx),2);


            for i=1:length(obj.RankedSigIdx)
                tableContent{i,1}=obj.ZcEventsNumber(i);
                tableContent{i,2}=obj.ZcInfo.getSignalNameFromSigIdx(...
                obj.RankedSigIdx(i));
            end
        end


        function sigIdx=getSelectedSignalIdx(obj)
            sigIdx=obj.RankedSigIdx(obj.SigSelected);
        end


        function index=getRowIndexInRankedSignalIndexList(obj,sigIdx)
            index=find(obj.RankedSigIdx==sigIdx);
        end


        function sigName=getSelectedSignalName(obj)
            sigIdx=obj.RankedSigIdx(obj.SigSelected);
            sigName=obj.ZcInfo.getSignalNameFromSigIdx(sigIdx);
        end


        function[time,value]=getSelectedSignalValue(obj)
            sigIdx=obj.RankedSigIdx(obj.SigSelected);
            [time,value]=obj.ZcInfo.getSignal(sigIdx);
        end


        function[time,value]=getSelectedSignalEvents(obj)
            sigIdx=obj.RankedSigIdx(obj.SigSelected);
            [time,value]=obj.ZcInfo.getEvents(sigIdx);
        end


        function type=getSelectedCrossingType(obj,time)
            sigIdx=obj.RankedSigIdx(obj.SigSelected);
            type=obj.ZcInfo.getCrossingType(sigIdx,time);
        end

    end

end