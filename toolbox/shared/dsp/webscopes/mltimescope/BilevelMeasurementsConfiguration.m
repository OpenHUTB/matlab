classdef BilevelMeasurementsConfiguration<dsp.webscopes.measurements.BaseMeasurementConfiguration

























    properties(AbortSet,Dependent)




        AutoStateLevel;




        HighStateLevel;




        LowStateLevel;




        StateLevelTolerance;







        UpperReferenceLevel;






        MidReferenceLevel;







        LowerReferenceLevel;



        SettleSeek;



        ShowTransitions;



        ShowAberrations;



        ShowCycles;
    end



    methods

        function this=BilevelMeasurementsConfiguration(hSpec)
            if nargin>0
                this.Specification=hSpec;
            else
                this.Specification=dsp.webscopes.measurements.BilevelMeasurementsSpecification;
            end
        end


        function set.AutoStateLevel(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','AutoStateLevel');
            setPropertyValue(this.Specification,'AutoStateLevel',value);
        end
        function value=get.AutoStateLevel(this)
            value=getPropertyValue(this.Specification,'AutoStateLevel');
        end


        function set.HighStateLevel(this,value)
            validateattributes(value,{'numeric'},{'nonnegative','real','scalar','finite','nonnan'},'','HighStateLevel');
            validateStateLevels(this,this.LowStateLevel,value);
            setPropertyValue(this.Specification,'HighStateLevel',value);
        end
        function value=get.HighStateLevel(this)
            value=getPropertyValue(this.Specification,'HighStateLevel');
        end


        function set.LowStateLevel(this,value)
            validateattributes(value,{'numeric'},{'nonnegative','real','scalar','finite','nonnan'},'','LowStateLevel');
            validateStateLevels(this,value,this.HighStateLevel);
            setPropertyValue(this.Specification,'LowStateLevel',value);
        end
        function value=get.LowStateLevel(this)
            value=getPropertyValue(this.Specification,'LowStateLevel');
        end


        function set.StateLevelTolerance(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','>',0,'<',100,'finite','nonnan'},'','StateLevelTolerance');
            setPropertyValue(this.Specification,'StateLevelTolerance',value);
        end
        function value=get.StateLevelTolerance(this)
            value=getPropertyValue(this.Specification,'StateLevelTolerance');
        end


        function set.UpperReferenceLevel(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','>',0,'<',100,'finite','nonnan'},'','UpperReferenceLevel');
            validateReferenceLevels(this,this.LowerReferenceLevel,this.MidReferenceLevel,value);
            setPropertyValue(this.Specification,'UpperReferenceLevel',value);
        end
        function value=get.UpperReferenceLevel(this)
            value=getPropertyValue(this.Specification,'UpperReferenceLevel');
        end


        function set.MidReferenceLevel(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','>',0,'<',100,'finite','nonnan'},'','MidReferenceLevel');
            validateReferenceLevels(this,this.LowerReferenceLevel,value,this.UpperReferenceLevel);
            setPropertyValue(this.Specification,'MidReferenceLevel',value);
        end
        function value=get.MidReferenceLevel(this)
            value=getPropertyValue(this.Specification,'MidReferenceLevel');
        end


        function set.LowerReferenceLevel(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','>',0,'<',100,'finite','nonnan'},'','LowerReferenceLevel');
            validateReferenceLevels(this,value,this.MidReferenceLevel,this.UpperReferenceLevel);
            setPropertyValue(this.Specification,'LowerReferenceLevel',value);
        end
        function value=get.LowerReferenceLevel(this)
            value=getPropertyValue(this.Specification,'LowerReferenceLevel');
        end


        function set.SettleSeek(this,value)
            validateattributes(value,{'numeric'},{'positive','real','scalar','finite','nonnan'},'','SettleSeek');
            setPropertyValue(this.Specification,'SettleSeek',value);
        end
        function value=get.SettleSeek(this)
            value=getPropertyValue(this.Specification,'SettleSeek');
        end


        function set.ShowTransitions(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowTransitions');
            setPropertyValue(this.Specification,'ShowTransitions',value);
        end
        function value=get.ShowTransitions(this)
            value=getPropertyValue(this.Specification,'ShowTransitions');
        end


        function set.ShowAberrations(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowAberrations');
            setPropertyValue(this.Specification,'ShowAberrations',value);
        end
        function value=get.ShowAberrations(this)
            value=getPropertyValue(this.Specification,'ShowAberrations');
        end


        function set.ShowCycles(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowCycles');
            setPropertyValue(this.Specification,'ShowCycles',value);
        end
        function value=get.ShowCycles(this)
            value=getPropertyValue(this.Specification,'ShowCycles');
        end
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)


            propList=getValidDisplayProperties(this.Specification,{...
            'AutoStateLevel',...
            'HighStateLevel',...
            'LowStateLevel',...
            'StateLevelTolerance',...
            'UpperReferenceLevel',...
            'MidReferenceLevel',...
            'LowerReferenceLevel',...
            'SettleSeek',...
            'ShowTransitions',...
            'ShowAberrations',...
            'ShowCycles'});
            groups=matlab.mixin.util.PropertyGroup(propList);
        end

        function validateStateLevels(~,low,high)
            import dsp.webscopes.*;
            if high<=low
                TimePlotBaseWebScope.localError('invalidLowHighStateLevels');
            end
        end

        function validateReferenceLevels(~,low,mid,high)
            import dsp.webscopes.*;
            if low>=mid||mid>=high||low>=high
                TimePlotBaseWebScope.localError('invalidLowerMidUpperReferenceLevels');
            end
        end
    end
end