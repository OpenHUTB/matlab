function createPulses(psObj,varargin)






























































    p=inputParser;
    p.addParameter('CurrentOnThreshold',0.025,@(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    p.addParameter('NumRCBranches',3,@(x)validateattributes(x,{'numeric'},{'integer','scalar','>=',1,'<=',5}));
    p.addParameter('PreBufferSamples',10,@(x)validateattributes(x,{'numeric'},{'nonnegative','integer','scalar'}));
    p.addParameter('PostBufferSamples',15,@(x)validateattributes(x,{'numeric'},{'nonnegative','integer','scalar'}));
    p.addParameter('PulseRequires2Samples',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('RCBranchesUse2TimeConstants',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});


    CurrentOnThreshold=p.Results.CurrentOnThreshold;
    NumRCBranches=p.Results.NumRCBranches;
    PreBufferSamples=p.Results.PreBufferSamples;
    PostBufferSamples=p.Results.PostBufferSamples;
    PulseRequires2Samples=p.Results.PulseRequires2Samples;
    RCBranchesUse2TimeConstants=p.Results.RCBranchesUse2TimeConstants;





    for psIdx=1:numel(psObj)





        if isempty(psObj(psIdx).Data)
            error(getString(message('autoblks:autoblkErrorMsg:errDataEmpty')));
        end





        NumSamples=size(psObj(psIdx).Data,1);






        [idxDchLoad,idxDchRelax]=i_findDchPulseEdges(psObj(psIdx).Current,...
        CurrentOnThreshold,PulseRequires2Samples);
        [idxChgLoad,idxChgRelax]=i_findChgPulseEdges(psObj(psIdx).Current,...
        CurrentOnThreshold,PulseRequires2Samples);


        idxLoad=sortrows([idxChgLoad;idxDchLoad]);
        idxRelax=sortrows([idxChgRelax;idxDchRelax]);


        NumPulses=size(idxLoad,1);


        psObj(psIdx).Pulse(:)=[];


        for pIdx=1:NumPulses


            pObj=Battery.Pulse(psObj(psIdx));


            idx1=max(idxLoad(pIdx,1)-PreBufferSamples,1);
            idx2=min(idxRelax(pIdx,2)+PostBufferSamples,NumSamples);


            ThisData=psObj(psIdx).Data(idx1:idx2,:);


            ThisData(:,1)=ThisData(:,1)-ThisData(1,1);


            pObj.Data=ThisData;
            pObj.idxPulseSequence=idx1;


            pObj.InitialCapVoltage=zeros(1,NumRCBranches);


            pObj.InitialChargeDeficit=psObj(psIdx).Capacity*(1-ThisData(1,5));


            pObj.idxLoad=idxLoad(pIdx,:)-idx1+1;
            pObj.idxRelax=idxRelax(pIdx,:)-idx1+1;


            pObj.IsDischarge=diff(pObj.PulseSOCRange([1,2]))<0;


            pObj.Parameters=Battery.Parameters(2,NumRCBranches,RCBranchesUse2TimeConstants);



            pObj.Parameters.SOC=sort(pObj.PulseSOCRange);


            psObj(psIdx).Pulse(pIdx,1)=pObj;

        end


        psObj(psIdx).populatePulseParameters();

    end





    function[idxLoad,idxRelax]=i_findDchPulseEdges(current,Threshold,PulseRequires2Samples)


        NumSamples=numel(current);


        IsCurrentOn=abs(current)>Threshold;


        if PulseRequires2Samples
            IsCurrentOn=IsCurrentOn&([IsCurrentOn(2:end);true]|[true;IsCurrentOn(1:end-1)]);
        end


        IsTransition=[false;diff(IsCurrentOn)];


        idxEdge=find(IsTransition~=0);


        IsEdgeUnderLoad=abs(current(idxEdge))>Threshold;
        IsEdgeUnderDchLoad=current(idxEdge)<-Threshold;


        IsPriorEdgeDchLoad=circshift(IsEdgeUnderDchLoad,1);IsPriorEdgeDchLoad(1)=0;
        IsEdgeDchRelax=~IsEdgeUnderLoad&IsPriorEdgeDchLoad;


        idxEdgeisDchLoad=find(IsEdgeUnderDchLoad);
        idxEdgeisDchRelax=find(IsEdgeDchRelax);



        idxEdge(end+1)=NumSamples+1;


        idxLoad=[idxEdge(idxEdgeisDchLoad),idxEdge(idxEdgeisDchLoad+1)-1];
        idxRelax=[idxEdge(idxEdgeisDchRelax),idxEdge(idxEdgeisDchRelax+1)-1];



        function[idxLoad,idxRelax]=i_findChgPulseEdges(current,Threshold,PulseRequires2Samples)


            NumSamples=numel(current);


            IsCurrentOn=abs(current)>Threshold;


            if PulseRequires2Samples
                IsCurrentOn=IsCurrentOn&([IsCurrentOn(2:end);true]|[true;IsCurrentOn(1:end-1)]);
            end


            IsTransition=[false;diff(IsCurrentOn)];


            idxEdge=find(IsTransition~=0);


            IsEdgeUnderLoad=abs(current(idxEdge))>Threshold;
            IsEdgeUnderChgLoad=current(idxEdge)>Threshold;


            IsPriorEdgeChgLoad=circshift(IsEdgeUnderChgLoad,1);IsPriorEdgeChgLoad(1)=0;
            IsEdgeChgRelax=~IsEdgeUnderLoad&IsPriorEdgeChgLoad;


            idxEdgeisChgLoad=find(IsEdgeUnderChgLoad);
            idxEdgeisChgRelax=find(IsEdgeChgRelax);



            idxEdge(end+1)=NumSamples+1;


            idxLoad=[idxEdge(idxEdgeisChgLoad),idxEdge(idxEdgeisChgLoad+1)-1];
            idxRelax=[idxEdge(idxEdgeisChgRelax),idxEdge(idxEdgeisChgRelax+1)-1];

