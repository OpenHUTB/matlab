classdef fdhcHDLtimingutil<hdlconnectivity.abstractHDLtimingutil









    properties

    end

    methods

        function this=fdhcHDLtimingutil(varargin)


            this.init();




            filtername=hdlgetparameter('filter_name');


            addEnbTiming(this,filtername,hdlgetparameter('clockenablename'),...
            hdlconnectivity.abstractHDLtimingutil.makeEnbTiming(0,1));



            clockname=[filtername,this.pathDelim,hdlgetparameter('clockname')];
            this.topClockName=clockname;
        end



    end



    methods(Access=private)





    end




end


