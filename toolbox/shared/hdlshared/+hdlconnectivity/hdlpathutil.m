classdef hdlpathutil<hgsetget&hdlconnectivity.HDLConnTree



















    properties

        ntwk_hdlpath_map;
        pathDelim;
    end

    methods

        function this=hdlpathutil(varargin)





            ip=inputParser;
            ip.addParamValue('pir',pir);
            ip.addParamValue('pathDelim','.',@(x)~isempty(regexp(x,'[/\\.]','once')));
            ip.parse(varargin{:});
            this.pathDelim=ip.Results.pathDelim;
            this.make_ntwk_paths(ip.Results.pir);
            clear ip;
        end

        function hpath=getComponentHDLPath(this,hC)


            try
                Ntwk=hC.Owner;
                hpath=this.ntwk_hdlpath_map(Ntwk.RefNum);
                hpath=strcat(hpath,[this.pathDelim,hC.Name]);
            catch me
                error(message('HDLShared:hdlconnectivity:getComponentHDLPathErr'))
            end
        end

        function hpath=getNetworkHDLPath(this,hN)

            if isa(hN,'hdlcoder.network'),

                try
                    hpath=this.ntwk_hdlpath_map(hN.RefNum);
                catch
                    error(message('HDLShared:hdlconnectivity:getNetworkHDLPathErr',hN.getErrorId))
                end
            else
                error(message('HDLShared:hdlconnectivity:getNetworkHDLPathCantCall'))
            end
        end

        function punct=getPathDelim(this)
            punct=this.pathDelim;
        end

    end

    methods(Access=private)

        function make_ntwk_paths(this,p)

            topN=p.getTopNetwork;

            this.ntwk_hdlpath_map=containers.Map();




            dutname=regexp(topN.Name,'(\w+)','tokens');
            dutname=dutname{end}{1};

            this.assign_path_prefix(topN,dutname);
        end

        function assign_path_prefix(this,hN,ntwk_path)
            if isKey(this.ntwk_hdlpath_map,hN.RefNum)
                curr_paths=this.ntwk_hdlpath_map(hN.RefNum);
                curr_paths{end+1}=ntwk_path;
                this.ntwk_hdlpath_map(hN.RefNum)=curr_paths;
            else
                this.ntwk_hdlpath_map(hN.RefNum)={ntwk_path};
            end

            for ii=1:numel(hN.Components),
                if isa(hN.Components(ii),'hdlcoder.ntwk_instance_comp'),
                    cmp=hN.Components(ii);

                    newpath=[ntwk_path,this.pathDelim,cmp.Name];
                    this.assign_path_prefix(cmp.ReferenceNetwork,newpath);
                end
            end
        end


    end

end


