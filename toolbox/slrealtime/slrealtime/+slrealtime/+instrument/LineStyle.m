classdef LineStyle<handle






    properties(Hidden,Constant)

        ValidStyles={'-','--',':','-.','none'};

        AutoColorSelection=[-1,-1,-1];
        ValidColors={...
        'red','r',...
        'green','g',...
        'blue','b',...
        'cyan','c',...
        'magenta','m',...
        'yellow','y',...
        'black','k',...
        'white','w'};

        ValidMarkers={...
        '+','o','*','.','x','square','diamond'...
        ,'v','^','>','<','pentagram','hexagram','none'};

        WidthDefault=0.5;
        StyleDefault='-';
        ColorDefault=slrealtime.instrument.LineStyle.AutoColorSelection;
        MarkerDefault='none';
        MarkerSizeDefault=6;
    end

    properties(Access=public)
        Width=slrealtime.instrument.LineStyle.WidthDefault;
        Style=slrealtime.instrument.LineStyle.StyleDefault;
        Color=slrealtime.instrument.LineStyle.ColorDefault;
        Marker=slrealtime.instrument.LineStyle.MarkerDefault;
        MarkerSize=slrealtime.instrument.LineStyle.MarkerSizeDefault;
    end

    methods(Access=public)
        function obj=LineStyle(varargin)
            narginchk(0,1);
            if nargin==1
                inObj=varargin{1};
                validateattributes(inObj,{'slrealtime.instrument.LineStyle'},{'scalar'});

                obj.Width=inObj.Width;
                obj.Style=inObj.Style;
                obj.Color=inObj.Color;
                obj.Marker=inObj.Marker;
                obj.MarkerSize=inObj.MarkerSize;
            end
        end
    end

    methods(Static,Access=public)
        function ret=validateWidth(width)
            ret=...
            isnumeric(width)&&...
            isscalar(width)&&...
            width>0;
        end

        function ret=validateStyle(style)
            ret=...
            ischar(style)&&...
            any(strcmp(style,slrealtime.instrument.LineStyle.ValidStyles));
        end

        function ret=validateColor(color)
            ret=...
            (ischar(color)&&any(strcmp(color,slrealtime.instrument.LineStyle.ValidColors)))||...
            (isnumeric(color)&&numel(color)==3&&(all(color==slrealtime.instrument.LineStyle.AutoColorSelection)||(all(color<=1)&&all(color>=0))));
        end

        function ret=validateMarker(marker)
            ret=...
            ischar(marker)&&...
            any(strcmp(marker,slrealtime.instrument.LineStyle.ValidMarkers));
        end

        function ret=validateMarkerSize(size)
            ret=...
            isnumeric(size)&&...
            isscalar(size)&&...
            size>0;
        end
    end

    methods
        function set.Width(this,width)
            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('width',@slrealtime.instrument.LineStyle.validateWidth);
            parser.parse(width);
            this.Width=parser.Results.width;
        end

        function set.Style(this,style)
            style=convertStringsToChars(style);

            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('style',@slrealtime.instrument.LineStyle.validateStyle);
            parser.parse(style);
            this.Style=parser.Results.style;
        end

        function set.Color(this,color)
            color=convertStringsToChars(color);

            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('color',@slrealtime.instrument.LineStyle.validateColor);
            parser.parse(color);
            this.Color=parser.Results.color;
        end

        function set.Marker(this,marker)
            marker=convertStringsToChars(marker);

            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('marker',@slrealtime.instrument.LineStyle.validateMarker);
            parser.parse(marker);
            this.Marker=parser.Results.marker;
        end

        function set.MarkerSize(this,size)
            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('size',@slrealtime.instrument.LineStyle.validateMarkerSize);
            parser.parse(size);
            this.MarkerSize=parser.Results.size;
        end
    end

    methods(Hidden,Access=public)
        function ret=isWidthSetToDefault(this)
            ret=this.Width==this.WidthDefault;
        end

        function ret=isStyleSetToDefault(this)
            ret=strcmp(this.Style,this.StyleDefault);
        end

        function ret=isColorSetToDefault(this)
            ret=isnumeric(this.Color)&&...
            all(this.Color==slrealtime.instrument.LineStyle.AutoColorSelection);
        end

        function ret=isMarkerSetToDefault(this)
            ret=strcmp(this.Marker,this.MarkerDefault);
        end

        function ret=isMarkerSizeSetToDefault(this)
            ret=this.MarkerSize==this.MarkerSizeDefault;
        end

        function ret=isDefault(this)
            ret=...
            this.isWidthSetToDefault()&&...
            this.isStyleSetToDefault()&&...
            this.isColorSetToDefault()&&...
            this.isMarkerSetToDefault()&&...
            this.isMarkerSizeSetToDefault();
        end

        function str=toString(this)
            str=num2str(this.Width);
            str=[str,'/',this.Style];

            if this.isColorSetToDefault()
                str=[str,'/auto'];
            else
                str=[str,'/',this.Color];
            end

            str=[str,'/',this.Marker];
            str=[str,'/',num2str(this.MarkerSize)];
        end
    end
end
