


classdef ReplaceData<handle
    methods(Static,Access=public)
        function replaceData=createFromRegx(...
            propertyName,propertyValue,searchRegx,regxFunc,startId...
            )
            utils.ScopedInstrumentation("replaceData::createFromRegx");

            originalValue=char(propertyValue);
            [splitNonMatch,hitsubstrings]=regexp(...
            originalValue,...
            searchRegx,...
            'split',...
            'match',...
regxFunc...
            );

            if isempty(hitsubstrings)
                replaceData=[];
                return;
            end
            import simulink.search.internal.model.ReplaceData;
            replaceData=ReplaceData(startId,propertyName,originalValue,splitNonMatch,hitsubstrings);
        end
    end
    methods(Access=public)
        function obj=ReplaceData(currentId,propertyName,propertyValue,splitNonMatch,hitsubstrings)
            obj.id=currentId;
            obj.propertyname=propertyName;
            obj.m_realPropertyName='';
            obj.isReadOnly=false;


            import simulink.search.internal.model.StringHighlighting;
            obj.highlighting=StringHighlighting(propertyValue,splitNonMatch,hitsubstrings);
        end




        function empty=isEmpty(this)
            empty=this.highlighting.isEmpty();
        end








        function setReplaceWithBitArray(this,srcReplaceData,bitArray)



            this.propertyname=lower(srcReplaceData.propertyname);
            this.id=srcReplaceData.id;
            this.m_realPropertyName=srcReplaceData.m_realPropertyName;
            this.highlighting.setReplaceWithBitArray(srcReplaceData.highlighting,bitArray);
        end




        function setAfterReplacedByBitArray(this,srcReplaceData,bitArray)



            this.propertyname=lower(srcReplaceData.propertyname);
            this.id=srcReplaceData.id;
            this.m_realPropertyName=srcReplaceData.m_realPropertyName;
            this.highlighting.setAfterReplacedByBitArray(srcReplaceData.highlighting,bitArray);
        end



        function swapOriginalAndReplace(this)
            this.highlighting.swapOriginalAndReplace();
        end

        function updateSearchRegx(this,searchRegx,regxFunc)
            this.highlighting.updateSearchRegx(searchRegx,regxFunc);
        end

        function updateReplaceRegx(this,searchRegx,replaceRegx)
            this.highlighting.updateReplaceRegx(searchRegx,replaceRegx);
        end


        function replaceStr=getReplacePreview(this)
            replaceStr=this.highlighting.getReplacePreview();
        end

        function setRealPropertyName(this,nameStr)
            this.m_realPropertyName=nameStr;
        end

        function realName=getRealPropertyName(this)
            realName=this.m_realPropertyName;
        end
    end

    properties(Access=protected)
        m_realPropertyName;
    end

    properties(Access=public)



        propertyname;
        id;
        highlighting;
        isReadOnly;
        readOnlyMessage;
    end

end
