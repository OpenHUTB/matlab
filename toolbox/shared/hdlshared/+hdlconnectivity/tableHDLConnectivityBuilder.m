classdef tableHDLConnectivityBuilder<hdlconnectivity.abstractHDLConnectivityBuilder












    properties(SetAccess='private')
        NetLL;
        RegLL;
    end

    methods

        function this=tableHDLConnectivityBuilder
            this.NetLL=containers.Map();
            this.RegLL=containers.Map();
        end
    end

    methods


        function bldrAddDriverReceiverPair(this,driver,receiver,varargin)

            tablekey=[receiver.path,this.pathDelim,receiver.name];

            if isKey(this.NetLL,tablekey),
                this.NetLL(tablekey)=cat(2,this.NetLL(tablekey),[driver.path,this.pathDelim,driver.name]);
            else
                this.NetLL(tablekey)={[driver.path,this.pathDelim,driver.name]};
            end

        end


        function bldrAddRegister(this,reg)
            regout=reg.output;
            regkey=[regout.path,this.pathDelim,regout.name];
            this.RegLL(regkey)=reg;
        end


        function r2rpaths=bldrGetReg2RegPaths(this)



            try
                r2rpaths=struct([]);
                rlist=this.RegLL.values;
                if isempty(rlist),
                    return
                end

                for ii=1:numel(rlist),
                    reg=rlist{ii};


                    drvrs=this.get_driver({[reg.input.path,this.pathDelim,reg.input.name]});
                    if~isempty(drvrs)




                        drvrs=unique(drvrs);
                        drvrs_regh=values(this.RegLL,drvrs);


                        if isempty(r2rpaths),
                            r2rpaths=struct('TO',reg,'FROM',drvrs_regh);
                        else
                            r2rpaths(end+1:end+numel(drvrs_regh))=struct(...
                            'TO',reg,'FROM',drvrs_regh);
                        end
                    end
                end
            catch me
                error(message('HDLShared:hdlconnectivity:GetReg2RegPaths',...
                reg.output(1).path,reg.output(1).name,me.message));
            end
        end
    end


    methods(Access='private')


        function drvr=get_driver(this,net)


            drvr={};
            while~isempty(net)
                drvr=cat(2,drvr,this.regoutputs(net));
                net=unique(this.netdriver(net));
            end
        end


        function dregs=regoutputs(this,net)

            keytf=isKey(this.RegLL,net);
            if all(~keytf),
                dregs={};
            else
                dregs=net(keytf);
            end


        end

        function dnets=netdriver(this,net)

            keytf=isKey(this.NetLL,net);
            if all(~keytf),
                dnets={};
            else
                dnets=values(this.NetLL,net(keytf));
                dnets=cat(2,dnets{:});
            end

        end
    end



end


