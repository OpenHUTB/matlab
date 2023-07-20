classdef IBISDiffPin<handle&matlab.mixin.Heterogeneous

...
...
...
...
...
...
...
...
...
...
...
...
...



    properties
        PinName(1,1)string{serdes.utilities.mustBeShorterThan(PinName,6)}=""
        InvPinName(1,1)string{serdes.utilities.mustBeShorterThan(InvPinName,6)}=""
        VDiff(1,1)string{serdes.utilities.mustBeShorterThan(VDiff,10)}=...
        serdes.internal.ibisami.ibis.AbstractIBISFile.NA
        TDelayTyp(1,1)string{serdes.utilities.mustBeShorterThan(TDelayTyp,10)}=...
        serdes.internal.ibisami.ibis.AbstractIBISFile.NA
        TDelayMin(1,1)string{serdes.utilities.mustBeShorterThan(TDelayMin,10)}=...
        serdes.internal.ibisami.ibis.AbstractIBISFile.NA
        TDelayMax(1,1)string{serdes.utilities.mustBeShorterThan(TDelayMax,10)}=...
        serdes.internal.ibisami.ibis.AbstractIBISFile.NA
        Hidden(1,1)logical=true;
    end

    methods
        function diffPin=IBISDiffPin(varargin)
            parser=inputParser;
            parser.addParameter('pinname',"")
            parser.addParameter('invpinname',"")
            parser.addParameter('vdiff',serdes.internal.ibisami.ibis.AbstractIBISFile.NA)
            parser.addParameter('tdelaytyp',serdes.internal.ibisami.ibis.AbstractIBISFile.NA)
            parser.addParameter('tdelaymin',serdes.internal.ibisami.ibis.AbstractIBISFile.NA)
            parser.addParameter('tdealymax',serdes.internal.ibisami.ibis.AbstractIBISFile.NA)
            parser.parse(varargin{:})
            args=parser.Results;
            diffPin.PinName=args.pinname;
            diffPin.InvPinName=args.invpinname;
            diffPin.VDiff=args.vdiff;
            diffPin.TDelayTyp=args.tdelaytyp;
            diffPin.TDelayMin=args.tdelaymin;
            diffPin.TDelayMax=args.tdealymax;
        end

        function ibisString=getIBISString(diffPin,indent)
            if diffPin.Hidden
                ibisString="";
            else
                ibisString=indent+string(sprintf('%-13s%-9s%-7s%-11s%-11s%-11s\n',...
                diffPin.PinName,diffPin.InvPinName,diffPin.VDiff,diffPin.TDelayTyp,diffPin.TDelayMin,diffPin.TDelayMax));
            end
        end
    end
end

