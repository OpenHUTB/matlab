classdef spiceCCVS<spiceBase













    properties
        value;
        ic;
        model;
    end

    properties(Constant,Access=private)
        id="H";
    end

    methods
        function this=spiceCCVS(str)
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
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceCCVS:error_InputStringsToSpiceCCVS')));
                end
                str=spiceBase.parseSpiceUnitsIdx(str,4);
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceCCVS:warning_CurrentcontrolledVoltageSource')),this.name);
                end


                if length(strComponents)<4
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end


                tempString=strComponents{4}(1);
                if strcmpi(tempString,"LAPLACE")...
                    ||strcmpi(tempString,"FREQ")...
                    ||strcmpi(tempString,"CHEBYSHEV")
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",strjoin(cellfun(@strjoin,strComponents(4:end)))]);
                    this.connectingNodes=[strComponents{2},strComponents{3}];
                else
                    polyControlled=false;
                    tableControlled=false;
                    valControlled=false;
                    if strcmpi(tempString,"POLY")||strncmpi(tempString,"POLY(",5)
                        polyControlled=true;
                        pdex=4;
                    elseif strcmpi(tempString,"TABLE")
                        tableControlled=true;
                        pdex=4;
                    elseif strcmpi(tempString,"VALUE")
                        pdex=4;
                        valControlled=true;
                    elseif length(strComponents)>=5&&strcmpi(strComponents{5}(1),"TABLE")
                        tableControlled=true;
                        pdex=5;
                    end


                    this.connectingNodes=[strComponents{2},strComponents{3}];
                    usedIndices=1:3;

                    if valControlled

                        strComponents=this.parseSpiceString(str,'ignoreEqual',true);
                        this.value=spiceBase.stripOuterBraces(strComponents{pdex+1});
                        usedIndices=[usedIndices,pdex,pdex+1];
                    elseif polyControlled

                        exprGroups=spiceSubckt.findEnclosure(strComponents{pdex},'(',')');
                        usedIndices=[usedIndices,pdex];


                        if isempty(exprGroups)
                            if length(strComponents)>pdex
                                exprGroups=spiceSubckt.findEnclosure(strComponents{pdex+1},'(',')');
                                usedIndices=[usedIndices,pdex+1];
                                if~isempty(exprGroups)
                                    pdex=pdex+1;
                                end
                            end
                        end


                        if isempty(exprGroups)
                            numAmmeters=1;
                        else


                            if size(exprGroups,2)~=2
                                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                            end
                            numAmmeters=str2double(extractBetween(strComponents{pdex},exprGroups(1,1)+1,exprGroups(1,2)-1));
                            if isnan(numAmmeters)
                                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                            end
                        end
                        if length(strComponents)<pdex+numAmmeters+1
                            pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                        end
                        controlAmmeters=strings(1,numAmmeters);
                        for ii=1:numAmmeters
                            if length(strComponents{pdex+ii})>1
                                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                            end
                            controlAmmeters(ii)=strComponents{pdex+ii};
                            usedIndices=[usedIndices,pdex+ii];%#ok<AGROW>
                            if~strncmpi(controlAmmeters(ii),'v',1)
                                pm_error('physmod:ee:spice2ssc:UnexpectedComponentIdentifier','V',getString(message('physmod:ee:library:comments:spice2ssc:spiceCCVS:error_CurrentmeasuringVoltageSource')),controlAmmeters(ii));
                            end
                        end
                        coefficients=string.empty;
                        reachedEnd=true;
                        for kk=(pdex+ii+1):length(strComponents)
                            usedIndices=[usedIndices,kk];%#ok<AGROW>
                            if length(strComponents{kk})~=1
                                reachedEnd=false;
                                break;
                            else
                                coefficients(end+1)=strComponents{kk};%#ok<AGROW>
                            end
                        end
                        if~reachedEnd
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",strjoin(cellfun(@strjoin,strComponents(kk:end)))]);
                        end


                        if numAmmeters==1&&length(coefficients)==1
                            coefficients=[0,coefficients];
                        end

                        controlSignals=strings(1,numAmmeters);
                        for ii=1:numAmmeters
                            controlSignals(ii)="value("+upper(controlAmmeters(ii))+".i,'A')";
                        end
                        if coefficients(1)~="0"
                            this.value=coefficients(1);
                        else
                            this.value=string.empty;
                        end
                        idx=1;
                        currentPolyPower=0;
                        polyTerms=string.empty;
                        for ii=2:length(coefficients)
                            if idx>length(polyTerms)
                                currentPolyPower=currentPolyPower+1;
                                polyTerms=cellfun(@(x)strjoin(x,"*"),this.polyConstructor(controlSignals,currentPolyPower));
                                idx=1;
                            end
                            if coefficients(ii)~="0"
                                if isempty(this.value)
                                    this.value=coefficients(ii)+"*"+polyTerms{idx};
                                else
                                    this.value=this.value+"+"+coefficients(ii)...
                                    +"*"+polyTerms{idx};
                                end
                            end
                            idx=idx+1;
                        end
                    elseif tableControlled



                        strComponents=this.parseSpiceString(str,'ignoreEqual',true);
                        if pdex==4
                            if sum(cellfun(@length,strComponents))<pdex+2
                                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                            end
                            control=spiceBase.stripOuterBraces(strComponents{pdex+1}(1));
                            tableData=strjoin(string(strComponents(pdex+2:end))," ");
                        elseif pdex==5
                            if sum(cellfun(@length,strComponents))<pdex+1
                                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                            end
                            controlcomponent=strComponents{4};
                            if~strncmpi(controlcomponent,'v',1)
                                pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier','V',getString(message('physmod:ee:library:comments:spice2ssc:spiceCCVS:error_CurrentmeasuringVoltageSource')),controlcomponent);
                            end
                            usedIndices=[usedIndices,4];
                            control="value("+upper(controlcomponent)+".i,'A')";
                            tableData=strjoin(string(strComponents(pdex+1:end))," ");
                        else

                            pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                        end
                        [input,output]=this.extractTableData(tableData);

                        if length(input)~=length(output)
                            pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                        end
                        this.value="simscape.tablelookup(["+strjoin(input,",")...
                        +"],["+strjoin(output,",")+"],"...
                        +control+",interpolation=linear,extrapolation=nearest)";
                        usedIndices=[usedIndices,pdex:length(strComponents)];
                    else
                        controlcomponent=strComponents{4};
                        if~strncmpi(controlcomponent,'v',1)
                            pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier','V',getString(message('physmod:ee:library:comments:spice2ssc:spiceCCVS:error_CurrentmeasuringVoltageSource')),controlcomponent);
                        end
                        gain=spiceBase.stripOuterBraces(strComponents{5});
                        usedIndices=[usedIndices,4:5];
                        this.value="("+gain+")*value("+upper(controlcomponent)+".i,'A')";
                    end
                    unusedIndices=setdiff(1:length(strComponents),usedIndices);
                    for ii=1:length(unusedIndices)
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{unusedIndices(ii)}]);
                    end
                end
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
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
                output.equations="0 == "+this.value+";";
            end
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
        end
    end

    methods(Access=private)
        function c=polyConstructor(this,vnames,maxpower)
            if maxpower==0
                c=cell.empty(0,length(vnames));
            elseif maxpower==1
                c=cell(1,length(vnames));
                for ii=1:length(vnames)
                    c{ii}=vnames(ii);
                end
            else
                clower=this.polyConstructor(vnames,maxpower-1);
                c=cell.empty;
                for ii=1:length(clower)
                    idx=find(vnames==clower{ii}(end));
                    for jj=idx:length(vnames)
                        c{end+1}=[clower{ii},vnames(jj)];%#ok<AGROW>
                    end
                end
            end
        end
    end
end
