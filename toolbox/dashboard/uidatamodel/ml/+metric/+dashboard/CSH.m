classdef CSH<handle

    properties(Dependent)
AnchorID
MapKey
    end

    properties(Access=private)
MF0CSH
    end

    methods(Access=?metric.dashboard.widgets.WidgetBase)
        function obj=CSH(element)
            obj.MF0CSH=element;
        end
    end

    methods
        function anchorID=get.AnchorID(this)
            anchorID=this.MF0CSH.AnchorID;
        end

        function set.AnchorID(this,anchorId)
            metric.dashboard.Verify.ScalarCharOrString(anchorId);
            this.MF0CSH.AnchorID=anchorId;
        end

        function mapKey=get.MapKey(this)
            mapKey=this.MF0CSH.MapKey;
        end

        function set.MapKey(this,mapKey)
            metric.dashboard.Verify.ScalarCharOrString(mapKey);
            this.MF0CSH.MapKey=mapKey;
        end
    end
end

