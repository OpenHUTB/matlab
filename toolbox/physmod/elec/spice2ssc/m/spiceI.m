classdef spiceI<spiceBase













    properties
        value;
        ic;
        model;
    end

    properties(Constant,Access=private)
        id="I";
        idc=1;
        iexp=2;
        isin=3;
        ipwl=4;
        ipulse=5;
        isffm=6;
    end

    methods
        function this=spiceI(str)
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
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceI:error_InputStringsToSpiceI')));
                end
                str=spiceBase.parseSpiceUnitsIdx(str,4);
                strComponents=this.parseSpiceString(str);
                this.name=strComponents{1};
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceI:warning_CurrentSource')),this.name);
                end


                if length(strComponents)<3
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end


                if length(strComponents)<4
                    strComponents{4}="0";
                end


                this.connectingNodes=[strComponents{2},strComponents{3}];
                usedIndices=1:3;
                idx=zeros(1,this.isffm);
                idx_temp=spiceBase.findName(strComponents,"dc");
                if~isempty(idx_temp)
                    idx(this.idc)=idx_temp;
                end
                idx_temp=spiceBase.findName(strComponents,"exp");
                if~isempty(idx_temp)
                    idx(this.iexp)=idx_temp;
                end
                idx_temp=spiceBase.findName(strComponents,"sin");
                if~isempty(idx_temp)
                    idx(this.isin)=idx_temp;
                end
                idx_temp=spiceBase.findName(strComponents,"pwl");
                if~isempty(idx_temp)
                    idx(this.ipwl)=idx_temp;
                end
                idx_temp=spiceBase.findName(strComponents,"pulse");
                if~isempty(idx_temp)
                    idx(this.ipulse)=idx_temp;
                end
                idx_temp=spiceBase.findName(strComponents,"sffm");
                if~isempty(idx_temp)
                    idx(this.isffm)=idx_temp;
                end
                tag_index=find(idx~=0,1,'last');
                if isempty(tag_index)
                    tag_index=0;
                end
                if tag_index~=0
                    if any(cellfun(@length,strComponents(idx(tag_index):end))>1)
                        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',this.name,getString(message('physmod:ee:library:comments:spice2ssc:spiceI:error_TransientSpecificationMustOccurAfterAllnamevaluePairs')));
                    end
                    fnArgElements=strjoin(string(strComponents(idx(tag_index):end)));
                    [fnArgElements,exprBraces]=spiceBase.stripArguments(fnArgElements,"{","}");
                    exprBraces=regexprep(exprBraces,"\s(?=(\+|\-)\S)","");
                    fnArgElements=regexprep(fnArgElements,"\-\(","\(\-");
                    fnArgElements=regexprep(fnArgElements,"\+","");
                    fnArgElements=strsplit(fnArgElements,{'(',')',',',' '});
                    fnArgElements(fnArgElements=="")=[];
                    strComponents(idx(tag_index):end)=[];
                    brace_index=1;
                    for ii=1:length(fnArgElements)
                        if fnArgElements(ii)=="{}"
                            fnArgElements(ii)=exprBraces(brace_index);
                            brace_index=brace_index+1;
                        end
                        strComponents{end+1}=fnArgElements(ii);%#ok<AGROW>
                    end
                    fnArgElements(1)=[];
                end
                switch tag_index
                case this.idc
                    this.value="ee.sources.current_source(dc_current={-("...
                    +spiceBase.stripOuterBraces(fnArgElements(1))...
                    +"),'A'})";
                    usedIndices=[usedIndices,idx(tag_index),idx(tag_index)+1];
                case this.iexp
                    this.value="ee.additional.spice_sources.curr_exp(";
                    usedIndices=[usedIndices,idx(tag_index)+(0:min([6,length(fnArgElements)]))];
                    for ii=1:min([6,length(fnArgElements)])
                        switch ii
                        case 1
                            this.value=this.value...
                            +"I1={"+fnArgElements(ii)+",'A'}";
                        case 2
                            this.value=this.value...
                            +"I2={"+fnArgElements(ii)+",'A'}";
                        case 3
                            this.value=this.value...
                            +"TDR={"+fnArgElements(ii)+",'s'}";
                        case 4
                            this.value=this.value...
                            +"TR={"+fnArgElements(ii)+",'s'}";
                        case 5
                            this.value=this.value...
                            +"TDF={"+fnArgElements(ii)+",'s'}";
                        case 6
                            this.value=this.value...
                            +"TF={"+fnArgElements(ii)+",'s'}";
                        end
                        if ii<length(fnArgElements)&&ii<6
                            this.value=this.value+",";
                        end
                    end
                    this.value=this.value+")";
                case this.isin
                    this.value="ee.additional.spice_sources.curr_sin(";
                    usedIndices=[usedIndices,idx(tag_index)+(0:min([6,length(fnArgElements)]))];
                    for ii=1:min([6,length(fnArgElements)])
                        switch ii
                        case 1
                            this.value=this.value...
                            +"IO={"+fnArgElements(ii)+",'A'}";
                        case 2
                            this.value=this.value...
                            +"IA={"+fnArgElements(ii)+",'A'}";
                        case 3
                            this.value=this.value...
                            +"FREQ={"+fnArgElements(ii)+",'Hz'}";
                        case 4
                            this.value=this.value...
                            +"TD={"+fnArgElements(ii)+",'s'}";
                        case 5
                            this.value=this.value...
                            +"DF={"+fnArgElements(ii)+",'1/s'}";
                        case 6
                            this.unsupportedStrings(end+1)=this.name+": phase argument for sinusoidal source";
                        end
                        if ii<length(fnArgElements)&&ii<5
                            this.value=this.value+",";
                        end
                    end
                    this.value=this.value+")";
                case this.ipwl
                    this.value="ee.additional.spice_sources.curr_pwl(";
                    usedIndices=[usedIndices,idx(tag_index)+(0:length(fnArgElements))];
                    len=length(fnArgElements);
                    if mod(len,2)~=0
                        pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                    end
                    time_vect=strings(1,len/2);
                    sig_vect=strings(1,len/2);
                    for ii=1:len/2
                        time_vect(ii)=fnArgElements(2*ii-1);
                        sig_vect(ii)=fnArgElements(2*ii);
                    end
                    this.value=this.value...
                    +"TIMElist={["+strjoin(time_vect)...
                    +"],'s'},CURRlist={["+strjoin(sig_vect)...
                    +"],'A'})";
                case this.ipulse
                    this.value="ee.additional.spice_sources.curr_pulse(";
                    usedIndices=[usedIndices,idx(tag_index)+(0:min([7,length(fnArgElements)]))];
                    for ii=1:min([7,length(fnArgElements)])
                        switch ii
                        case 1
                            this.value=this.value...
                            +"I1={"+fnArgElements(ii)+",'A'}";
                        case 2
                            this.value=this.value...
                            +"I2={"+fnArgElements(ii)+",'A'}";
                        case 3
                            this.value=this.value...
                            +"TD={"+fnArgElements(ii)+",'s'}";
                        case 4
                            this.value=this.value...
                            +"TR={"+fnArgElements(ii)+",'s'}";
                        case 5
                            this.value=this.value...
                            +"TF={"+fnArgElements(ii)+",'s'}";
                        case 6
                            this.value=this.value...
                            +"PW={"+fnArgElements(ii)+",'s'}";
                        case 7
                            this.value=this.value...
                            +"PER={"+fnArgElements(ii)+",'s'}";
                        end
                        if ii<length(fnArgElements)&&ii<7
                            this.value=this.value+",";
                        end
                    end
                    this.value=this.value+")";
                case this.isffm
                    this.value="ee.additional.spice_sources.curr_sffm(";
                    usedIndices=[usedIndices,idx(tag_index)+(0:min([5,length(fnArgElements)]))];
                    for ii=1:min([5,length(fnArgElements)])
                        switch ii
                        case 1
                            this.value=this.value...
                            +"IO={"+fnArgElements(ii)+",'A'}";
                        case 2
                            this.value=this.value...
                            +"IA={"+fnArgElements(ii)+",'A'}";
                        case 3
                            this.value=this.value...
                            +"FC={"+fnArgElements(ii)+",'Hz'}";
                        case 4
                            this.value=this.value...
                            +"MI={"+fnArgElements(ii)+",'1'}";
                        case 5
                            this.value=this.value...
                            +"FS={"+fnArgElements(ii)+",'Hz'}";
                        end
                        if ii<length(fnArgElements)&&ii<5
                            this.value=this.value+",";
                        end
                    end
                    this.value=this.value+")";
                otherwise
                    if length(strComponents{4})>1
                        this.value="ee.sources.current_source(dc_current={-("...
                        +spiceBase.stripOuterBraces(strComponents{4}(2))...
                        +"),'A'})";
                    else
                        this.value="ee.sources.current_source(dc_current={-("...
                        +spiceBase.stripOuterBraces(strComponents{4})...
                        +"),'A'})";
                    end
                    usedIndices=[usedIndices,4];
                end

                i_unsupported=spiceBase.findName(strComponents,"stimulus");
                if~isempty(i_unsupported)
                    if length(strComponents{i_unsupported})>=2
                        if strComponents{i_unsupported}(2)~=""
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",strjoin(strComponents{i_unsupported})]);
                            usedIndices=[usedIndices,i_unsupported];
                        else
                            this.unsupportedStrings(end+1)=strjoin([this.name+":",strjoin(cellfun(@strjoin,strComponents(i_unsupported:i_unsupported+1)))]);
                            usedIndices=[usedIndices,i_unsupported,i_unsupported+1];
                        end
                    else
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",strjoin(strComponents{i_unsupported})]);
                        usedIndices=[usedIndices,i_unsupported];
                    end
                end
                i_unsupported=spiceBase.findName(strComponents,"ac");
                if~isempty(i_unsupported)
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",strjoin(cellfun(@strjoin,strComponents(i_unsupported:i_unsupported+1)))]);
                    usedIndices=[usedIndices,i_unsupported,i_unsupported+1];
                end
                unusedIndices=setdiff(1:length(strComponents),usedIndices);
                for ii=1:length(unusedIndices)
                    this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{unusedIndices(ii)}]);
                end
                this.connectingNodes(this.connectingNodes=="0")="*";
            end
        end

        function output=getSimscapeText(this,~)
            output.components=this.name+" = "+this.value+";";
            output.connections=this.getConnectionString;
        end
    end
end