classdef CodegenInfo<handle






    properties

hN
layer2comp
NetworkInfo
netname
codegendir
codegentarget
dlcfg
connectivity

    end

    methods


        function this=CodegenInfo(hN,layer2comp,networkInfo,netname,...
            codegendir,codegentarget,dlcfg,connectivity)

            this.hN=hN;
            this.layer2comp=layer2comp;
            this.NetworkInfo=networkInfo;
            this.netname=netname;
            this.codegendir=codegendir;
            this.codegentarget=codegentarget;
            this.dlcfg=dlcfg;
            this.connectivity=connectivity;

        end
    end

end
