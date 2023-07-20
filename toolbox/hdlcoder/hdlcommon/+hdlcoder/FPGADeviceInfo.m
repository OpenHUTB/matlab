classdef FPGADeviceInfo<handle






    properties


        Name='';


        Vendor='';


        DSPWidth=[];



        SplitDSPWidth=[];


        RAMWidth=[];
        RAMDepth=[];


        SplitRAMWidth=[];



    end

    properties(Constant,Hidden)

        DefaultName='Zynq Ultrascale+';

        DefaultVendor='Xilinx';

        DefaultDSPWidth=[25,18];
        DefaultSplitDSPWidth=[];


        DefaultRAMWidth=36;
        DefaultRAMDepth=1024;
        DefaultSplitRAMWidth=18;

    end


    properties(Hidden=true)


        Hidden=false;

    end

    properties(Access=protected,Hidden=true)


    end

    properties(Access=protected)

    end

    methods

        function obj=FPGADeviceInfo(varargin)

            p=inputParser;
            addParameter(p,'Name',obj.DefaultName,@(x)(ischar(x)||isstring(x))&&~isempty(x));
            addParameter(p,'Vendor',obj.DefaultVendor,@(x)(ischar(x)||isstring(x))&&~isempty(x));
            addParameter(p,'DSPWidth',obj.DefaultDSPWidth,@(x)(isnumeric(x))&&~isempty(x));
            addParameter(p,'SplitDSPWidth',obj.DefaultSplitDSPWidth,@(x)(isnumeric(x)));
            addParameter(p,'RAMWidth',obj.DefaultRAMWidth,@(x)(isnumeric(x))&&~isempty(x));
            addParameter(p,'SplitRAMWidth',obj.DefaultSplitRAMWidth,@(x)(isnumeric(x)));
            addParameter(p,'RAMDepth',obj.DefaultRAMDepth,@(x)(isnumeric(x))&&~isempty(x));

            parse(p,varargin{:});
            obj.Name=p.Results.Name;
            obj.Vendor=p.Results.Vendor;
            obj.RAMWidth=p.Results.RAMWidth;
            obj.RAMDepth=p.Results.RAMDepth;
            obj.SplitRAMWidth=p.Results.SplitRAMWidth;
            obj.DSPWidth=p.Results.DSPWidth;
            obj.SplitDSPWidth=p.Results.SplitDSPWidth;
        end


        function set.Name(obj,val)
            if~ischar(val)&&~isstring(val)&&~isempty(val)
                error(message('hdlcommon:plugin:InvalidPropertyValueNoEx',...
                val,'Name'));
            end
            obj.Name=val;
        end


        function set.Vendor(obj,val)
            if~ischar(val)&&~isstring(val)&&~isempty(val)
                error(message('hdlcommon:plugin:InvalidPropertyValueNoEx',...
                string(val),'Vendor'));
            end
            obj.Vendor=val;
        end


        function set.DSPWidth(obj,val)

            if~isnumeric(val)||length(val)~=2
                error(message('hdlcommon:plugin:InvalidPropertyValueNoEx',...
                string(val),'DSPWidth'));
            end
            obj.DSPWidth=val;
        end

        function set.SplitDSPWidth(obj,val)



            if~isnumeric(val)||(~isempty(val)&&length(val)~=2)
                error(message('hdlcommon:plugin:InvalidPropertyValueNoEx',...
                string(val),'SplitDSPWidth'));
            end
            obj.SplitDSPWidth=val;
        end

        function set.RAMWidth(obj,val)
            if~isnumeric(val)||length(val)~=1
                error(message('hdlcommon:plugin:InvalidPropertyValueNoEx',...
                string(val),'RAMWidth'));
            end
            obj.RAMWidth=val;
        end

        function set.RAMDepth(obj,val)
            if~isnumeric(val)||length(val)~=1
                error(message('hdlcommon:plugin:InvalidPropertyValueNoEx',...
                string(val),'RAMDepth'));
            end
            obj.RAMDepth=val;
        end

        function set.SplitRAMWidth(obj,val)


            if~isnumeric(val)||(~isempty(val)&&length(val)~=1)
                error(message('hdlcommon:plugin:InvalidPropertyValueNoEx',...
                string(val),'SplitRAMWidth'));
            end
            obj.SplitRAMWidth=val;
        end


    end


end

