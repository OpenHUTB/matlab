classdef spiceDiode<spiceBase






    properties
        value;
        ic;
        model;
    end

    properties(Access=private)
        area=1;
        scale=1;
        is=1e-14;
        ikf=Inf;
        isr=0;
        n=1;
        nr=2;
        m=0.5;
        vj=1;
        rs=1e-12;
        c_param=2;
        cjo=0;
        fc=0.5;
        tt=0;
        revbrk=2;
        bv=inf;
        ibv=1e-10;
        ibvl=1e-10;
        nbv=1;
        nbvl=1;
        xti=3;
        eg=1.11;
        tikf=0;
        trs1=0;
        trs2=0;
        tbv1=0;
        tbv2=0;
    end

    properties(Constant,Access=private)
        id="D";
    end

    methods
        function this=spiceDiode(str,varargin)
            this.nodes=["p","n"];
            if nargin<1

                this.name=string.empty;
                this.connectingNodes=string.empty;
                this.value=[];
                this.ic=[];
                this.model=string.empty;
            else
                str=string(str);
                if length(str)>1
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceDiode:error_InputStringsToSpiceDiode')));
                end
                str=spiceBase.parseSpiceUnitsIdx(str,5);
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceDiode:warning_Diode')),this.name);
                end


                if length(strComponents)<4
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end


                this.connectingNodes=[strComponents{2},strComponents{3}];
                this.model=strComponents{4};
                if length(strComponents)>=5
                    if~spiceBase.isLiteralParameter(strComponents{5})
                        this.area=spiceBase.stripOuterBraces(strComponents{5});
                        if length(strComponents)>5
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{6:end}]);
                        end
                    else
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{5:end}]);
                    end
                end
                if nargin<2
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                elseif nargin>=2
                    if nargin>2
                        pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceDiode:warning_Arguments')),this.name);
                    end
                    models=varargin{1};
                    modelFound=false;
                    for ii=1:length(models)
                        modelStruct=spiceBase.parseModelDefinition(models(ii));
                        if strcmpi(modelStruct.name,this.model)&&strcmpi(modelStruct.type,"d")
                            modelFound=true;
                            break;
                        end
                    end
                    if~modelFound||~modelStruct.supportedString
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                    else
                        for ii=1:length(modelStruct.parameterNames)
                            if isprop(this,lower(modelStruct.parameterNames(ii)))
                                this.(lower(modelStruct.parameterNames(ii)))=modelStruct.parameterValues{ii};
                            else
                                this.unsupportedStrings(end+1)=strjoin([this.name+":",modelStruct.parameterNames(ii),"=",modelStruct.parameterValues{ii}]);
                            end
                        end
                    end
                end
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            output.components=this.name...
            +" = ee.additional.spice_semiconductors.spice_diode("...
            +"AREA={"+this.area+",'m^2'},"...
            +"SCALE={"+this.scale+",'1'},"...
            +"IS={"+this.is+",'A/m^2'},"...
            +"IKF={"+this.ikf+",'A/m^2'},"...
            +"ISR={"+this.isr+",'A/m^2'},"...
            +"N={"+this.n+",'1'},"...
            +"NR={"+this.nr+",'1'},"...
            +"M={"+this.m+",'1'},"...
            +"VJ={"+this.vj+",'V'},"...
            +"RS={"+this.rs+",'Ohm*m^2'},"...
            +"C_param={"+this.c_param+",'1'},"...
            +"CJO={"+this.cjo+",'F/m^2'},"...
            +"FC={"+this.fc+",'1'},"...
            +"TT={"+this.tt+",'s'},"...
            +"RevBrk={"+this.revbrk+",'1'},"...
            +"BV={"+this.bv+",'V'},"...
            +"IBV={"+this.ibv+",'A/m^2'},"...
            +"IBVL={"+this.ibvl+",'A/m^2'},"...
            +"NBV={"+this.nbv+",'1'},"...
            +"NBVL={"+this.nbvl+",'1'},"...
            +"XTI={"+this.xti+",'1'},"...
            +"EG={"+this.eg+",'eV'},"...
            +"TIKF={"+this.tikf+",'K^-1'},"...
            +"TRS1={"+this.trs1+",'K^-1'},"...
            +"TRS2={"+this.trs2+",'K^-2'},"...
            +"TBV1={"+this.tbv1+",'K^-1'},"...
            +"TBV2={"+this.tbv2+",'K^-2'});";
            output.connections=this.getConnectionString;
        end
    end
end