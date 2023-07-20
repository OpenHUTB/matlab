




classdef SignalClient


    properties(Dependent=true,Access=public)


        ObserverType;



        ObserverParams;


        UpdateRate;



        DimensionChannel;




        ObserveImaginaryPart;


        BusLeafPath;
    end


    methods


        function obj=SignalClient(opts)
            if nargin>0
                obj.UUID=opts.UUID;
                obj.ObserverType_=opts.ObserverType_;
                obj.ObserverParams_=opts.ObserverParams_;
                obj.UpdateRate_=opts.UpdateRate_;
                obj.DimensionChannel_=opts.DimensionChannel_;
                obj.ObserveImaginaryPart_=opts.ObserveImaginaryPart_;
                obj.BusLeafPath_=opts.BusLeafPath_;
            else
                obj.UUID=sdi.Repository.generateUUID();
            end
        end


        function this=set.ObserverType(this,val)
            validateattributes(val,{'char'},{});
            this.ObserverType_=val;
        end

        function val=get.ObserverType(this)
            val=this.ObserverType_;
        end


        function this=set.ObserverParams(this,val)
            validateattributes(val,{'struct'},{'scalar'});
            this.ObserverParams_=val;
        end

        function val=get.ObserverParams(this)
            val=this.ObserverParams_;
        end


        function this=set.UpdateRate(this,val)
            validateattributes(val,{'numeric'},{'scalar','integer','>',0});
            this.UpdateRate_=uint32(val);
        end

        function val=get.UpdateRate(this)
            val=this.UpdateRate_;
        end


        function this=set.DimensionChannel(this,val)
            validateattributes(val,{'numeric'},{'scalar','integer','>',0});
            this.DimensionChannel_=uint32(val);
        end

        function val=get.DimensionChannel(this)
            val=this.DimensionChannel_;
        end


        function this=set.ObserveImaginaryPart(this,val)
            validateattributes(val,{'logical'},{'scalar'});
            this.ObserveImaginaryPart_=val;
        end

        function val=get.ObserveImaginaryPart(this)
            val=this.ObserveImaginaryPart_;
        end


        function this=set.BusLeafPath(this,val)
            validateattributes(val,{'char'},{});
            this.BusLeafPath_=val;
        end

        function val=get.BusLeafPath(this)
            val=this.BusLeafPath_;
        end


        function label=getLabel(this)


            label=this.UUID;
        end

    end


    properties(Hidden=true)
        UUID;
        ObserverType_='';
        ObserverParams_=struct();
        UpdateRate_=1;
        DimensionChannel_=uint32(1);
        ObserveImaginaryPart_=false;
        BusLeafPath_='';
    end

end
