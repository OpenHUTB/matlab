classdef(Hidden)Simulation3DVisionSensor<Simulation3DSensor


    properties(Nontunable)

        HorizontalResolution(1,1)uint32{mustBeLessThanOrEqual(HorizontalResolution,1920)}=1920;

        VerticalResolution(1,1)uint32{mustBeLessThanOrEqual(VerticalResolution,1080)}=1080;

        HorizontalFOV(1,1)single{mustBeNonnegative,mustBeLessThanOrEqual(HorizontalFOV,120)}=60;
    end

    methods(Access=protected)
        function[Image]=stepImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Sensor)
                    [Image]=self.Sensor.read();
                else
                    Image=zeros(self.VerticalResolution,self.HorizontalResolution,3,'uint8');
                end
            else
                Image=zeros(self.VerticalResolution,self.HorizontalResolution,3,'uint8');
            end
        end

        function num=getNumOutputsImpl(~)
            num=1;
        end

        function[sz1]=getOutputSizeImpl(self)
            sz1=[double(self.VerticalResolution),double(self.HorizontalResolution),3];
        end

        function[fz1]=isOutputFixedSizeImpl(~)
            fz1=true;
        end

        function[dt1]=getOutputDataTypeImpl(~)
            dt1='uint8';
        end

        function[cp1]=isOutputComplexImpl(~)
            cp1=false;
        end
    end
    methods(Access=public,Hidden=true)
        function tag=getTag(self)
            tag=sprintf('Camera%d',self.SensorIdentifier);
        end
    end
end
