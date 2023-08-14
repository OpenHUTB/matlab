classdef FigureInteractionData<handle







    properties
        iCode cell={};
        iClearCode logical=false;
        iShowCode logical=false;
        isFakeCode logical=false;
        iAtomicActionID string="";
        ilegendTextPosition double;
        iLegendEntryString string;
        iLegendEntryIndex uint32;
        editedAnnotationType string="";
        editedAnnotationText string="";
        editedAnnotationPosition double;
        iRegisterAction logical=false;
    end

    methods
        function setCode(this,code)
            this.iClearCode=false;
            this.iCode=code;
            this.iCode=cellstr(string(code));
        end

        function showCode(this)
            this.iShowCode=true;
        end

        function setFakeCode(this,state)
            this.isFakeCode=state;
        end

        function setAtomicActionID(this,atomicActionID)
            this.iAtomicActionID=atomicActionID;
        end

        function clearCode(this)
            this.iClearCode=true;
        end

        function setLegendEntryIndex(this,iLegendEntryIndex)
            this.iLegendEntryIndex=iLegendEntryIndex;
        end

        function setLegendEntryString(this,iLegendEntryString)
            this.iLegendEntryString=iLegendEntryString;
        end

        function setLegendTextPosition(this,ilegendTextPosition)
            this.ilegendTextPosition=ilegendTextPosition;
        end

        function setEditedAnnotationType(this,editedAnnotationType)
            this.editedAnnotationType=editedAnnotationType;
        end

        function setEditedAnnotationText(this,editedAnnotationText)
            this.editedAnnotationText=editedAnnotationText;
        end

        function setEditedAnnotationPosition(this,editedAnnotationPosition)
            this.editedAnnotationPosition=editedAnnotationPosition;
        end
    end
end
