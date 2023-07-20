classdef spiceIgbt<spiceBase









    properties
        value;
        ic;
        model;
        type;
    end

    properties(Access=private)
        agd=5e-6;
        area=1e-5;
        bvf=1;
        bvn=4;
        cgs=1.24e-8;
        coxd=3.5e-8;
        jsne=6.5e-13;
        kf=1;
        kp=0.38;
        mun=1.5e3;
        mup=4.5e2;
        nb=2e14;
        tau=7.1e-6;
        theta=0.02;
        vt=4.7;
        vtd=1e-3;
        wb=9e-5;
    end

    properties(Constant,Access=private)
        id="Z";
    end

    methods
        function this=spiceIgbt(str,varargin)
            this.nodes=["cx","gx","ex"];
            if nargin<1

                this.name=string.empty;
                this.connectingNodes=string.empty;
                this.value=[];
                this.ic=[];
                this.model=string.empty;
            else
                str=string(str);
                if length(str)>1
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceIgbt:error_InputStringsToSpiceIgbt')));
                end
                str=spiceBase.parseSpiceUnitsIdx(str,6);
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceIgbt:warning_Igbt')),this.name);
                end


                if length(strComponents)<5
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end



                this.connectingNodes=[strComponents{2},strComponents{3},strComponents{4}];
                this.model=strComponents{5};


                if nargin<2
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                elseif nargin>=2
                    if nargin>2
                        pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceIgbt:warning_Arguments')),this.name);
                    end
                    models=varargin{1};
                    modelFound=false;
                    for ii=1:length(models)
                        modelStruct=spiceBase.parseModelDefinition(models(ii));
                        if strcmpi(modelStruct.name,this.model)...
                            &&(strcmpi(modelStruct.type,"nigbt"))
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
                for ii=6:length(strComponents)
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
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            if~isempty(this.type)
                if this.type=="nigbt"
                    output.components=this.name...
                    +" = ee.additional.spice_semiconductors.spice_nigbt(";
                else
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.type);
                end
                output.components=output.components...
                +"AGD={"+this.agd+",'m^2'},"...
                +"AREA={"+this.area+",'m^2'},"...
                +"KF={"+this.kf+",'1'},"...
                +"KP={"+this.kp+",'A/V^2'},"...
                +"VT={"+this.vt+",'V'},"...
                +"THETA={"+this.theta+",'1/V'},"...
                +"MUN={"+this.mun+",'cm^2/(V*s)'},"...
                +"MUP={"+this.mup+",'cm^2/(V*s)'},"...
                +"NB={"+this.nb+",'1/cm^3'},"...
                +"TAU={"+this.tau+",'s'},"...
                +"WB={"+this.wb+",'m'},"...
                +"JSNE={"+this.jsne+",'A/cm^2'},"...
                +"BVF={"+this.bvf+",'1'},"...
                +"BVN={"+this.bvn+",'1'},"...
                +"CGS={"+this.cgs+",'F/cm^2'},"...
                +"COXD={"+this.coxd+",'F/cm^2'},"...
                +"VTD={"+this.vtd+",'V'});";
                output.connections=this.getConnectionString;
            else
                output=string.empty;
            end
        end
    end
end