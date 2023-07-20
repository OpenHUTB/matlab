


classdef ElementType

    enumeration
        IsotropicAntenna(1,'Isotropic',@getIsotropicElement,@genCodeIsotropic)
        CosineAntenna(2,'Cosine',@getCosineElement,@genCodeCosine)
        OmnidirectionalMicrophone(3,'Omnidirectional',@getOmnidirectionalElement,@genCodeOmnidirectional)
        CardioidMicrophone(4,'Cardioid',@getCardioidElement,@genCodeCardioid)
        CustomAntenna(5,'CustomAntenna',@getCustomElement,@genCodeCustom)
    end

    properties
ID
Name
ElementGetCallback
GenCodeCallback
    end


    methods(Static)
        function N=names
            N=arrayfun(@(a)a.Name,enumeration('phased.apps.internal.SensorArrayViewer.ElementType'),'UniformOutput',false);
        end

        function el=getElementAtPos(pos)

            E=enumeration('phased.apps.internal.SensorArrayViewer.ElementType');

            ids=arrayfun(@(a)a.ID,E);

            [~,I]=sortrows(ids);

            finals=arrayfun(@(a)ismember(a,pos),I);

            el=E(I(finals));
        end
    end

    methods

        function obj=ElementType(id,tag,cb,gccb)
            obj.ID=id;
            obj.Name=getString(message(['phased:apps:arrayapp:',tag]));
            obj.ElementGetCallback=cb;
            obj.GenCodeCallback=gccb;
        end

        function el=getElement(obj,curAT)
            el=obj.ElementGetCallback(obj,curAT);
        end

        function genCode(obj,curAT,mcode)








            obj.GenCodeCallback(obj,curAT,mcode);
        end

    end

    methods


        function el=getIsotropicElement(~,curAT)
            el=phased.IsotropicAntennaElement('FrequencyRange',curAT.FreqRange,...
            'BackBaffled',curAT.IsBackBaffled);
        end

        function genCodeIsotropic(~,curAT,mcode)
            mcode.addcr('%Create Isotropic Antenna Element');
            mcode.addcr('el = phased.IsotropicAntennaElement;');
            if curAT.IsBackBaffled
                mcode.addcr('el.BackBaffled = true;');
            end
            mcode.addcr('h.Element = el;');
        end


        function el=getCosineElement(~,curAT)
            el=phased.CosineAntennaElement('FrequencyRange',curAT.FreqRange,...
            'CosinePower',curAT.CosinePower);
        end

        function genCodeCosine(~,curAT,mcode)
            mcode.addcr('%Create Cosine Antenna Element');
            mcode.addcr('el = phased.CosineAntennaElement;');
            mcode.addcr(['el.CosinePower = ',mat2str(curAT.CosinePower),';']);
            mcode.addcr('h.Element = el;');
        end


        function el=getOmnidirectionalElement(~,curAT)
            el=phased.OmnidirectionalMicrophoneElement('FrequencyRange',curAT.FreqRange,...
            'BackBaffled',curAT.IsBackBaffled);
        end

        function genCodeOmnidirectional(~,curAT,mcode)
            mcode.addcr('%Create Omnidirectional Microphone Element');
            mcode.addcr('el = phased.OmnidirectionalMicrophoneElement;');
            if curAT.IsBackBaffled
                mcode.addcr('el.BackBaffled = true;');
            end
            mcode.addcr('h.Element = el;');
        end


        function el=getCardioidElement(~,~)
            el=phased.CustomMicrophoneElement;
            el.PolarPatternFrequencies=[1000,2000];
            el.PolarPattern=mag2db([...
            0.5+0.5*cosd(el.PolarPatternAngles);...
            0.6+0.4*cosd(el.PolarPatternAngles)]);
        end

        function genCodeCardioid(~,~,mcode)
            mcode.addcr('%Create Cardioid Microphone Element');
            mcode.addcr('el = phased.CustomMicrophoneElement;');
            mcode.addcr('el.PolarPatternFrequencies = [1000 2000];');
            mcode.addcr('el.PolarPattern = mag2db([...');
            mcode.addcr('    0.5+0.5*cosd(el.PolarPatternAngles);...');
            mcode.addcr('    0.6+0.4*cosd(el.PolarPatternAngles)]);');
            mcode.addcr('h.Element = el;');
        end


        function el=getCustomElement(~,curAT)
            el=phased.CustomAntennaElement('FrequencyVector',curAT.FrequencyVector,...
            'FrequencyResponse',curAT.FrequencyResponse,...
            'AzimuthAngles',curAT.AzimuthAngles,...
            'ElevationAngles',curAT.ElevationAngles,...
            'MagnitudePattern',curAT.MagnitudePattern,...
            'PhasePattern',curAT.PhasePattern);
        end

        function genCodeCustom(~,curAT,mcode)
            mcode.addcr('%Create Custom Antenna Element');
            mcode.addcr('el = phased.CustomAntennaElement;');
            mcode.addcr(['el.FrequencyVector = ',mat2str(curAT.FrequencyVector),';']);
            mcode.addcr(['el.FrequencyResponse = ',mat2str(curAT.FrequencyResponse),';']);
            mcode.addcr(['el.AzimuthAngles = ',curAT.StringValues.AzimuthAngles,';']);
            mcode.addcr(['el.ElevationAngles = ',curAT.StringValues.ElevationAngles,';']);
            mcode.addcr(['el.MagnitudePattern = ',curAT.StringValues.MagnitudePattern,';']);
            mcode.addcr(['el.PhasePattern = ',curAT.StringValues.PhasePattern,';']);
            mcode.addcr('h.Element = el;');
        end

    end

end



