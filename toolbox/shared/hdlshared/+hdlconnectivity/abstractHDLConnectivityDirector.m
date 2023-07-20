classdef abstractHDLConnectivityDirector<hgsetget&hdlconnectivity.HDLConnTree



















    properties
        builder;
adapter_list




        current_adapter;
        current_hdl_path;
        timingUtil;
    end

    properties(SetAccess='protected')
        pathDelim;

    end


    methods

        function delete(this)
            fn=fieldnames(this.adapter_list);
            for ii=1:numel(fn),
                delete(this.adapter_list.(fn{ii}));
            end


        end
    end



    methods(Abstract)

        setCurrentAdapter(this,adapter_type)
        addDriverReceiverPair(this,driver,receiver,varargin)
        addRegister(this,in,out,clock,clockenable,varargin)
        addDriverReceiverRegistered(this,varargin)
    end


    methods

        function setCurrentBuilder(this,bldr)
            this.builder=bldr;
        end



        function setCurrentHDLPath(this,path,inst_prefix,newhier)







            if nargin>2,
                if iscell(path),






                    eidx=cellfun(@isempty,path);
                    midstr=cell(size(path));
                    midstr(~eidx)={strcat(this.pathDelim,inst_prefix)};
                    path=strcat(path,midstr,newhier);

                else

                    if~isempty(path)
                        path=strcat(path,this.pathDelim,inst_prefix,newhier);
                    else
                        path=newhier;
                    end
                    path={path};
                end

            end
            this.current_hdl_path=path;
            this.allAdapterMethod('setCurrentHDLPath',path);

        end

        function path=getCurrentHDLPath(this)

            path=this.current_hdl_path;
        end

        function paths=getReg2RegPaths(this)

            paths=this.builder.bldrGetReg2RegPaths();
        end



        function setTimingUtil(this,tUtil)
            if~isempty(this.timingUtil)
                error(message('HDLShared:hdlconnectivity:resettimingutil'));
            end
            this.timingUtil=tUtil;
        end

        function tU=getTimingUtil(this)
            tU=this.timingUtil;
        end
        function addRelativeClockEnable(this,varargin)
            this.timingUtil.addRelativeClockEnable(varargin{:});
        end
        function addPipelinedClockEnable(this,varargin)
            this.timingUtil.addPipelinedClockEnable(varargin{:});
        end

        function compileClockEnables(this)
            tU=this.timingUtil;
            tU.compileEnbList();
        end




        function delim=getPathDelim(this)
            delim=this.pathDelim;
        end

        function setPathDelim(this,delim)
            if~isempty(this.pathDelim)&&this.pathDelim~=delim,
                error(message('HDLShared:hdlconnectivity:resetConnectivityPathDelim'));
            end
            this.updatePathDelims(delim);
        end


    end


    methods(Access=protected)

        function allAdapterMethod(this,meth,args)

            fn=fieldnames(this.adapter_list);
            for ii=1:numel(fn),
                adptr=this.adapter_list.(fn{ii});
                adptr.(meth)(args);
            end
        end

        function updatePathDelims(this,delim)



            this.pathDelim=delim;
            this.updateTimingUtilDelim(delim);
            this.updateBuilderDelim(delim);
        end


        function updateTimingUtilDelim(this,delim)
            tU=this.timingUtil;
            if~isempty(tU),
                tU.setPathDelim(delim);
            end
        end

        function updateBuilderDelim(this,delim)
            bldr=this.builder;
            if~isempty(bldr),
                bldr.setPathDelim(delim);
            end
        end

    end







end




