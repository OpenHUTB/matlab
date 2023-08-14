function refCon=getActualRefCon(workspace,currentInputRefCon,clientID)




    if refConIsPreset(currentInputRefCon.ReferenceConstellation)
        if ischar(currentInputRefCon.AverageReferencePower)
            [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.AverageReferencePower);
            AveragePower=varargout{1};
        else
            AveragePower=currentInputRefCon.AverageReferencePower;
        end
        if ischar(currentInputRefCon.ReferencePhaseOffSet)
            [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.ReferencePhaseOffSet);
            PhaseOffset=varargout{1};
        else
            PhaseOffset=currentInputRefCon.ReferencePhaseOffSet;
        end
        refConPower=AveragePower;
        refConOffset=PhaseOffset;
        if any(strcmp(currentInputRefCon.ReferenceConstellation,{'BPSK',getString(message('comm:ConstellationVisual:BPSK'))}))


            refCon={refConPower*constellation(comm.BPSKModulator('PhaseOffset',refConOffset)).'};

        elseif any(strcmp(currentInputRefCon.ReferenceConstellation,{'QPSK',getString(message('comm:ConstellationVisual:QPSK'))}))

            refCon={refConPower*constellation(comm.QPSKModulator('PhaseOffset',refConOffset)).'};

        elseif any(strcmp(currentInputRefCon.ReferenceConstellation,{'8-PSK',getString(message('comm:ConstellationVisual:PSK8'))}))

            refCon={refConPower*constellation(comm.PSKModulator('PhaseOffset',refConOffset)).'};

        else
            if any(strcmp(currentInputRefCon.ReferenceConstellation,{'16-QAM',getString(message('comm:ConstellationVisual:QAM16'))}))

                modulationOrder=16;
            elseif any(strcmp(currentInputRefCon.ReferenceConstellation,{'64-QAM',getString(message('comm:ConstellationVisual:QAM64'))}))

                modulationOrder=64;
            elseif any(strcmp(currentInputRefCon.ReferenceConstellation,{'256-QAM',getString(message('comm:ConstellationVisual:QAM256'))}))

                modulationOrder=256;
            end
            normalizationMethod=currentInputRefCon.ConstellationNormalization;
            if strcmp(normalizationMethod,'MinimumDistance')||strcmp(normalizationMethod,'MinDistance')
                MinDistance=refConPower;
            elseif strcmp(normalizationMethod,'AveragePower')
                MinDistance=comm.internal.qam.minDistanceForAvgPower(refConPower,modulationOrder);
            elseif strcmp(normalizationMethod,'PeakPower')
                MinDistance=comm.internal.qam.minDistanceForPeakPower(refConPower,modulationOrder);
            end
            refCon={(MinDistance/2).*exp(1i*refConOffset).*qammod((0:modulationOrder-1),modulationOrder,'bin')};
        end
        refCon=refCon{1};
    else
        value=comm.scopes.evaluateExpression(workspace,currentInputRefCon.RefConstellationValue,clientID);
        refCon={value};
    end
end

function isPreset=refConIsPreset(varargin)




    NonQAMpresets={'BPSK',getString(message('comm:ConstellationVisual:BPSK')),...
    'QPSK',getString(message('comm:ConstellationVisual:QPSK')),...
    '8-PSK',getString(message('comm:ConstellationVisual:PSK8'))};
    qamPresets={'16-QAM',getString(message('comm:ConstellationVisual:QAM16')),...
    '64-QAM',getString(message('comm:ConstellationVisual:QAM64')),...
    '256-QAM',getString(message('comm:ConstellationVisual:QAM256'))};
    mustBeQAM=false;
    refCon=varargin{1};
    if nargin==3&&strcmp(varargin{2},'QAM')
        mustBeQAM=true;
    end
    if isa(refCon,'double')
        refCon=mat2str(refCon);
    end
    if mustBeQAM&&ismember(refCon,qamPresets)
        isPreset=true;
    elseif~mustBeQAM&&(ismember(refCon,[qamPresets,NonQAMpresets]))
        isPreset=true;
    else
        isPreset=false;
    end
end