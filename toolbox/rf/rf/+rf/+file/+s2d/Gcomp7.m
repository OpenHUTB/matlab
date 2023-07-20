classdef Gcomp7<rf.file.s2d.GcompMethods






    properties(SetAccess=private)
PIN
POUT
PowerFrequency
PowerFrequencyUnit
PowerFormat
PowerReferenceImpedance
        PowerDimension='dbm'
    end

    methods
        function obj=Gcomp7(newData,newFormatLine,newGCOMP7freq,newGCOMP7funit,newGCOMP7theformat,newGCOMP7refimpedance)
            narginchk(6,6);
            obj=obj@rf.file.s2d.GcompMethods(newData,newFormatLine);



            obj.PowerFrequencyUnit=newGCOMP7funit;
            obj.PowerFrequency=newGCOMP7freq;
            obj.PowerFormat=newGCOMP7theformat;
            obj.PowerReferenceImpedance=newGCOMP7refimpedance;
        end
    end

    methods
        function set.PIN(obj,newPIN)
            validateattributes(newPIN,{'numeric'},{'column','real','nonnan'},'','PIN')
            obj.PIN=newPIN;
        end

        function set.POUT(obj,newPOUT)
            validateattributes(newPOUT,{'numeric'},{'ncols',2,'real','nonnan'},'','POUT')
            obj.POUT=newPOUT;
        end

        function set.PowerFrequency(obj,newPowerFrequency)
            validateattributes(newPowerFrequency,{'numeric'},{'scalar','real','positive'},'','PowerFrequency')
            obj.PowerFrequency=newPowerFrequency;
        end

        function set.PowerFrequencyUnit(obj,newPowerFrequencyUnit)
            validateattributes(newPowerFrequencyUnit,{'char'},{'row'},'','PowerFrequencyUnit')
            obj.PowerFrequencyUnit=newPowerFrequencyUnit;
        end

        function set.PowerFormat(obj,newPowerFormat)
            validateattributes(newPowerFormat,{'char'},{'row'},'','PowerFormat')
            obj.PowerFormat=newPowerFormat;
        end

        function set.PowerReferenceImpedance(obj,newPowerReferenceImpedance)
            validateattributes(newPowerReferenceImpedance,{'numeric'},{'scalar','real','positive','nonnan'},'','PowerReferenceImpedance')
            obj.PowerReferenceImpedance=newPowerReferenceImpedance;
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'PIN','N21X','N21Y'};
        end

        function validatedatainput(newData)
            validateattributes(newData,{'numeric'},{'ncols',3})
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,Data)
            obj.PIN=Data(:,1);
            obj.POUT=[Data(:,2),Data(:,3)];
        end
    end
end