







classdef StringHighlighting<handle

    methods(Access=public)
        function obj=StringHighlighting(originalValue,splitNonMatch,hitsubstrings)
            utils.ScopedInstrumentation("stringHighlighting::constructing");
            obj.originalvalue=originalValue;
            obj.splitNonMatch=splitNonMatch;
            obj.hitsubstrings=hitsubstrings;
            obj.replacesubstrings={};
            len=numel(hitsubstrings);
            obj.substringsReplaced=cell(1,len);
            for i=1:len
                obj.substringsReplaced{i}=false;
            end
        end

        function copyFrom(this,srcHighlighting)
            this.originalvalue=srcHighlighting.originalvalue;
            this.splitNonMatch=srcHighlighting.splitNonMatch;
            this.hitsubstrings=srcHighlighting.hitsubstrings;
            this.replacesubstrings=srcHighlighting.replacesubstrings;
            this.substringsReplaced=srcHighlighting.substringsReplaced;
        end

        function replaceAllFrom(this,srcHighlighting)
            this.originalvalue=srcHighlighting.getReplacePreview();
            this.splitNonMatch=this.originalvalue;
            this.splitNonMatch=srcHighlighting.splitNonMatch;
            this.hitsubstrings=srcHighlighting.hitsubstrings;
            this.replacesubstrings=srcHighlighting.replacesubstrings;
            substringsReplaced=srcHighlighting.substringsReplaced;
            len=numel(substringsReplaced);
            this.substringsReplaced=cell(1,len);
            for i=1:len
                this.substringsReplaced{i}=true;
            end
        end

        function clear(this)
            this.splitNonMatch={};
            this.hitsubstrings={};
            this.replacesubstrings={};
            this.substringsReplaced={};
        end

        function empty=isEmpty(this)
            empty=isempty(this.hitsubstrings);
        end




        function setReplaceWithBitArray(this,srcHighlighting,bitArray)
            if isempty(bitArray)
                this.copyFrom(srcHighlighting);
                return;
            end
            this.getCopyAfterBitArrayProcess(srcHighlighting,bitArray,true);
        end




        function setAfterReplacedByBitArray(this,srcHighlighting,bitArray)




            import simulink.search.internal.model.StringHighlighting;
            this.originalvalue=this.getReplacedStringByBitArray(...
            bitArray,...
            this.splitNonMatch...
            );
            this.getCopyAfterBitArrayProcess(srcHighlighting,bitArray,false);
        end

        function swapOriginalAndReplace(this)
            if isempty(this.hitsubstrings)
                return;
            end

            this.originalvalue=this.getReplacePreview();



            lenPos=numel(this.hitsubstrings);


            import simulink.search.internal.model.StringHighlighting;
            bitArrayPos=1;
            for srcPos=1:lenPos
                if this.substringsReplaced{srcPos}
                    continue;
                end


                tmp=this.hitsubstrings{srcPos};
                this.hitsubstrings{srcPos}=this.replacesubstrings{srcPos};
                this.replacesubstrings{srcPos}=tmp;
            end
        end

        function updateSearchRegx(this,searchRegx,regxFunc)

            [this.splitNonMatch,this.hitsubstrings]=regexp(...
            char(this.originalvalue),...
            searchRegx,...
            'split',...
            'match',...
regxFunc...
            );
        end

        function updateReplaceRegx(this,searchRegx,replaceRegx)
            len=numel(this.hitsubstrings);
            oldReplaceSubstrings=this.replacesubstrings;
            this.replacesubstrings=cell(1,len);
            for i=1:len
                if this.substringsReplaced{i}
                    this.replacesubstrings{i}=oldReplaceSubstrings{i};
                    continue;
                end
                this.replacesubstrings{i}=regexprep(...
                this.hitsubstrings{i},...
                searchRegx,...
                replaceRegx,...
'ignorecase'...
                );
            end
        end


        function replaceStr=getReplacePreview(this)
            import simulink.search.internal.model.StringHighlighting;
            replaceStr=this.getReplacedStringByBitArray(...
            [],...
            this.splitNonMatch...
            );
        end

        function updateByDeltaReplaced(...
            this,...
deltaHighlight...
            )
            if isempty(this.hitsubstrings)
                return;
            end



            lenPos=numel(this.hitsubstrings);


            deltaSubstrReplaced=deltaHighlight.substringsReplaced;
            for srcPos=1:lenPos
                if~deltaSubstrReplaced{srcPos}

                    this.substringsReplaced{srcPos}=false;
                    tmp=this.hitsubstrings{srcPos};
                    this.hitsubstrings{srcPos}=this.replacesubstrings{srcPos};
                    this.replacesubstrings{srcPos}=tmp;
                    this.substringsReplaced{srcPos}=false;
                end
            end
            this.originalvalue=deltaHighlight.getReplacePreview();
        end
    end

    methods(Static,Access=public)
        function checked=getHighlightChecked(highlightNumber,bitArray)
            if isempty(bitArray)
                checked=true;
                return;
            end


            realByte=bitshift(highlightNumber-1,-3);
            realBit=(highlightNumber-1)-realByte*8;
            byteValue=bitArray(realByte+1);
            checked=(bitand(byteValue,bitshift(1,realBit))>0);
        end
    end

    methods(Access=protected)


        function replacedStr=getReplacedStringByBitArray(...
            this,...
            bitArray,...
splitNonMatch...
            )
            if isempty(this.hitsubstrings)
                replacedStr=splitNonMatch;
                return;
            end



            lenPos=numel(this.hitsubstrings);
            subStrTotalLength=numel(splitNonMatch{1});
            for i=1:lenPos
                subStrTotalLength=subStrTotalLength...
                +max(numel(this.hitsubstrings{i}),numel(this.replacesubstrings{i}))...
                +numel(splitNonMatch{i+1});
            end
            replacedStr=blanks(subStrTotalLength);


            import simulink.search.internal.model.StringHighlighting;
            tarPos=1;
            bitArrayPos=1;
            for srcPos=1:lenPos
                endPos=tarPos+numel(splitNonMatch{srcPos});
                replacedStr(tarPos:endPos-1)=splitNonMatch{srcPos};
                tarPos=endPos;

                if this.substringsReplaced{srcPos}
                    checked=false;
                else
                    checked=StringHighlighting.getHighlightChecked(bitArrayPos,bitArray);
                    bitArrayPos=bitArrayPos+1;
                end
                if~checked

                    endPos=tarPos+numel(this.hitsubstrings{srcPos});
                    replacedStr(tarPos:endPos-1)=this.hitsubstrings{srcPos};
                    tarPos=endPos;
                    continue;
                end


                endPos=tarPos+numel(this.replacesubstrings{srcPos});
                replacedStr(tarPos:endPos-1)=this.replacesubstrings{srcPos};
                tarPos=endPos;
            end
            endPos=tarPos+numel(splitNonMatch{lenPos+1});
            replacedStr(tarPos:endPos-1)=splitNonMatch{lenPos+1};
            tarPos=endPos;


            replacedStr(tarPos:subStrTotalLength)=[];
        end

        function updateByBitArray(...
            this,...
            bitArray,...
convertToDeltaUpdate...
            )
            if isempty(this.hitsubstrings)
                return;
            end



            lenPos=numel(this.hitsubstrings);


            import simulink.search.internal.model.StringHighlighting;
            bitArrayPos=1;
            for srcPos=1:lenPos
                if this.substringsReplaced{srcPos}
                    checked=false;
                else
                    checked=StringHighlighting.getHighlightChecked(bitArrayPos,bitArray);
                    bitArrayPos=bitArrayPos+1;
                end
                if~checked

                    if convertToDeltaUpdate

                        this.substringsReplaced{srcPos}=true;
                    end
                    continue;
                end

                if~convertToDeltaUpdate

                    this.substringsReplaced{srcPos}=false;
                    tmp=this.hitsubstrings{srcPos};
                    this.hitsubstrings{srcPos}=this.replacesubstrings{srcPos};
                    this.replacesubstrings{srcPos}=tmp;
                    this.substringsReplaced{srcPos}=true;
                end
            end
        end

        function getCopyAfterBitArrayProcess(this,...
            srcHighlighting,...
            bitArray,...
convertToDeltaUpdate...
            )
            this.copyFrom(srcHighlighting);

            this.updateByBitArray(bitArray,convertToDeltaUpdate);
        end
    end

    properties(Access=public)
        originalvalue;


        splitNonMatch;



        hitsubstrings;
        replacesubstrings;

        substringsReplaced;
    end
end
