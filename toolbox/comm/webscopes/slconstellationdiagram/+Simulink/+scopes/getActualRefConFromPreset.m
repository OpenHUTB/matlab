function value=getActualRefConFromPreset(refconStr,normalization,avgpower,peakPower,minDis,phaseoffset,isStringReturn)





    try
        [refConValArray,~,~]=uiservices.evaluate(strrep(strrep(refconStr,'''''',''''),';',','));
        if~iscell(refConValArray)
            refConValArray={refConValArray};
        end
        if any(contains(refconStr,["PSK","QAM"]))
            numele=length(refConValArray);
            if~strcmp(normalization,"none")
                [normValArray,~,~]=uiservices.evaluate(strrep(normalization,'''''',''''));
                if isempty(normValArray)&&ischar(normalization)
                    normValArray=normalization;
                end
                if~iscell(normValArray)
                    normValArray={normValArray};
                end
            else
                [normValArray{1:numele}]=deal('AveragePower');
            end
            [PwrOrMinDisVaueArray{1:numele}]=deal(1);
            [PwrOrMinDisVaueArray{strcmpi(normValArray,'MinDistance')}]=deal(2);
            if~strcmp(peakPower,"none")
                [peakPowerArray,~,~]=uiservices.evaluate(strrep(peakPower,'''''',''));
                if~iscell(peakPowerArray)
                    peakPowerArray={peakPowerArray};
                end
                [PwrOrMinDisVaueArray{strcmpi(normValArray,'PeakPower')}]=deal(peakPowerArray{strcmpi(normValArray,'PeakPower')});
            end

            if~strcmp(minDis,"none")
                [minDisArray,~,~]=uiservices.evaluate(strrep(minDis,'''''',''));
                if~iscell(minDisArray)
                    minDisArray={minDisArray};
                end
                [PwrOrMinDisVaueArray{strcmpi(normValArray,'MinDistance')}]=deal(minDisArray{strcmpi(normValArray,'MinDistance')});
            end
            if~strcmp(avgpower,"none")
                [avgPowerArray,~,~]=uiservices.evaluate(strrep(avgpower,'''''',''));
                if~iscell(avgPowerArray)
                    avgPowerArray={avgPowerArray};
                end
                [PwrOrMinDisVaueArray{strcmpi(normValArray,'AveragePower')}]=deal(avgPowerArray{strcmpi(normValArray,'AveragePower')});
            end


            if strcmp(phaseoffset,"pi/4")


                [phaseoffsetArray{1:numele}]=deal('pi/4');
            elseif~strcmp(phaseoffset,"none")

                [phaseoffsetArray,~,~]=uiservices.evaluate(strrep(phaseoffset,'''''',''));
                if~iscell(phaseoffsetArray)
                    phaseoffsetArray={phaseoffsetArray};
                end
            else

                [phaseoffsetArray{1:numele}]=deal('0');
                [phaseoffsetArray{strcmpi(refConValArray,'QPSK')}]=deal('pi/4');
                [phaseoffsetArray{strcmpi(refConValArray,'8-PSK')}]=deal('pi/8');
            end
            value=cell(length(refConValArray),0);
            for idx=1:length(refConValArray)
                if contains(refConValArray{idx},["PSK","QAM"])
                    currentInputRefCon.ReferenceConstellation=refConValArray{idx};
                    currentInputRefCon.ConstellationNormalization=normValArray{idx};
                    currentInputRefCon.AverageReferencePower=PwrOrMinDisVaueArray{idx};
                    currentInputRefCon.ReferencePhaseOffSet=phaseoffsetArray{idx};
                    value{idx}=getActualRefCon(currentInputRefCon);
                else
                    value{idx}=str2num(refConValArray{idx});
                end
            end
        else
            value=refConValArray;
        end
        if(isStringReturn)
            if length(value)>1||~isempty(value{1})
                refConStr=[];
                for idx=1:length(value)
                    delim=',';
                    if(idx==length(value))
                        delim=[];
                    end
                    value{idx}=reshape(value{idx},1,numel(value{idx}));
                    refConStr=[refConStr,'[',num2str(value{idx}),']',delim];%#ok<AGROW>
                end
                value=['{',refConStr,'}'];
            else
                value=refconStr;
            end
        else
            if length(value)==1&&iscell(value)
                value=value{1};
            end
        end

    catch
        if isStringReturn
            value='[0.7071+0.7071i  -0.7071+0.7071i  -0.7071-0.7071i   0.7070-0.7071i]';
        else
            value=[0.7071+0.7071i,-0.7071+0.7071i,-0.7071-0.7071i,0.7070-0.7071i];
        end
    end
end
function refCon=getActualRefCon(currentInputRefCon)




    if refConIsPreset(currentInputRefCon.ReferenceConstellation)
        if ischar(currentInputRefCon.AverageReferencePower)
            [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.AverageReferencePower);
            this.Specification.AveragePower=varargout{1};
        else
            this.Specification.AveragePower=currentInputRefCon.AverageReferencePower;
        end
        if ischar(currentInputRefCon.ReferencePhaseOffSet)
            [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.ReferencePhaseOffSet);
            this.Specification.PhaseOffset=varargout{1};
        else
            this.Specification.PhaseOffset=currentInputRefCon.ReferencePhaseOffSet;
        end
        refConPower=this.Specification.AveragePower;
        refConOffset=this.Specification.PhaseOffset;
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
            this.Specification.ConstellationNormalization=currentInputRefCon.ConstellationNormalization;
            normalizationMethod=this.Specification.ConstellationNormalization;
            if strcmp(normalizationMethod,'MinimumDistance')||strcmp(normalizationMethod,'MinDistance')
                this.Specification.MinDistance=refConPower;
            elseif strcmp(normalizationMethod,'AveragePower')
                this.Specification.MinDistance=comm.internal.qam.minDistanceForAvgPower(refConPower,modulationOrder);
            elseif strcmp(normalizationMethod,'PeakPower')
                this.Specification.MinDistance=comm.internal.qam.minDistanceForPeakPower(refConPower,modulationOrder);
            end
            refCon={(this.Specification.MinDistance/2).*exp(1i*refConOffset).*qammod((0:modulationOrder-1),modulationOrder,'bin')};
        end
        refCon=refCon{1};
    else
        [varargout{1:nargout}]=uiservices.evaluate(currentInputRefCon.RefConstellation);
        refCon=varargout{1};
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