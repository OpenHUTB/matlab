classdef String<serdes.internal.ibisami.ami.type.AmiType

...
...
...
...
...
...
...
...
...



    properties(Constant)
        Name="String";
        CType="char*";
        TemplateType="ami_string_type";
        Blank=hex2dec('20')
        Bang=hex2dec('21')
        DoubleQu=hex2dec('22')
        FirstChar=hex2dec('23')
        LastChar=hex2dec('7E')
        HT=hex2dec('09')
        LF=hex2dec('0A')
        OD=hex2dec('0D')
    end
    methods(Static)
        function ok=isOkAmiString(value)
            ok=false;
            if~isa(value,'char')&&~isa(value,'string')
                return;
            end
            if isa(value,'string')&&~isscalar(value)
                return
            end
            chars=char(value);
            lastCharIdx=length(chars);
            for idx=1:lastCharIdx
                ch=chars(idx);

                if ch==serdes.internal.ibisami.ami.type.String.DoubleQu&&...
                    idx~=1&&idx~=lastCharIdx
                    return
                end

                if ch>serdes.internal.ibisami.ami.type.String.LastChar
                    return
                end


                if ch<serdes.internal.ibisami.ami.type.String.FirstChar&&...
                    ch~=serdes.internal.ibisami.ami.type.String.Blank&&...
                    ch~=serdes.internal.ibisami.ami.type.String.Bang&&...
                    ch~=serdes.internal.ibisami.ami.type.String.HT&&...
                    ch~=serdes.internal.ibisami.ami.type.String.LF&&...
                    ch~=serdes.internal.ibisami.ami.type.String.OD&&...
                    ch~=serdes.internal.ibisami.ami.type.String.DoubleQu
                    return
                end
            end
            ok=true;
        end
    end

    methods
        function obj=String()

        end

        function verificationResult=verifyValueForType(type,value)
            verificationResult=false;
            if~type.verifyValue(value)
                return
            end
            if~type.isOkAmiString(value)
                return
            end
            verificationResult=true;
        end
        function isEqual=isEqual(type,value1,value2)
            isEqual=type.verifyValueForType(value1)&&...
            type.verifyValueForType(value2)&&...
            isequal(string(value1),string(value2));
        end
        function convertedValue=convertStringValueToType(~,value)
            convertedValue=string(value);
        end
        function amiValue=convertToAmiValue(type,value)
            amiValue=string(value);
            if~type.isOkAmiString(amiValue)
                warning(message('serdes:ibis:NotRecognized',string(value),'String'))
            end
            chValue=char(amiValue);
            if isempty(chValue)||'"'~=chValue(1:1)
                amiValue='"'+amiValue;
            end
            if isempty(chValue)||'"'~=chValue(end:end)
                amiValue=amiValue+'"';
            end
        end
    end
end

