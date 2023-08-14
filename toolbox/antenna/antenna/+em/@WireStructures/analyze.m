function status=analyze(obj,frequency,ElemNumber,buildOnlyFlag)

    status=0;

    if nargin==2||isempty(ElemNumber)
        voltagesDiag=[];
    else
        voltagesDiag=ismember(1:size(obj.FeedLocation,1),ElemNumber);
    end
    if nargin~=4
        buildOnlyFlag=false;
    end

    if isempty(voltagesDiag)
        if obj.Medium.EMSolObj.ExVecObj.NExVecs>1
            obj.Medium.EMSolObj.ResetExVec(1);
        end
    elseif obj.Medium.EMSolObj.ExVecObj.NExVecs~=...
        length(voltagesDiag)
        obj.Medium.EMSolObj.ResetExVec(length(voltagesDiag));
    end


    wireStack.checkFrequency(frequency);



    if~isempty(obj.Medium.EMSolObj.Freqs)
        if max(frequency)>max(obj.Medium.EMSolObj.Freqs)
            obj.MesherStruct.HasMeshChanged=true;
        else
            numcalculations=sum(~ismembertol(frequency,...
            obj.Medium.EMSolObj.Freqs,eps(max(frequency)),'DataScale',1));
        end
        freqIndToRemove=~ismembertol(obj.Medium.EMSolObj.Freqs,...
        frequency,eps(max(obj.Medium.EMSolObj.Freqs)),...
        'DataScale',1);
        obj.Medium.EMSolObj.RemoveFreqs(freqIndToRemove);


        for wireInd=1:length(obj.WiresInt)
            obj.WiresInt{wireInd}.Freqs=obj.Medium.EMSolObj.Freqs;
        end
    else
        numcalculations=length(frequency);
    end



    if strcmpi(obj.MesherStruct.MeshingChoice,'Auto')
        [~,~]=getMesh(obj,max(frequency));
    else
        [~,~]=getMesh(obj);





        minLambda=obj.Medium.Lambda(max(frequency));
        radii=cellfun(@(x)x.SegmentRadius,obj.WiresInt);



        if any(radii>em.WireStructures.maxr2lambda*minLambda)
            ApproxBrokenMsg=message(...
            'antenna:antennaerrors:ThinWireApproxInvalid').string;
            warning(message(...
            'antenna:antennaerrors:WireRadiusTooLargeForWavelength',...
            num2str(em.WireStructures.maxr2lambda),...
            num2str(em.WireStructures.maxr2lambda*minLambda),...
            ApproxBrokenMsg));
        end
    end


    if obj.MesherStruct.HasMeshChanged||obj.checkHasStructureChanged
        obj.SolverStruct.Solution.Directivity=[];
        obj.SolverStruct.Solution.Dirfreq=[];
        obj.SolverStruct.Solution.theta=[];
        obj.SolverStruct.Solution.phi=[];
        obj.SolverStruct.Solution.cep=[];
        obj.SolverStruct.Solution.pol=[];
        numcalculations=length(frequency);
    end

    if isequal(obj.MesherStruct.DisplayWaitBar,1)
        obj.MesherStruct.DisplayWaitBar=0;
    end

    if(isempty(obj.hwait)&&((numcalculations>2)||...
        (numcalculations>0&&...
        obj.MesherStruct.Mesh.numParts>100)))&&...
        ~buildOnlyFlag
        msg=sprintf('Populating matrices for %d/%d wire parts',...
        1,obj.MesherStruct.Mesh.numParts);
        if numcalculations>2
            hwait=waitbar(0,msg,'Name','Frequency sweep',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        else
            hwait=waitbar(0,msg,'Name','Solution progress',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        end
        setappdata(hwait,'canceling',0);
        setappdata(hwait,'partInd',1);
        setappdata(hwait,'numParts',obj.MesherStruct.Mesh.numParts);
        obj.hwait=hwait;
    else
        hwait=[];
    end
    if buildOnlyFlag
        initLastArg='BuildOnly';
    else
        initLastArg=hwait;
    end

    for wireInd=1:length(obj.WiresInt)
        vInd=(obj.FeedWireIntInd==wireInd);
        if isempty(vInd)||...
            ~isa(obj.WiresInt{wireInd},'em.wire.solver.DeltaGapPECWire')
            obj.WiresInt{wireInd}.Initialize(obj.Medium,...
            reshape(frequency,1,1,[]),initLastArg);
            if~isempty(hwait)&&getappdata(hwait,'canceling')
                break
            end
        else
            if isempty(voltagesDiag)
                if length(obj.FeedVoltage)==1
                    feedVoltage=obj.FeedVoltage*ones(size(vInd));
                else
                    feedVoltage=obj.FeedVoltage;
                end
                if length(obj.FeedPhase)==1
                    feedPhase=obj.FeedPhase*pi/180*ones(size(vInd));
                else
                    feedPhase=obj.FeedPhase*pi/180;
                end
                [x,y]=pol2cart(feedPhase.',feedVoltage.');
                voltages=complex(x,y);
                vOnWire=voltages(vInd);
            else
                voltages=diag(voltagesDiag);
                vOnWire=voltages(vInd,:);
            end
            if all(size(vOnWire)==...
                size(obj.WiresInt{wireInd}.Voltages))&&...
                all(vOnWire==...
                obj.WiresInt{wireInd}.Voltages)
                obj.WiresInt{wireInd}.Initialize(obj.Medium,[],...
                reshape(frequency,1,1,[]),initLastArg);
                if~isempty(hwait)&&getappdata(hwait,'canceling')
                    break
                end
            else
                obj.WiresInt{wireInd}.Initialize(obj.Medium,...
                vOnWire,reshape(frequency,1,1,[]),initLastArg);
                if~isempty(hwait)&&getappdata(hwait,'canceling')
                    break
                end
            end
        end
    end

    if~buildOnlyFlag
        initLastArg=[];
    end
    for extraConnInd=1:length(obj.ExtraConns)
        if obj.WiresInt{wireInd}.UpdateWaitBar(hwait)
            break;
        end
        obj.ExtraConnsInt{extraConnInd}.Initialize(obj.Medium,...
        reshape(frequency,1,1,[]),[],[],initLastArg);
    end
    resetHasMeshChanged(obj);



    if(~isempty(hwait)&&~getappdata(hwait,'canceling'))&&...
        numcalculations==1
        obj.hwait=[];
        delete(hwait);
        hwait=[];
    end

    if buildOnlyFlag
        return
    end




    if(~isempty(hwait)&&getappdata(hwait,'canceling'))||...
        (isempty(obj.Medium.Solve(hwait))&&numcalculations>0)

        setHasStructureChanged(obj)
        status=1;
    end


    if~isempty(hwait)
        obj.hwait=[];
        delete(hwait);
    end
end