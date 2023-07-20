classdef spiceBjt<spiceBase








    properties
        value;
        ic;
        model;
        type;
    end

    properties(Access=private)
        area=1;
        bf=100;
        br=1;
        cjc=0;
        cje=0;
        cjs=0;
        eg=1.11;
        fc=0.5;
        ikf=inf;
        ikr=inf;
        irb=inf;
        is=1e-16;
        isc=0;
        ise=0;
        itf=0;
        mjc=0.33;
        mje=0.33;
        mjs=0;
        nc=2;
        ne=1.5;
        nf=1;
        nr=1;
        rb=0;
        rbm=0;
        rc=0;
        re=0;
        tf=0;
        tr=0;
        vaf=inf;
        var=inf;
        vjc=0.75;
        vje=0.75;
        vjs=0.75;
        vtf=inf;
        xcjc=1;
        xtb=0;
        xtf=0;
        xti=3;
    end

    properties(Constant,Access=private)
        id="Q";
    end

    methods
        function this=spiceBjt(str,varargin)
            this.nodes=["cx","bx","ex","sx"];
            if nargin<1

                this.name=string.empty;
                this.connectingNodes=string.empty;
                this.value=[];
                this.ic=[];
                this.model=string.empty;
            else
                str=string(str);
                if length(str)>1
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceBjt:error_InputStringsToSpiceBjt')));
                end
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,'BJT',this.name);
                end


                if length(strComponents)<5
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end



                if length(strComponents)==5
                    token5IsModel=true;
                elseif~isempty(regexp(strComponents{5},"^\d",'once'))
                    token5IsModel=false;
                else
                    models=varargin{1};
                    modelFound=false;
                    token5IsModel=false;
                    for ii=1:length(models)
                        modelStruct=spiceBase.parseModelDefinition(models(ii));
                        if strcmpi(modelStruct.name,strComponents{5})...
                            &&(strcmpi(modelStruct.type,"npn")...
                            ||strcmpi(modelStruct.type,"pnp"))
                            modelFound=true;
                            break;
                        end
                    end
                    if modelFound
                        token5IsModel=true;
                    end
                end



                if token5IsModel
                    this.connectingNodes=[strComponents{2},strComponents{3},strComponents{4},"0"];
                    this.model=strComponents{5};
                    strComponents=spiceBase.parseSpiceUnitsCell(strComponents,6);
                    if length(strComponents)>5
                        if~spiceBase.isLiteralParameter(strComponents{6})
                            this.area=spiceBase.stripOuterBraces(strComponents{6});
                        else
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{6}]);
                        end
                    end
                    if length(strComponents)>6
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",cellfun(@string,strComponents{7:end})]);
                    end
                else
                    this.connectingNodes=[strComponents{2},strComponents{3},strComponents{4},strComponents{5}];
                    strComponents=spiceBase.parseSpiceUnitsCell(strComponents,7);
                    this.model=strComponents{6};
                    if length(strComponents)>6
                        if~spiceBase.isLiteralParameter(strComponents{7})
                            this.area=spiceBase.stripOuterBraces(strComponents{7});
                        else
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{7}]);
                        end
                    end
                    if length(strComponents)>7
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",cellfun(@string,strComponents{8:end})]);
                    end
                end
                if nargin<2
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                elseif nargin>=2
                    if nargin>2
                        pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceBjt:warning_Arguments')),this.name);
                    end
                    models=varargin{1};
                    modelFound=false;
                    for ii=1:length(models)
                        modelStruct=spiceBase.parseModelDefinition(models(ii));
                        if strcmpi(modelStruct.name,this.model)...
                            &&(strcmpi(modelStruct.type,"npn")...
                            ||strcmpi(modelStruct.type,"pnp"))
                            modelFound=true;
                            break;
                        end
                    end
                    if~modelFound||~modelStruct.supportedString
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",str]);
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
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            if~isempty(this.type)
                if this.type=="npn"
                    output.components=this.name...
                    +" = ee.additional.spice_semiconductors.spice_npn(";
                elseif this.type=="pnp"
                    output.components=this.name...
                    +" = ee.additional.spice_semiconductors.spice_pnp(";
                end
                output.components=output.components...
                +"AREA={"+this.area+",'m^2'},"...
                +"BF={"+this.bf+",'1'},"...
                +"BR={"+this.br+",'1'},"...
                +"CJC={"+this.cjc+",'F/m^2'},"...
                +"CJE={"+this.cje+",'F/m^2'},"...
                +"CJS={"+this.cjs+",'F/m^2'},"...
                +"EG={"+this.eg+",'eV'},"...
                +"FC={"+this.fc+",'1'},"...
                +"IKF={"+this.ikf+",'A/m^2'},"...
                +"IKR={"+this.ikr+",'A/m^2'},"...
                +"IRB={"+this.irb+",'A/m^2'},"...
                +"IS={"+this.is+",'A/m^2'},"...
                +"ISC={"+this.isc+",'A/m^2'},"...
                +"ISE={"+this.ise+",'A/m^2'},"...
                +"ITF={"+this.itf+",'A/m^2'},"...
                +"MJC={"+this.mjc+",'1'},"...
                +"MJE={"+this.mje+",'1'},"...
                +"MJS={"+this.mjs+",'1'},"...
                +"NC={"+this.nc+",'1'},"...
                +"NE={"+this.ne+",'1'},"...
                +"NF={"+this.nf+",'1'},"...
                +"NR={"+this.nr+",'1'},"...
                +"RB={"+this.rb+",'Ohm*m^2'},"...
                +"RBM={"+this.rbm+",'Ohm*m^2'},"...
                +"RC={"+this.rc+",'Ohm*m^2'},"...
                +"RE={"+this.re+",'Ohm*m^2'},"...
                +"TF={"+this.tf+",'s'},"...
                +"TR={"+this.tr+",'s'},"...
                +"VAF={"+this.vaf+",'V'},"...
                +"VAR={"+this.var+",'V'},"...
                +"VJC={"+this.vjc+",'V'},"...
                +"VJE={"+this.vje+",'V'},"...
                +"VJS={"+this.vjs+",'V'},"...
                +"VTF={"+this.vtf+",'V'},"...
                +"XCJC={"+this.xcjc+",'1'},"...
                +"XTB={"+this.xtb+",'1'},"...
                +"XTF={"+this.xtf+",'1'},"...
                +"XTI={"+this.xti+",'1'},"...
                +"C_param=2);";
                output.connections=this.getConnectionString;
            else
                output=string.empty;
            end
        end
    end
end