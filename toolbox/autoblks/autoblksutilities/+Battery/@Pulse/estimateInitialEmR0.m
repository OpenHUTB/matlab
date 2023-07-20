function estimateInitialEmR0(pObj,varargin)












































    p=inputParser;
    p.addParameter('SetEmConstraints',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('EstimateEm',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('EstimateR0',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});


    SetEmConstraints=p.Results.SetEmConstraints;
    EstimateEm=p.Results.EstimateEm;
    EstimateR0=p.Results.EstimateR0;


    for pIdx=1:numel(pObj)


        Param=pObj(pIdx).Parameters(end);





        vf=pObj(pIdx).Voltage(pObj(pIdx).idxRelax(end));


        idxData=[
        pObj(pIdx).idxLoad(1)-1,pObj(pIdx).idxLoad(1)
        pObj(pIdx).idxLoad(2),pObj(pIdx).idxRelax(1)
        ];


        vt=pObj(pIdx).Voltage(idxData);
        it=pObj(pIdx).Current(idxData);


        dVt=diff(vt,[],2);
        dIt=diff(it,[],2);



        Em=[vt(1,1),vf];



        R0=-(dVt./dIt)';





        if pObj(pIdx).IsDischarge
            Em=fliplr(Em);
            R0=fliplr(R0);
        end


        Em=max(min(Em,Param.EmMax),Param.EmMin);
        R0=max(min(R0,Param.R0Max),Param.R0Min);


        if EstimateEm
            Param.Em=Em;
        end
        if EstimateR0
            Param.R0=R0;
        end





        if SetEmConstraints
            if pObj(pIdx).IsDischarge
                Param.EmMin(1)=Em(2)-0.001;
            else
                Param.EmMax(2)=Em(2)+0.001;
            end
        end


        pObj(pIdx).Parameters=Param;

    end

