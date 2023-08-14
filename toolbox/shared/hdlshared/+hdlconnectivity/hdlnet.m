classdef hdlnet<hgsetget









    properties
        name='';
        path={};
        sltype='';
        isRegisterOutput=false;
        isClock=false;
        isClockEnable=false;
        isReset=false;
        PIRSignal=[];
        connectivityOnly=false;
    end

    methods

        function this=hdlnet(varargin)
            if nargin~=0,
                prop=varargin(1:2:end-1);
                val=varargin(2:2:end);
                set(this,prop,val);
            end
        end
    end


end


