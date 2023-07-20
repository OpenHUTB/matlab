classdef spiceCapacitor<spiceBase






    properties
        value;
        ic;
        model;
    end

    properties(Access=private)
        c=1;
    end

    properties(Constant,Access=private)
        id="C";
    end

    methods
        function this=spiceCapacitor(str,varargin)
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
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceCapacitor:error_InputStringsToSpiceCapacitor')));
                end
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceCapacitor:warning_Capacitor')),this.name);
                end


                if length(strComponents)<4
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end


                isDefinedByModel=isempty(regexpi(strComponents{4},"^[^a-z_A-Z]"));
                this.connectingNodes=[strComponents{2},strComponents{3}];
                usedIndices=1:3;
                if isDefinedByModel
                    this.model=strComponents{4};
                    usedIndices=[usedIndices,4];
                    strComponents=spiceBase.parseSpiceUnitsCell(strComponents,5);
                    if length(strComponents)<5
                        pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                    end
                    this.value=spiceBase.stripOuterBraces(strComponents{5});
                    usedIndices=[usedIndices,5];
                    if nargin<2
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                    elseif nargin>=2
                        if nargin>2
                            pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceCapacitor:warning_Arguments')),this.name);
                        end
                        models=varargin{1};
                        modelFound=false;
                        for ii=1:length(models)
                            modelStruct=spiceBase.parseModelDefinition(models(ii));
                            if strcmpi(modelStruct.name,this.model)&&strcmpi(modelStruct.type,"cap")
                                modelFound=true;
                                break;
                            end
                        end
                        if~modelFound||~modelStruct.supportedString
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                        else
                            ndex=find(strcmpi(modelStruct.parameterNames,"c"));
                            odex=find(~strcmpi(modelStruct.parameterNames,"c"));
                            if~isempty(ndex)
                                if length(ndex)==1
                                    this.c=modelStruct.parameterValues(ndex);
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
                    this.model=string.empty;
                    strComponents=spiceBase.parseSpiceUnitsCell(strComponents,4);
                    if length(strComponents{4})>1
                        this.value=spiceBase.stripOuterBraces(strComponents{4}(2));
                    else
                        this.value=spiceBase.stripOuterBraces(strComponents{4});
                    end
                    usedIndices=[usedIndices,4];
                end

                idx=spiceBase.findNameEquals(strComponents,"ic");
                equalsBased=true;
                if isempty(idx)
                    idx=spiceBase.findName(strComponents,"ic");
                    equalsBased=false;
                end
                if~isempty(idx)
                    if equalsBased
                        this.ic=spiceBase.stripOuterBraces(strComponents{idx}(2));
                    else
                        this.ic=spiceBase.stripOuterBraces(strComponents{idx});
                    end
                    usedIndices=[usedIndices,idx];
                end
                unusedIndices=setdiff(1:length(strComponents),usedIndices);
                for ii=1:length(unusedIndices)
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{unusedIndices(ii)}]);
                end
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            if string(this.c)=="1"
                output.components=this.name...
                +" = foundation.electrical.elements.capacitor(c={"...
                +this.value+",'F'},r=capacitorSeriesResistance,g={0,'1/Ohm'}";
            else
                output.components=this.name...
                +" = foundation.electrical.elements.capacitor(c={("...
                +string(this.c)+")*("+this.value+...
                "),'F'},r=capacitorSeriesResistance,g={0,'1/Ohm'}";
            end
            if isempty(this.ic)
                output.components=output.components+",vc.priority=priority.none);";
            else
                output.components=output.components+",vc.value={"...
                +string(this.ic)+",'V'},vc.priority=priority.high);";
            end
            output.connections=this.getConnectionString;
        end
    end
end