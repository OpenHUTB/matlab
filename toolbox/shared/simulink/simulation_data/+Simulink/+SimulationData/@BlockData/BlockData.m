















classdef BlockData<Simulink.SimulationData.Element


    properties(Access='public')
        BlockPath=Simulink.SimulationData.BlockPath({});
        Values=[];
    end


    properties(Access='private',Hidden=true)
        VisualizationMetadata=[];
    end


    methods

        function this=set.BlockPath(this,val)


            if(isa(val,'Simulink.SimulationData.BlockPath'))
                this.BlockPath=val;
            else
                this.BlockPath=Simulink.SimulationData.BlockPath(val);
            end
        end


        function this=set.Values(this,val)



            if Simulink.SimulationData.utValidSignalOrCompositeData(val)

                this.Values=val;


            else
                Simulink.SimulationData.utError('InvalidBlockDataValues');
            end
        end


        function[elementVal,name,retIdx]=find(~,varargin)







            elementVal=[];
            name=[];
            retIdx=[];

        end


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
            ps.Values=this.Values;
            disp(ps);


            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ',mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n',mc.Name);
            end

        end


        function out=copy(this)


            n=numel(this);
            out=this;
            for idx=1:n
                out(idx).Values=Simulink.SimulationData.utCopyRecurse(this(idx).Values);
            end
        end



        function out=isequal(sig1,varargin)
            out=loc_eq(@isequal,sig1,varargin);
        end


        function out=isequaln(sig1,varargin)
            out=loc_eq(@isequaln,sig1,varargin);
        end

        function varargout=plot(this)

            ret=cell(1,nargout);
            [ret{:}]=Simulink.sdi.plot(this);
            varargout=ret;
        end

    end


    methods(Hidden=true)

        function ret=isFromBlock(this,bpath)



            if~isa(bpath,'Simulink.SimulationData.BlockPath')
                Simulink.SimulationData.utError('InvalidBlockDataFromBlock');
            end

            ret=this.BlockPath.pathIsLike(bpath);
        end

        function this=setVisualizationMetadata(this,val)
            this.VisualizationMetadata=val;
        end

        function ret=getVisualizationMetadata(this)
            ret=this.VisualizationMetadata;
        end


    end
end

function out=loc_eq(fcn,sig1,inputs)
    out=true;
    blockDataMeta=metaclass(Simulink.SimulationData.BlockData);
    props={blockDataMeta.PropertyList(:).Name};

    meta=metaclass(sig1);
    for k=1:length(inputs)
        sig2=inputs{k};

        meta2=metaclass(sig2);
        if~isequal(meta.Name,meta2.Name)
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


            for jp=1:length(props)
                if isequal(props{jp},'VisualizationMetadata')
                    continue;
                end
                if~fcn(sig1_elm.(props{jp}),sig2_elm.(props{jp}))
                    out=false;
                    return;
                end
            end
        end
    end
end