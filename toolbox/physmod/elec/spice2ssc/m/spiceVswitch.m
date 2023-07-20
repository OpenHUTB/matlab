classdef spiceVswitch<spiceBase







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
        von=1;
        voff=0;
        vt=0;
        vh=0;
        td=0;
        roffGmin=ee.enum.switches.offResistance.no;
    end

    properties(Constant,Access=private)
        id="S";
    end

    methods
        function this=spiceVswitch(str,varargin)
            this.nodes=["p2","n2","p1","n1"];
            if nargin<1

                this.name=string.empty;
                this.connectingNodes=string.empty;
                this.value=[];
                this.ic=[];
                this.model=string.empty;
            else
                str=string(str);
                if length(str)>1
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceVswitch:error_InputStringsToSpiceVswitch')));
                end
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceVswitch:warning_VoltagecontrolledSwitch')),this.name);
                end


                if length(strComponents)<6
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end



                this.connectingNodes=[strComponents{2},strComponents{3},strComponents{4},strComponents{5}];
                this.model=strComponents{6};
                if length(strComponents)>6
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",cellfun(@string,strComponents{7:end})]);
                end
                if nargin<2
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",this.model]);
                elseif nargin>=2
                    if nargin>2
                        pm_warning('physmod:ee:spice2ssc:IgnoringExtras',getString(message('physmod:ee:library:comments:spice2ssc:spiceVswitch:warning_Arguments')),this.name);
                    end
                    models=varargin{1};
                    modelFound=false;
                    for ii=1:length(models)
                        modelStruct=spiceBase.parseModelDefinition(models(ii));
                        if strcmpi(modelStruct.name,this.model)...
                            &&(strcmpi(modelStruct.type,"sw")...
                            ||strcmpi(modelStruct.type,"vswitch"))
                            modelFound=true;

                            resModel=false;
                            transModel=false;
                            if any(strcmpi(modelStruct.parameterNames,'von'))...
                                ||any(strcmpi(modelStruct.parameterNames,'voff'))

                                resModel=true;
                            end
                            if any(strcmpi(modelStruct.parameterNames,'vt'))

                                transModel=true;
                            end
                            if resModel&&transModel

                                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceVswitch:error_MixingOfParameters')));
                            elseif~resModel&&~transModel
                                if strcmpi(modelStruct.type,"sw")
                                    transModel=true;
                                elseif strcmpi(modelStruct.type,"vswitch")
                                    resModel=true;
                                end
                            end
                            if resModel

                                this.switchModel=ee.enum.switches.switchModelVoltage.resistance;
                            elseif transModel

                                this.switchModel=ee.enum.switches.switchModelVoltage.transition;
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

                this.switchModel=ee.enum.switches.switchModelVoltage.transition;

            end
            if this.switchModel==ee.enum.switches.switchModelVoltage.resistance
                if~isstring(this.roff)
                    if isnan(this.roff)
                        this.roff=1e6;
                    end
                end
                output.components=this.name...
                +" = ee.additional.spice_passives.vswitch("...
                +"SWITCH_model="+this.switchModel+","...
                +"VOFF={"+this.voff+",'V'},"...
                +"VON={"+this.von+",'V'},"...
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
                +" = ee.additional.spice_passives.vswitch("...
                +"SWITCH_model="+this.switchModel+","...
                +"VT={"+this.vt+",'V'},"...
                +"VH={"+this.vh+",'V'},"...
                +"Roff_gmin="+this.roffGmin+","...
                +"ROFF={"+this.roff+",'Ohm'},"...
                +"RON={"+this.ron+",'Ohm'},"...
                +"TD={"+this.td+",'s'});";
            end
            output.connections=this.getConnectionString;
        end
    end
end