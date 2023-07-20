classdef InstrumentManager<slrealtime.internal.SLRTComponent

    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
'Started'...
        }
    end

    properties(Access=public)
Instruments
    end

    properties(Access=private)
        InstrumentsAddedToTargetName=[]
    end

    methods(Access=public)
        function delete(this)
            if~isempty(this.InstrumentsAddedToTargetName)
                try
                    tg=slrealtime(this.InstrumentsAddedToTargetName);
                    arrayfun(@(x)removeInstrument(tg,x),this.Instruments);
                catch
                end
            end
        end
    end

    methods(Access=protected)
        function setup(this)
            this.Position=[0,0,0,0];
            this.Visible='off';
        end

        function update(this)
            if this.firstUpdate
                this.firstUpdate=false;



                if isempty(this.GetTargetNameFcnH)
                    this.initTarget([]);
                end
            end
        end
    end

    methods
        function set.Instruments(this,value)
            if isa(value,'slrealtime.Instrument')
                tg=this.tgGetTargetObject();
                if isempty(tg),return;end



                try
                    arrayfun(@(x)removeInstrument(tg,x),this.Instruments);
                    arrayfun(@(x)clearScalarAndLineData(x),this.Instruments);
                catch
                end



                this.Instruments=value;
                try
                    arrayfun(@(x)addInstrument(tg,x),this.Instruments);
                catch
                end
            else
                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:InstrumentManagerInstruments');
            end
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)%#ok
        end

        function updateGUI(this,~)
            arrayfun(@(x)clearScalarAndLineData(x),this.Instruments);
        end

        function targetSelectionChanged(this)


            if~isempty(this.InstrumentsAddedToTargetName)
                try
                    tg=this.tgGetTargetObject(this.InstrumentsAddedToTargetName);
                    arrayfun(@(x)removeInstrument(tg,x),this.Instruments);
                    arrayfun(@(x)clearScalarAndLineData(x),this.Instruments);
                catch
                end
            end



            tg=this.tgGetTargetObject();
            if isempty(tg),return;end
            try
                arrayfun(@(x)addInstrument(tg,x),this.Instruments);
                this.InstrumentsAddedToTargetName=this.GetTargetNameFcnH();
            catch
            end

            targetSelectionChanged@slrealtime.internal.SLRTComponent(this);
        end
    end
end