


































classdef DataStoreMemory<Simulink.SimulationData.BlockData


    properties(SetAccess=private,GetAccess=public)
        Scope='local';
        DSMWriterBlockPaths=[];
        DSMWriters=[];
    end



    methods

        function this=DataStoreMemory(name,bpath,scope,writePaths,writers,values)

            if nargin>0
                narginchk(6,6);


                this.Name=name;


                this.BlockPath=bpath;


                if~strcmp(scope,'local')&&~strcmp(scope,'global')
                    Simulink.SimulationData.utError('InvalidDSMscope');
                end
                this.Scope=scope;


                if~isa(values,'timeseries')
                    Simulink.SimulationData.utError('InvalidDSMvalues');
                end
                this.Values=values;


                sz=size(writePaths);
                if sz(2)~=1||length(sz)~=2||...
                    ~isa(writePaths,'Simulink.SimulationData.BlockPath')
                    Simulink.SimulationData.utError('InvalidDSMwriterPaths');
                end
                this.DSMWriterBlockPaths=writePaths;
                num_writers=sz(1);


                sz=size(writers);
                num_time_pts=length(values.Time);
                if length(sz)~=2||sz(1)~=num_time_pts||sz(2)~=1||~isa(writers,'double')
                    Simulink.SimulationData.utError('InvalidDSMwriters');
                end
                errors=or(writers>num_writers,writers<1);
                if~isequal(errors,zeros(size(writers)))
                    Simulink.SimulationData.utError('InvalidDSMwriterIdx',num_writers);
                end
                this.DSMWriters=writers;
            end
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
            ps.BlockPath=this.BlockPath;
            ps.Scope=this.Scope;
            ps.DSMWriterBlockPaths=this.DSMWriterBlockPaths;
            ps.DSMWriters=this.DSMWriters;
            ps.Values=this.Values;
            disp(ps);


            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ',mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n',mc.Name);
            end

        end

        function this=utSetScope(this,val)


            this.Scope=val;
        end


        function this=utSetWriters(this,writers)




            if(isempty(writers))
                this.DSMWriterBlockPaths=[];
            else
                this.DSMWriterBlockPaths=...
                Simulink.SimulationData.BlockPath(writers{1});
                for idx=2:length(writers)
                    this.DSMWriterBlockPaths(idx)=...
                    Simulink.SimulationData.BlockPath(writers{idx});
                end
            end
        end


        function this=utSetWriterIndices(this,val)


            this.DSMWriters=val;
        end


        function res=convertWriterPathsToCell(this)




            res=cell(length(this.DSMWriterBlockPaths),...
            ~isempty(this.DSMWriterBlockPaths));

            for idx=1:length(this.DSMWriterBlockPaths)
                res{idx}=this.DSMWriterBlockPaths(idx).convertToCell();
            end

        end


    end

end
