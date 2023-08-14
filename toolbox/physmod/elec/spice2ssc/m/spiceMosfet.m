classdef spiceMosfet<spiceBase









    properties
        value;
        ic;
        model;
        type;
    end

    properties(Access=private)
        ad=0;
        as=0;
        cbd=0;
        cbs=0;
        cgbo=0;
        cgdo=0;
        cgso=0;
        cj=0;
        cjsw=0;
        delta=0;
        eta=0;
        fc=0.5;
        gamma="nan";
        is=1e-14;
        js=0;
        kappa=0.2;
        kp="nan";
        lambda=0;
        ld=0;
        l=100e-6;
        level=1;
        m=1;
        mj=0.5;
        mjsw=0.33;
        n=1;
        neff=1;
        nfs=0;
        nss='nan';
        nsub="nan";
        nrd=0;
        nrs=0;
        pb=0.8;
        pd=0;
        phi="nan";
        ps=0;
        rd="nan";
        rs="nan";
        rsh="nan";
        theta=0;
        tox="nan";
        tpg=1;
        ucrit=1e4;
        uexp=0;
        uo=600;
        vmax=0;
        vto="nan";
        xj=0;
        w=100e-6;
        ci_param='3';
    end

    properties(Constant,Access=private)
        id="M";
    end

    methods
        function this=spiceMosfet(str,varargin)
            this.nodes=["dx","gx","sx","bx"];
            if nargin<1

                this.name=string.empty;
                this.connectingNodes=string.empty;
                this.value=[];
                this.ic=[];
                this.model=string.empty;
            else
                str=string(str);
                if length(str)>1
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceMosfet:error_InputStringsToSpiceMosfet')));
                end
                str=spiceBase.parseSpiceUnitsIdx(str,7);
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceMosfet:warning_MOSFET')),this.name);
                end


                if length(strComponents)<6
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end



                this.connectingNodes=[strComponents{2},strComponents{3},strComponents{4},strComponents{5}];
                this.model=strComponents{6};
                if nargin<2
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                elseif nargin>=2
                    if nargin>2
                        pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceMosfet:warning_Arguments')),this.name);
                    end
                    models=varargin{1};
                    modelFound=false;
                    for ii=1:length(models)
                        modelStruct=spiceBase.parseModelDefinition(models(ii));
                        if strcmpi(modelStruct.name,this.model)...
                            &&(strcmpi(modelStruct.type,"nmos")...
                            ||strcmpi(modelStruct.type,"pmos"))
                            modelFound=true;
                            break;
                        end
                    end
                    if~modelFound||~modelStruct.supportedString
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                    else
                        this.type=modelStruct.type;
                        for ii=1:length(modelStruct.parameterNames)
                            if isprop(this,lower(modelStruct.parameterNames(ii)))
                                this.(lower(modelStruct.parameterNames(ii)))=modelStruct.parameterValues{ii};
                            else
                                this.unsupportedStrings(end+1)=strjoin([this.name+":",modelStruct.parameterNames(ii),"=",modelStruct.parameterValues{ii}]);
                            end
                        end
                    end
                end
                for ii=7:length(strComponents)
                    if length(strComponents{ii})~=2
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{ii}]);
                    else
                        if isprop(this,lower(strComponents{ii}(1)))
                            this.(lower(strComponents{ii}(1)))=spiceBase.stripOuterBraces(strComponents{ii}(2));
                        else
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{ii}(1),"=",strComponents{ii}(2)]);
                        end
                    end
                end
                if this.level==3&&string(this.tox)=="nan"
                    this.tox=1e-7;
                end
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            if~isempty(this.type)
                if this.type=="nmos"
                    output.components=this.name...
                    +" = ee.additional.spice_semiconductors.spice_nmos(";
                elseif this.type=="pmos"
                    output.components=this.name...
                    +" = ee.additional.spice_semiconductors.spice_pmos(";
                end
                if this.level==1&&string(this.tox)=="nan"
                    this.ci_param=1;
                end
                output.components=output.components...
                +"AD={"+this.ad+",'m^2'},"...
                +"AS={"+this.as+",'m^2'},"...
                +"CBD={"+this.cbd+",'F'},"...
                +"CBS={"+this.cbs+",'F'},"...
                +"CGBO={"+this.cgbo+",'F/m'},"...
                +"CGDO={"+this.cgdo+",'F/m'},"...
                +"CGSO={"+this.cgso+",'F/m'},"...
                +"CJ={"+this.cj+",'F/m^2'},"...
                +"CJSW={"+this.cjsw+",'F/m'},"...
                +"DELTA={"+this.delta+",'1'},"...
                +"ETA={"+this.eta+",'1'},"...
                +"FC={"+this.fc+",'1'},"...
                +"GAMMA={"+this.gamma+",'V^0.5'},"...
                +"IS={"+this.is+",'A'},"...
                +"JS={"+this.js+",'A/m^2'},"...
                +"KAPPA={"+this.kappa+",'1'},"...
                +"KP={"+this.kp+",'A/V^2'},"...
                +"LAMBDA={"+this.lambda+",'1/V'},"...
                +"LD={"+this.ld+",'m'},"...
                +"LENGTH={"+this.l+",'m'},"...
                +"LEVEL={"+this.level+",'1'},"...
                +"SCALE={"+this.m+",'1'},"...
                +"MJ={"+this.mj+",'1'},"...
                +"MJSW={"+this.mjsw+",'1'},"...
                +"N={"+this.n+",'1'},"...
                +"NEFF={"+this.neff+",'1'},"...
                +"NFS={"+this.nfs+",'1/cm^2'},"...
                +"NSS={"+this.nss+",'1/cm^2'},"...
                +"NSUB={"+this.nsub+",'1/cm^3'},"...
                +"NRD={"+this.nrd+",'1'},"...
                +"NRS={"+this.nrs+",'1'},"...
                +"PB={"+this.pb+",'V'},"...
                +"PD={"+this.pd+",'m'},"...
                +"PHI={"+this.phi+",'V'},"...
                +"PS={"+this.ps+",'m'},"...
                +"RD={"+this.rd+",'Ohm'},"...
                +"RS={"+this.rs+",'Ohm'},"...
                +"RSH={"+this.rsh+",'Ohm'},"...
                +"THETA={"+this.theta+",'1/V'},"...
                +"TOX={"+this.tox+",'m'},"...
                +"TPG={"+this.tpg+",'1'},"...
                +"UCRIT={"+this.ucrit+",'V/cm'},"...
                +"UEXP={"+this.uexp+",'1'},"...
                +"U0={"+this.uo+",'cm^2/(V*s)'},"...
                +"VMAX={"+this.vmax+",'m/s'},"...
                +"VTO={"+this.vto+",'V'},"...
                +"XJ={"+this.xj+",'m'},"...
                +"WIDTH={"+this.w+",'m'},"...
                +"Ci_param={"+this.ci_param+",'1'},"...
                +"Cov_param=2,"...
                +"C_param=2);";
                output.connections=this.getConnectionString;
            else
                output=string.empty;
            end
        end
    end
end