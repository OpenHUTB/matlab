function[phaseshift,voltage]=calcPhaseShiftAndVoltageForConformal(Element,...
    ElementPosition,Voltage,PhaseShift)
    Length=size(ElementPosition,1);
    phaseShift=cell(1,Length);
    VOLTAGE=cell(1,Length);
    if iscell(Element)
        for i=1:size(ElementPosition,1)
            if isa(Element{i},'em.Array')
                Size=Element{i}.ArraySize;
                phaseShift{1,i}=Element{i}.PhaseShift(:)'*pi/180+repmat(PhaseShift(i),prod(Size),1)';
                VOLTAGE{1,i}=Element{i}.AmplitudeTaper(:)'.*(repmat(Voltage(i),prod(Size),1)');
            elseif isa(Element{i},'pcbStack')


                Size=size(Element{i}.FeedLocations,1);
                phaseShift{1,i}=Element{i}.FeedPhase(:)'*pi/180+repmat(PhaseShift(i),prod(Size),1)';
                VOLTAGE{1,i}=Element{i}.FeedVoltage(:)'.*(repmat(Voltage(i),prod(Size),1)');
            else
                phaseShift{1,i}=PhaseShift(i);
                VOLTAGE{1,i}=Voltage(i);
            end
        end
        phaseshift=cell2mat(phaseShift);
        voltage=cell2mat(VOLTAGE);
        if strcmpi(class(Element{1}),'dipoleCrossed')||(isprop(Element{1},'Element')&&strcmpi(class(Element{1}.Element),'dipoleCrossed'))
            phaseshift=repmat(phaseshift,1,2);
            voltage=repmat(voltage,1,2);
        end
    elseif any(strcmpi(class(Element),{'linearArray','rectangularArray','circularArray','pcbStack'}))
        for i=1:size(ElementPosition,1)
            if isscalar(Element)
                Elem=Element;
            else
                Elem=Element(i);
            end
            if isa(Element,'em.Array')
                Size=Elem.ArraySize;
                phaseShift{1,i}=Elem.PhaseShift(:)'*pi/180+repmat(PhaseShift(i),prod(Size),1)';
                VOLTAGE{1,i}=Elem.AmplitudeTaper(:)'.*(repmat(Voltage(i),prod(Size),1)');
            elseif isa(Element,'pcbStack')


                Size=size(Elem.FeedLocations,1);
                phaseShift{1,i}=Elem.FeedPhase(:)'*pi/180+repmat(PhaseShift(i),prod(Size),1)';
                VOLTAGE{1,i}=Elem.FeedVoltage(:)'.*(repmat(Voltage(i),prod(Size),1)');
            else
                phaseShift{1,i}=PhaseShift(i);
                VOLTAGE{1,i}=Voltage(i);
            end
        end
        phaseshift=cell2mat(phaseShift);
        voltage=cell2mat(VOLTAGE);
        if strcmpi(class(Element(1)),'dipoleCrossed')||(isprop(Element(1),'Element')&&strcmpi(class(Element(1).Element),'dipoleCrossed'))
            phaseshift=repmat(phaseshift,1,2);
            voltage=repmat(voltage,1,2);
        end
    else
        phaseshift=PhaseShift;
        voltage=Voltage;
        if strcmpi(class(Element(1)),'dipoleCrossed')
            phaseshift=repmat(phaseshift,1,2);
            voltage=repmat(voltage,1,2);
        end
    end
end
