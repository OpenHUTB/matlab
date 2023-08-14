classdef LineSettings


    properties(Dependent)
        LineStyle;
        LineWidth;
        Color;
        ColorString;
        Axes;
    end


    methods


        function val=get.LineStyle(this)
            val=this.LineStyle_;
        end
        function this=set.LineStyle(this,val)
            if isempty(val)
                this.LineStyle_='';
            else
                val=lower(val);
                validatestring(val,{'-',':','-.','--'});
                this.LineStyle_=val;
            end
        end


        function val=get.LineWidth(this)
            val=this.LineWidth_;
        end
        function this=set.LineWidth(this,val)
            if isempty(val)
                this.LineWidth_=1;
            else
                validateattributes(val,{'numeric'},...
                {'scalar','integer','>=',1,'<=',20});
                this.LineWidth_=val;
            end
        end


        function val=get.Color(this)
            val=this.Color_;
        end
        function this=set.Color(this,val)
            if isempty(val)
                this.Color_=[];
            else
                validateattributes(val,{'double'},...
                {'numel',3,'nonnegative','<=',1});
                this.Color_=double(reshape(val,[1,3]));
            end
        end


        function val=get.Axes(this)
            val=this.Axes_;
        end
        function this=set.Axes(this,val)
            if isempty(val)
                this.Axes_=uint32.empty;
            else
                validateattributes(val,...
                {'numeric'},{'positive','integer','vector','<=',16});
                this.Axes_=sort(uint32(val));
            end
        end


        function val=get.ColorString(this)
            if isempty(this.Color_)
                val='';
            else
                val=Simulink.sdi.internal.LineSettings.colorToHexString(...
                this.Color_);
            end
        end
        function this=set.ColorString(this,val)
            if isempty(val)
                this.Color_=[];
            else
                this.Color_=Simulink.sdi.internal.LineSettings.hexStringToColor(val);
            end
        end

    end


    methods(Static)


        function colorInHex=colorToHexString(val)


            validateattributes(val,{'double'},...
            {'numel',3,'nonnegative','<=',1});
            valInHex=dec2hex(round(255*val));

            if strcmpi(valInHex(1),'0')&&strcmpi(valInHex(2),'0')&&strcmpi(valInHex(3),'0')
                colorInHex='#000000';
            else
                valInHex=reshape(valInHex',1,6);
                rStr=valInHex(1:2);
                gStr=valInHex(3:4);
                bStr=valInHex(5:6);


                colorInHex=strcat('#',rStr,gStr,bStr);
            end
        end


        function val=hexStringToColor(colorInHex)


            validateattributes(colorInHex,{'char'},{});
            val=[];
            if length(colorInHex)==7
                rStr=colorInHex(2:3);
                gStr=colorInHex(4:5);
                bStr=colorInHex(6:7);
                rVal=hex2dec(rStr)/255;
                gVal=hex2dec(gStr)/255;
                bVal=hex2dec(bStr)/255;
                val=[rVal,gVal,bVal];
            end
        end

    end


    properties(Hidden)
        LineStyle_='';
        LineWidth_=1;
        Color_=[];
        Axes_=uint32.empty;
    end
end
