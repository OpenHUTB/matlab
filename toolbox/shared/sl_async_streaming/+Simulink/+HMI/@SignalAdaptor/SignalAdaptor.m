



classdef SignalAdaptor


    properties(Dependent=true,Access=public)


        Name;


        AdaptorParams;

    end


    methods


        function obj=SignalAdaptor()
        end


        function this=set.Name(this,val)
            if~ischar(val)||isempty(val)
                DAStudio.error('SimulinkHMI:observers:SignalAdaptorInvalidType');
            end
            this.name_=val;
        end

        function val=get.Name(this)
            val=this.name_;
        end


        function this=set.AdaptorParams(this,val)
            if~isstruct(val)||~isscalar(val)
                DAStudio.error('SimulinkHMI:observers:SignalAdaptorInvalidParams');
            end
            this.adaptorParams_=val;
        end

        function val=get.AdaptorParams(this)
            val=this.adaptorParams_;
        end

    end


    properties(Hidden=true)
        name_='';
        adaptorParams_=struct();
    end

end

