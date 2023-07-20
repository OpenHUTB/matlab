function rtn=handleVectorExceptions(obj,bound)
    if isa(obj,'pcbStack')||isa(obj,'em.internal.pcbDesigner.PCBModelCopy')

        vectorPropPresent=false;
    else
        vectorPropPresent=false;
        for k=1:numel(obj.OptimStruct.PropertyNames)
            if any(strcmpi(obj.OptimStruct.PropertyNames{k},obj.OptimStruct.VectorProperties))
                vectorPropPresent=true;
            end
        end
    end

    if vectorPropPresent

        if numel(obj.OptimStruct.PropertyNames)<numel(bound)

            expectedBoundSize=0;
            for m=1:numel(obj.OptimStruct.PropertyNames)
                propLengthFactor=getVectorSize(obj,obj.OptimStruct.PropertyNames{m});
                expectedBoundSize=expectedBoundSize+propLengthFactor;
            end
            if expectedBoundSize~=numel(bound)
                if(expectedBoundSize~=numel(bound))&&...
                    (expectedBoundSize~=numel(obj.OptimStruct.PropertyNames))
                    error(message("antenna:antennaerrors:MissedVectorProperties"));
                end
            end
            rtn=bound;
        else

            copyBound=num2cell(bound);
            for m=1:numel(obj.OptimStruct.PropertyNames)
                val=copyBound{m};
                if any(strcmpi(obj.OptimStruct.PropertyNames{m},obj.OptimStruct.VectorProperties))
                    Size=getVectorSize(obj,obj.OptimStruct.PropertyNames{m});
                    if isscalar(val)
                        val=makeArray(obj,Size,val);
                    end
                    subObj=obj.OptimStruct.PairedProps{find(strcmpi(obj.OptimStruct.PairedProps,obj.OptimStruct.PropertyNames{m}))+1};

                    checkVectorLength(obj,subObj);
                    if isscalar(get(subObj,obj.OptimStruct.PropertyNames{m}))
                        currentVal=makeArray(obj,Size,get(subObj,obj.OptimStruct.PropertyNames{m}));
                        set(subObj,obj.OptimStruct.PropertyNames{m},currentVal);
                    end
                end
                copyBound{m}=val;
            end
            rtn=cell2mat(copyBound);
        end

    else

        if numel(obj.OptimStruct.PropertyNames)<numel(bound)
            error(message("antenna:antennaerrors:MismatchBoundsToProperties"));
        end
        rtn=bound;
    end

    function rtn=makeArray(~,Size,val)
        array=zeros(1,Size);
        for a=1:Size
            array(a)=val;
        end
        rtn=array;
    end

    function rtn=getVectorSize(obj,propName)
        subObj=obj.OptimStruct.PairedProps{find(strcmpi(obj.OptimStruct.PairedProps,propName))+1};
        switch class(subObj)
        case 'waveguideSlotted'
            switch propName
            case 'SlotSpacing'
                rtn=subObj.NumSlots-1;
            case 'SlotOffset'
                rtn=subObj.NumSlots;
            case 'SlotAngle'
                rtn=subObj.NumSlots;
            otherwise
                rtn=1;
            end
        case 'circularArray'
            switch propName
            case 'AmplitudeTaper'
                rtn=subObj.NumElements;
            case 'PhaseShift'
                rtn=subObj.NumElements;
            otherwise
                rtn=1;
            end
        case 'yagiUda'
            switch propName
            case 'DirectorSpacing'
                rtn=subObj.NumDirectors;
            case 'DirectorLength'
                rtn=subObj.NumDirectors;
            otherwise
                rtn=1;
            end
        case 'bicone'
            switch propName
            case 'ConeHeight'
                rtn=2;
            case 'NarrowRadius'
                rtn=2;
            case 'BroadRadius'
                rtn=2;
            otherwise
                rtn=1;
            end
        case 'dipoleVee'
            switch propName
            case 'ArmLength'
                rtn=2;
            case 'ArmElevation'
                rtn=2;
            otherwise
                rtn=1;
            end
        case 'discone'
            switch propName
            case 'ConeRadii'
                rtn=2;
            otherwise
                rtn=1;
            end
        case 'biconeStrip'
            switch propName
            case 'ConeRadii'
                rtn=2;
            case 'HatHeight'
                rtn=2;
            case 'ConeHeight'
                rtn=2;
            case 'BroadRadius'
                rtn=2;
            otherwise
                rtn=1;
            end
        case 'disconeStrip'
            switch propName
            case 'ConeRadii'
                rtn=2;
            otherwise
                rtn=1;
            end
        case 'linearArray'
            switch propName
            case 'ElementSpacing'
                rtn=subObj.NumElements-1;
            case 'AmplitudeTaper'
                rtn=subObj.NumElements;
            case 'PhaseShift'
                rtn=subObj.NumElements;
            otherwise
                rtn=1;
            end

        case 'eggCrate'
            switch propName
            case 'Gap'
                rtn=2;
            case 'FeedVoltage'
                rtn=subObj.NumElements;
            case 'FeedPhase'
                rtn=subObj.NumElements;
            otherwise
                rtn=1;
            end

        case 'hornCorrugated'
            switch propName
            case 'CorrugateDepth'
                rtn=2;
            otherwise
                rtn=1;
            end
        case 'lpda'
            switch propName
            case 'ArmLength'
                rtn=8;
            case 'ArmWidth'
                rtn=8;
            case 'ArmSpacing'
                rtn=8;
            case 'BoardWidth'
                rtn=2;
            otherwise
                rtn=1;
            end
        case 'monocone'
            switch propName
            case 'Radii'
                rtn=3;
            otherwise
                rtn=1;
            end
        case 'rectangularArray'
            switch propName
            case 'RowSpacing'
                rtn=subObj.Size(1)-1;
            case 'ColumnSpacing'
                rtn=subObj.Size(2)-1;
            case 'AmplitudeTaper'
                rtn=prod(subObj.Size);
            case 'PhaseShift'
                rtn=prod(subObj.Size);
            otherwise
                rtn=1;
            end
        case 'dipoleCrossed'
            switch propName
            case 'ArmElevation'
                rtn=2;
            case 'FeedVoltage'
                rtn=2;
            case 'FeedPhase'
                rtn=2;
            otherwise
                rtn=1;
            end
        case 'customDualReflectors'
            switch propName
            case 'FeedOffset'
                rtn=3;
            case 'ReflectorTilt'
                if isempty(subObj.SubReflector)
                    rtn=1;
                else
                    rtn=2;
                end
            otherwise
                rtn=1;
            end
        otherwise
            rtn=1;
        end
    end

    function checkVectorLength(obj,antObj)
        listObj={'yagiUda','customDualReflectors'};
        if any(strcmpi(listObj,class(antObj)))||...
            any(strcmpi(obj.OptimStruct.ValidatingInShow,class(antObj)))
            createGeometry(antObj);
        end
    end
end

