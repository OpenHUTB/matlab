classdef Filter<handle
    properties
Domain
ConfigName
ConfigLabel
PropName
PropValue
QueryName
PropLabel
SubPropName
SubPropLabel
        location;
    end

    methods
        function this=Filter(filterStruct)
            if nargin==1
                this.ConfigName=filterStruct.Name;
                if isfield(filterStruct,'Domain')
                    this.Domain=filterStruct.Domain;
                end
                this.PropName=filterStruct.Prop;
                this.PropLabel=filterStruct.PropLabel;
            end
        end

        function addFilterToCurrentDoc(this)
            slreq.report.rtmx.utils.MatrixWindow.publishAddFilter(this);
        end

        function clearColFilterToCurrentObj(this)
            this.location='Col';
            slreq.report.rtmx.utils.MatrixWindow.publishClearFilter(this);
        end

        function clearRowFilterToCurrentObj(this)
            this.location='Row';
            slreq.report.rtmx.utils.MatrixWindow.publishClearFilter(this);
        end

        function out=getFilterStruct(this)
            out.Name=this.ConfigName;
            out.Prop=this.PropName;
            out.QueryName=this.QueryName;
            out.PropLable=this.PropLabel;

        end
    end

    methods(Static)
        function out=getTemplate()
            out=slreq.matrix.Filter;
        end
    end
end