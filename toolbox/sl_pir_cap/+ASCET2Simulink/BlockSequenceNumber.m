


classdef BlockSequenceNumber<handle


    properties
        block=[]
    end
    methods
        function this=BlockSequenceNumber(block)
            this.block=block;
        end
        function thisSequenceNumber=getValue(this)
            thisBlockTag=ASCET2Simulink.BlockTag(this.block,'sequenceNumber');
            thisSequenceNumber=thisBlockTag.getValue();
        end
        function result=compare(this,another)
            result=0;
            thisBlockTag=ASCET2Simulink.BlockTag(this.block,'sequenceNumber');
            thisSequenceNumber=thisBlockTag.getValue();
            anotherBlockTag=ASCET2Simulink.BlockTag(another.block,'sequenceNumber');
            anotherSequenceNumber=anotherBlockTag.getValue();
            thisSequenceNumberElements=regexp(thisSequenceNumber,':','split');
            anotherSequenceNumberElements=regexp(anotherSequenceNumber,':','split');
            if~isempty(thisSequenceNumberElements)&&...
                ~isempty(anotherSequenceNumberElements)
                if length(thisSequenceNumberElements)<length(anotherSequenceNumberElements)
                    for index=1:length(thisSequenceNumberElements)
                        thisSequenceNumberElement=str2num(thisSequenceNumberElements{index});%#ok<ST2NM>
                        anotherSequenceNumberElement=str2num(anotherSequenceNumberElements{index});%#ok<ST2NM>
                        if thisSequenceNumberElement<anotherSequenceNumberElement
                            result=-1;
                            return;
                        elseif thisSequenceNumberElement>anotherSequenceNumberElement
                            result=1;
                            return;
                        end
                    end
                    if anotherSequenceNumber(length(thisSequenceNumber)+1)>0
                        result=-1;
                    elseif anotherSequenceNumber(length(thisSequenceNumber)+1)<0
                        result=1;
                    end
                elseif length(thisSequenceNumberElements)>length(anotherSequenceNumberElements)
                    for index=1:length(anotherSequenceNumberElements)
                        thisSequenceNumberElement=str2num(thisSequenceNumberElements{index});%#ok<ST2NM>
                        anotherSequenceNumberElement=str2num(anotherSequenceNumberElements{index});%#ok<ST2NM>
                        if thisSequenceNumberElement<anotherSequenceNumberElement
                            result=-1;
                            return;
                        elseif thisSequenceNumberElement>anotherSequenceNumberElement
                            result=1;
                            return;
                        end
                    end
                    if thisSequenceNumber(length(anotherSequenceNumber)+1)>0
                        result=1;
                    elseif thisSequenceNumber(length(anotherSequenceNumber)+1)<0
                        result=-1;
                    end
                else
                    for index=1:length(thisSequenceNumberElements)
                        thisSequenceNumberElement=str2num(thisSequenceNumberElements{index});%#ok<ST2NM>
                        anotherSequenceNumberElement=str2num(anotherSequenceNumberElements{index});%#ok<ST2NM>
                        if thisSequenceNumberElement<anotherSequenceNumberElement
                            result=-1;
                            return;
                        elseif thisSequenceNumberElement>anotherSequenceNumberElement
                            result=1;
                            return;
                        end
                    end
                    result=0;
                end
            else
                e=MException('ASCET2Simulink:BlockPriority:compare','invalid block path');
                e.throw;
            end
        end
    end

end
