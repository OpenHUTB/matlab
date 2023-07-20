classdef spiceBehavioral<spiceBase








    properties
        value;
        ic;
        model;
    end

    properties(Access=private)
        type;
    end

    properties(Constant,Access=private)
        id="B";
    end

    methods
        function this=spiceBehavioral(str,varargin)
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
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceBehavioral:error_InputStringsToSpiceBehavioral')));
                end
                str=spiceBase.parseSpiceUnitsIdx(str,4);
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceBehavioral:warning_BehavioralSource')),this.name);
                end


                idxv=spiceBase.findNameEquals(strComponents,'v');
                idxi=spiceBase.findNameEquals(strComponents,'i');
                if(isempty(idxv)&&isempty(idxi))...
                    ||(~isempty(idxv)&&~isempty(idxi))
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end
                if isempty(idxv)
                    this.type='i';
                    this.value=spiceBase.stripOuterBraces(strComponents{idxi}(2));
                    for ii=(idxi+1):length(strComponents)
                        if length(strComponents{ii})==1
                            this.value=this.value+spiceBase.stripOuterBraces(strComponents{ii});
                            idxi=[idxi,ii];%#ok<AGROW>
                        else
                            break;
                        end
                    end
                else
                    this.type='v';
                    this.value=spiceBase.stripOuterBraces(strComponents{idxv}(2));
                    for ii=(idxv+1):length(strComponents)
                        if length(strComponents{ii})==1
                            this.value=this.value+spiceBase.stripOuterBraces(strComponents{ii});
                            idxv=[idxv,ii];%#ok<AGROW>
                        else
                            break;
                        end
                    end
                end


                parameterLocations=setdiff(4:length(strComponents),[idxv,idxi]);
                if~isempty(parameterLocations)
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",strjoin(cellfun(@strjoin,strComponents(parameterLocations)))]);
                end


                this.connectingNodes=[strComponents{2},strComponents{3}];
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            output.variables=this.name+" = {value={"...
            +0+",'A'},priority=priority.none};";
            output.branches=this.name+": ";
            if this.connectingNodes(1)~="*"
                output.branches=output.branches+this.connectingNodes(1)+".i -> ";
            else
                output.branches=output.branches+this.connectingNodes(1)+" -> ";
            end
            if this.connectingNodes(2)~="*"
                output.branches=output.branches+this.connectingNodes(2)+".i;";
            else
                output.branches=output.branches+this.connectingNodes(2)+";";
            end
            if strcmpi(this.type,'v')
                if this.connectingNodes(1)~="*"&&this.connectingNodes(2)~="*"
                    output.equations="value("+this.connectingNodes(1)+".v"...
                    +"-"+this.connectingNodes(2)+".v"+",'V') == "...
                    +this.value+";";
                elseif this.connectingNodes(1)~="*"&&this.connectingNodes(2)=="*"
                    output.equations="value("+this.connectingNodes(1)+".v"...
                    +",'V') == "...
                    +this.value+";";
                elseif this.connectingNodes(1)=="*"&&this.connectingNodes(2)~="*"
                    output.equations="value(-"+this.connectingNodes(2)+".v"+",'V') == "...
                    +this.value+";";
                else
                    output.equations="0 == "...
                    +this.value+";";
                end
            else
                output.equations="value("+this.name+",'A') == "+this.value+";";
            end
        end
    end
end
