function estimateInitialEmR0(psObj,varargin)













































    p=inputParser;
    p.addParameter('SetEmConstraints',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('EstimateEm',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('EstimateR0',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});


    SetEmConstraints=p.Results.SetEmConstraints;
    EstimateEm=p.Results.EstimateEm;
    EstimateR0=p.Results.EstimateR0;


    for psIdx=1:numel(psObj)


        Param=psObj(psIdx).Parameters;


        socIdx=getSocIdxForPulses(psObj(psIdx));



        for pIdx=1:psObj(psIdx).NumPulses
            thisIdx=sort(socIdx([pIdx,pIdx+1]));
            psObj(psIdx).Pulse(pIdx).Parameters.Em=Param.Em(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.EmMin=Param.EmMin(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.EmMax=Param.EmMax(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.R0=Param.R0(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.R0Min=Param.R0Min(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.R0Max=Param.R0Max(:,thisIdx);
        end


        psObj(psIdx).Pulse.estimateInitialEmR0(...
        'SetEmConstraints',SetEmConstraints,...
        'EstimateEm',EstimateEm,...
        'EstimateR0',EstimateR0);


        PParam=[psObj(psIdx).Pulse.Parameters];
        AllEm=reshape([PParam.Em],2,[]);
        AllR0=reshape([PParam.R0],2,[]);




        switch psObj(psIdx).TestType
        case 'discharge'
            AllEm=[
            AllEm(2,1),AllEm(1,:)
            AllEm(2,:),AllEm(1,end)
            ];
            AllR0=[
            AllR0(2,1),AllR0(1,:)
            AllR0(2,:),AllR0(1,end)
            ];
        case 'charge'
            AllEm=[
            AllEm(1,:),AllEm(2,end)
            AllEm(1,1),AllEm(2,:)
            ];
            AllR0=[
            AllR0(2,1),AllR0(1,:)
            AllR0(2,:),AllR0(1,end)
            ];
        otherwise
            error(getString(message('autoblks:autoblkErrorMsg:errTest')));
        end
        AllEm=mean(AllEm,1);
        AllR0=mean(AllR0,1);





        if EstimateEm
            Param.Em(:,socIdx)=AllEm;


            if SetEmConstraints
                Param.EmMin(socIdx(1))=Param.Em(socIdx(1))-1e-6;
                Param.EmMax(socIdx(1))=Param.Em(socIdx(1))+1e-6;
            end
        end



        if EstimateR0
            Param.R0(:,socIdx)=AllR0;
        end



        psObj(psIdx).Parameters=Param;

    end

