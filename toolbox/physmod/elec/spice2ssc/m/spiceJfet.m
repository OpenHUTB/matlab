classdef spiceJfet<spiceBase







    properties
        value;
        ic;
        model;
        type;
    end

    properties(Access=private)
        area=1;
        beta=1e-4;
        cgd=0;
        cgs=0;
        fc=0.5;
        is=1e-14;
        lambda=0;
        m=0.5;
        n=1;
        rd=1e-12;
        rs=1e-12;
        vto=-2;
        xti=3;
    end

    properties(Constant,Access=private)
        id="J";
    end

    methods
        function this=spiceJfet(str,varargin)
            this.nodes=["dx","gx","sx"];
            if nargin<1

                this.name=string.empty;
                this.connectingNodes=string.empty;
                this.value=[];
                this.ic=[];
                this.model=string.empty;
            else
                str=string(str);
                if length(str)>1
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceJfet:error_InputStringsToSpiceJfet')));
                end
                str=spiceBase.parseSpiceUnitsIdx(str,6);
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceJfet:warning_JFET')),this.name);
                end


                if length(strComponents)<5
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end



                this.connectingNodes=[strComponents{2},strComponents{3},strComponents{4}];
                this.model=strComponents{5};
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
                if nargin<2
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                elseif nargin>=2
                    if nargin>2
                        pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceJfet:warning_Arguments')),this.name);
                    end
                    models=varargin{1};
                    modelFound=false;
                    for ii=1:length(models)
                        modelStruct=spiceBase.parseModelDefinition(models(ii));
                        if strcmpi(modelStruct.name,this.model)...
                            &&(strcmpi(modelStruct.type,"njf")...
                            ||strcmpi(modelStruct.type,"pjf"))
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
                if this.type=="njf"
                    output.components=this.name...
                    +" = ee.additional.spice_semiconductors.spice_njfet(";
                elseif this.type=="pjf"
                    output.components=this.name...
                    +" = ee.additional.spice_semiconductors.spice_pjfet(";
                end
                output.components=output.components...
                +"AREA={"+this.area+",'m^2'},"...
                +"BETA={"+this.beta+",'A/(V^2*m^2)'},"...
                +"CGD={"+this.cgd+",'F/m^2'},"...
                +"CGS={"+this.cgs+",'F/m^2'},"...
                +"FC={"+this.fc+",'1'},"...
                +"IS={"+this.is+",'A/m^2'},"...
                +"LAMBDA={"+this.lambda+",'1/V'},"...
                +"M={"+this.m+",'1'},"...
                +"N={"+this.n+",'1'},"...
                +"RD={"+this.rd+",'Ohm*m^2'},"...
                +"RS={"+this.rs+",'Ohm*m^2'},"...
                +"VTO={"+this.vto+",'V'},"...
                +"XTI={"+this.xti+",'1'},"...
                +"C_param=2);";
                output.connections=this.getConnectionString;
            else
                output=string.empty;
            end
        end
    end
end