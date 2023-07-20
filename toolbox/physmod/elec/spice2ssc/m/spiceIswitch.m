classdef spiceIswitch<spiceBase







    properties
        value;
        ic;
        model;
        type;
    end

    properties(Access=private)
        switchModel=nan;
        ron=1;
        roff=nan;
        ion=1e-3;
        ioff=0;
        it=0;
        ih=0;
        td=0;
        roffGmin=ee.enum.switches.offResistance.no;
        roff_res_gmin=ee.enum.switches.offResistance.no;
        controlSource;
    end

    properties(Constant,Access=private)
        id="W";
    end

    methods
        function this=spiceIswitch(str,varargin)
            this.nodes=["p2","n2","n1"];
            if nargin<1

                this.name=string.empty;
                this.connectingNodes=string.empty;
                this.value=[];
                this.ic=[];
                this.model=string.empty;
            else
                str=string(str);
                if length(str)>1
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceIswitch:error_InputStringsToSpiceIswitch')));
                end
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceIswitch:warning_CurrentcontrolledSwitch')),this.name);
                end


                if length(strComponents)<5
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end



                this.connectingNodes=[strComponents{2},strComponents{3},"0"];
                this.controlSource=strComponents{4};
                if~strncmpi(this.controlSource,"V",1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier','V',getString(message('physmod:ee:library:comments:spice2ssc:spiceIswitch:warning_CurrentmeasuringVoltageSource')),this.controlSource);
                end
                this.model=strComponents{5};
                if length(strComponents)>5
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",cellfun(@string,strComponents{6:end})]);
                end
                if nargin<2
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                elseif nargin>=2
                    if nargin>2
                        pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceIswitch:warning_Arguments')),this.name);
                    end
                    models=varargin{1};
                    modelFound=false;
                    for ii=1:length(models)
                        modelStruct=spiceBase.parseModelDefinition(models(ii));
                        if strcmpi(modelStruct.name,this.model)...
                            &&(strcmpi(modelStruct.type,"csw")...
                            ||strcmpi(modelStruct.type,"iswitch"))
                            modelFound=true;

                            resModel=false;
                            transModel=false;
                            if any(strcmpi(modelStruct.parameterNames,'ion'))...
                                ||any(strcmpi(modelStruct.parameterNames,'ioff'))

                                resModel=true;
                            end
                            if any(strcmpi(modelStruct.parameterNames,'it'))

                                transModel=true;
                            end
                            if resModel&&transModel

                                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceIswitch:error_MixingOfParameters')));
                            elseif~resModel&&~transModel
                                if strcmpi(modelStruct.type,"csw")
                                    transModel=true;
                                elseif strcmpi(modelStruct.type,"iswitch")
                                    resModel=true;
                                end
                            end
                            if resModel

                                this.switchModel=ee.enum.switches.switchModel.resistance;
                            elseif transModel

                                this.switchModel=ee.enum.switches.switchModel.transition;
                            end
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
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            if isnan(this.switchModel)

                this.switchModel=ee.enum.switches.switchModel.transition;

            end

            if this.switchModel==ee.enum.switches.switchModel.resistance
                if~isstring(this.roff)
                    if isnan(this.roff)
                        this.roff=1e6;
                    end
                end
                output.components=this.name...
                +" = ee.additional.spice_passives.iswitch("...
                +"SWITCH_model="+this.switchModel+","...
                +"IOFF={"+this.ioff+",'A'},"...
                +"ION={"+this.ion+",'A'},"...
                +"ROFF_res={"+this.roff+",'Ohm'},"...
                +"RON={"+this.ron+",'Ohm'});";
            else
                if~isstring(this.roff)
                    if isnan(this.roff)
                        this.roffGmin=ee.enum.switches.offResistance.yes;
                        this.roff=1e12;
                    end
                end
                output.components=this.name...
                +" = ee.additional.spice_passives.iswitch("...
                +"SWITCH_model="+this.switchModel+","...
                +"IT={"+this.it+",'A'},"...
                +"IH={"+this.ih+",'A'},"...
                +"Roff_gmin="+this.roffGmin+","...
                +"ROFF={"+this.roff+",'Ohm'},"...
                +"RON={"+this.ron+",'Ohm'},"...
                +"TD={"+this.td+",'s'});";
            end
            output.connections=this.getConnectionString;
            varname=lower(this.name);
            output.variables=varname+" = {0,'A'};";
            output.branches=varname+": * -> "+this.name+".p1.i;";
            output.equations=varname+" == "...
            +upper(this.controlSource)+".i;";
        end
    end
end