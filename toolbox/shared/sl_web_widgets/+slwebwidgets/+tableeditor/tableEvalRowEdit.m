function[outVal,wasError]=tableEvalRowEdit(inVal,varargin)





    outVal=inVal;
    wasError=false;
    try

        try


            [capturedText,outVal]=evalin('base',"evalc('"+inVal+"')");

            if isa(outVal,'Simulink.Parameter')
                outVal=outVal.Value;
            end
        catch

            try

                [capturedText,outVal]=evalin('base',"evalc("""+inVal+""")");
            catch
                if~isempty(varargin)
                    try
                        capturedText='';
                        outVal=slwebwidgets.tableeditor.evalinSimulink(varargin{1},inVal);
                    catch
                    end
                end
            end
        end


        isNumber=isnumeric(outVal);
        isCharArray=ischar(outVal);
        isStringScalarVal=isStringScalar(outVal);
        isEnumVal=isenum(outVal);
        isALogical=islogical(outVal);


        isAnyValid=isNumber||isCharArray||isStringScalarVal||isEnumVal||isALogical;



        if~isempty(capturedText)||~isAnyValid
            outVal=inVal;
            wasError=true;
            return;
        end


        if~isscalar(outVal)&&~ischar(outVal)
            outVal=inVal;
            wasError=true;
            return;
        end



        if isenum(outVal)
            outVal=char(outVal);
            return;
        end


        if isnan(outVal)||isinf(outVal)||~isreal(outVal)
            outVal=num2str(outVal);
        end
    catch


        wasError=true;
    end
