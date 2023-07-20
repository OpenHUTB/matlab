classdef XlnxSGMII625MHzRef<eda.internal.component.XLNXSGMII

    methods
        function this=XlnxSGMII625MHzRef(varargin)
            this=this@eda.internal.component.XLNXSGMII(varargin);
            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fil',...
            '+eda','+internal','+component','@XlnxSGMII625MHzRef')};
            this.HDLFiles={'XlnxSGMII625MHzRef.vhd'};
        end
    end
end

