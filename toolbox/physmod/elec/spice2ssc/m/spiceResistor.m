classdef spiceResistor<spiceBase






    properties
        value;
        ic;
        model;
    end

    properties(Access=private)
        r=1;
    end

    properties(Constant,Access=private)
        id="R";
    end

    methods
        function this=spiceResistor(str,varargin)
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
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceResistor:error_InputStringsToSpiceResistor')));
                end
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceResistor:warning_Resistor')),this.name);
                end


                if length(strComponents)<4
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end


                isDefinedByModel=isempty(regexpi(strComponents{4},"^[^a-z_A-Z]"));
                this.connectingNodes=[strComponents{2},strComponents{3}];
                if isDefinedByModel
                    strComponents=spiceBase.parseSpiceUnitsCell(strComponents,5);
                    this.model=strComponents{4};
                    if length(strComponents)<5
                        pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                    end
                    this.value=spiceBase.stripOuterBraces(strComponents{5});
                    argIndex=6;
                    if nargin<2
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                    elseif nargin>=2
                        if nargin>2
                            pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceResistor:warning_Arguments')),this.name);
                        end
                        models=varargin{1};
                        modelFound=false;
                        for ii=1:length(models)
                            modelStruct=spiceBase.parseModelDefinition(models(ii));
                            if strcmpi(modelStruct.name,this.model)&&strcmpi(modelStruct.type,"res")
                                modelFound=true;
                                break;
                            end
                        end
                        if~modelFound||~modelStruct.supportedString
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                        else
                            ndex=find(strcmpi(modelStruct.parameterNames,"r"));
                            odex=find(~strcmpi(modelStruct.parameterNames,"r"));
                            if~isempty(ndex)
                                if length(ndex)==1
                                    this.r=spiceBase.stripOuterBraces(modelStruct.parameterValues(ndex));
                                else
                                    this.unsupportedStrings(end+1)=strjoin([this.model,models(ii)]);
                                end
                            end
                            if~isempty(odex)
                                for ii=1:length(odex)
                                    this.unsupportedStrings(end+1)=strjoin([this.model,modelStruct.parameterNames(odex(ii))+" = "+modelStruct.parameterValues(odex(ii))]);
                                end
                            end
                        end
                    end
                else
                    strComponents=spiceBase.parseSpiceUnitsCell(strComponents,4);
                    this.model=string.empty;
                    if length(strComponents{4})>1
                        this.value=spiceBase.stripOuterBraces(strComponents{4}(2));
                    else
                        this.value=spiceBase.stripOuterBraces(strComponents{4});
                    end
                    argIndex=5;
                end
                if length(strComponents)>=argIndex
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",strjoin(cellfun(@strjoin,strComponents(argIndex:end)))]);
                end
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            if string(this.r)=="1"
                output.components=this.name...
                +" = foundation.electrical.elements.resistor(R={"...
                +this.value+",'Ohm'});";
            else
                output.components=this.name...
                +" = foundation.electrical.elements.resistor(R={("...
                +string(this.r)+")*("+this.value+"),'Ohm'});";
            end
            output.connections=this.getConnectionString;
        end
    end
end