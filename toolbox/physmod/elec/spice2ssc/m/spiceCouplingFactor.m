classdef spiceCouplingFactor<handle








    properties
        name=string.empty;
        unsupportedStrings=string.empty;
    end

    properties(Access=public)
        k=NaN;
        inductors=string.empty;
    end

    properties(Constant,Access=private)
        id="K";
    end

    methods
        function this=spiceCouplingFactor(str,varargin)
            if nargin>=1
                str=string(str);
                if length(str)>1
                    pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:spice2ssc:spiceCouplingFactor:error_InputStringsToSpiceCouplingFactor')));
                end
                strComponents=spiceBase.parseSpiceString(str);
                this.name=strComponents{1};
                usedIndices=1;
                if~strncmpi(this.name,this.id,1)
                    pm_warning('physmod:ee:spice2ssc:UnexpectedComponentIdentifier',this.id,getString(message('physmod:ee:library:comments:spice2ssc:spiceCouplingFactor:warning_CouplingFactor')),this.name);
                end


                if length(strComponents)<4
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                end


                ldex=cellfun(@(x)(strncmpi(x,"L",1)),strComponents,'UniformOutput',false);
                if ldex{2}
                    value_idx=find(~[ldex{2:end}],1)+1;
                    usedIndices=[usedIndices,2:value_idx];
                    strComponents=spiceBase.parseSpiceUnitsCell(strComponents,value_idx);
                    this.k=spiceBase.stripOuterBraces(strComponents{value_idx}(end));
                    this.inductors=[strComponents{2:value_idx-1}];
                    unusedIndices=setdiff(1:length(strComponents),usedIndices);
                    for ii=1:length(unusedIndices)
                        this.unsupportedStrings(end+1)=strjoin([this.name+":",strComponents{unusedIndices(ii)}]);
                    end
                else
                    this.unsupportedStrings(end+1)=str;
                end
            end
        end

        function addCouplingToInductors(this,elements)
            if~isempty(this.inductors)
                inductorCombinations=nchoosek(this.inductors,2);
                elementNames=cellfun(@(x)(x.name),elements);
                for ii=1:size(inductorCombinations,1)
                    idx1=find(strcmpi(elementNames,inductorCombinations(ii,1)),1);
                    idx2=find(strcmpi(elementNames,inductorCombinations(ii,2)),1);
                    if isempty(idx1)||isempty(idx2)
                        pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.name);
                    end
                    elements{idx1}.addCoupling(elements{idx2},this.k);
                    elements{idx2}.addCoupling(elements{idx1},this.k);
                end
            end
        end
    end
end