















classdef Signal<Simulink.SimulationData.BlockData


    properties(Access='public')
        PortType='inport';
        PortIndex=1;
        PropagatedName='';
    end

    properties(Hidden=true,GetAccess=public,SetAccess=private)
        Version=0;
    end


    methods

        function this=Signal()
            this.Version=1;
        end

        function tt=extractTimetable(this,varargin)















































































































            tt=matlab.internal.tabular.extractTimetable(this,varargin{:});
        end


        function this=set.PortType(this,val)


            if strcmp(val,'inport')||strcmp(val,'outport')
                this.PortType=val;
            else
                Simulink.SimulationData.utError('InvalidSignalPortType');
            end
        end


        function this=set.PortIndex(this,val)

            validateattributes(val,{'numeric'},...
            {'real','integer','scalar','positive','nonsparse'});
            this.PortIndex=double(val);
        end


        function this=set.PropagatedName(this,val)


            if ischar(val)||isstring(val)
                this.PropagatedName=char(val);
                this.Version=1;%#ok
            else
                Simulink.SimulationData.utError('InvalidSignalPropagatedName');
            end
        end



        function out=isequal(sig1,varargin)
            out=loc_eq(@isequal,sig1,varargin);
        end


        function out=isequaln(sig1,varargin)
            out=loc_eq(@isequaln,sig1,varargin);
        end
    end



    methods(Hidden=true)
        function disp(this)



            if length(this)~=1
                Simulink.SimulationData.utNonScalarDisp(this);
                return;
            end


            mc=metaclass(this);
            if feature('hotlinks')
                fprintf('  <a href="matlab: help %s">%s</a>\n',mc.Name,mc.Name);
            else
                fprintf('  %s\n',mc.Name);
            end


            fprintf('  Package: %s\n\n',mc.ContainingPackage.Name);


            fprintf('  Properties:\n');
            ps.Name=this.Name;
            ps.PropagatedName=this.PropagatedName;
            ps.BlockPath=this.BlockPath;
            ps.PortType=this.PortType;
            ps.PortIndex=this.PortIndex;
            ps.Values=this.Values;
            disp(ps);


            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ',mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n',mc.Name);
            end

        end
    end
end
function out=loc_eq(fcn,sig1,inputs)
    out=true;

    meta=metaclass(sig1);
    if~isequal(meta.Name,'Simulink.SimulationData.Signal')
        out=false;
        return
    end

    props={meta.PropertyList(:).Name};
    skip={'Version','PropagatedName'};
    propToCheck=setxor(props,skip);

    for k=1:length(inputs)
        sig2=inputs{k};

        meta2=metaclass(sig2);
        if~isequal(meta2.Name,'Simulink.SimulationData.Signal')
            out=false;
            return;
        end

        if~isequal(size(sig1),size(sig2))
            out=false;
            return;
        end

        for ielm=1:numel(sig1)
            sig1_elm=sig1(ielm);
            sig2_elm=sig2(ielm);


            for jp=1:length(propToCheck)
                if~fcn(sig1_elm.(propToCheck{jp}),sig2_elm.(propToCheck{jp}))
                    out=false;
                    return;
                end
            end


            if sig1_elm.Version>=1&&sig2_elm.Version>=1
                if~fcn(sig1_elm.PropagatedName,sig2_elm.PropagatedName)
                    out=false;
                    return;
                end
            end
        end
    end
end


