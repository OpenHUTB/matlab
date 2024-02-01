classdef Utils

    methods(Static=true)
        function out=encodeModuleName(in)
            out=encode_decode_macro_name_mex(0,in);
        end


        function out=decodeModuleName(in)
            out=encode_decode_macro_name_mex(1,in);
        end


        function out=formatBytesAsString(bytes,maxItems)
            if nargin<2
                maxItems=16;
            end
            out=format_bytes_as_string_mex(bytes,uint8(maxItems));
        end


        function out=convertOnOffToBool(val)
            if numel(val)==1&&(islogical(val)||(isnumeric(val)&&numel(val)==1&&(val==1||val==0)))
                out=logical(val);
            elseif ischar(val)
                validatestring(lower(val),{'on','off'});
                out=logical(strcmpi(val,'on'));
            else
                error(message('CodeInstrumentation:utils:notOnOffValue'));
            end
        end


        function out=convertBoolToOnOff(val)
            if numel(val)==1&&(islogical(val)||(isnumeric(val)&&numel(val)==1&&(val==1||val==0)))
                if val
                    out='on';
                else
                    out='off';
                end
            elseif ischar(val)
                validatestring(lower(val),{'on','off'});
                out=lower(val);
            else
                error(message('CodeInstrumentation:utils:notOnOffValue'));
            end
        end


        function out=checkStringValue(val)
            if ischar(val)
                out=val;
            else
                validateattributes(val,{'char'},{'row'});
            end
        end


        function out=checkCellStringValue(val)
            if iscellstr(val)
                out=val;
            else
                validateattributes(val,{'cell'},{'vector'});
            end
        end


        function out=checkFloatValue(val)
            validateattributes(val,{'single','double'},{'scalar'});
            out=val;
        end


        function out=checkClassValue(val,cls)
            validateattributes(val,{cls},{});
            out=val;
        end
    end

end


