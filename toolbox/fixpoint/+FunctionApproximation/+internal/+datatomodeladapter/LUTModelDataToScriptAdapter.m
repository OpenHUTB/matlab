classdef LUTModelDataToScriptAdapter<FunctionApproximation.internal.datatomodeladapter.DataToScript






    properties
        InterpMethod;
        LUTData;
        BreakpointValues;
        InputType;
        OutputType;
        TableValuesType;
        BreakpointType;
        Spacing;
    end

    methods
        function this=LUTModelDataToScriptAdapter(data)
            interpMethodString=FunctionApproximation.internal.getLUTInterpMethodString(data.InterpolationMethod);
            if strcmp(interpMethodString,'linear point-slope')
                this.InterpMethod=FunctionApproximation.InterpolationMethod.Linear;
            else
                this.InterpMethod=FunctionApproximation.InterpolationMethod(interpMethodString);
            end
            this.InputType=data.InputTypes;
            this.OutputType=data.OutputType;
            this.TableValuesType=data.StorageTypes(end);
            this.BreakpointType=data.StorageTypes(1:end-1);
            this.Spacing=data.Spacing;
            this.LUTData=data.Data{end};
            this.BreakpointValues=data.Data{1:end-1};
        end

        function scriptInfo=getScriptInfo(this,data)
            scriptInfo=FunctionApproximation.internal.datatomodeladapter.ScriptInfo();
            codeString=getCodeString(this);
            codeString=strrep(codeString,'#FILENAME',scriptInfo.Filename);
            scriptInfo.setCodeString(codeString);
            scriptInfo.update(data);
        end

        function codeString=getCodeString(this)

            tableData=struct('BreakpointValues',{{this.BreakpointValues}},...
            'BreakpointDataTypes',this.BreakpointType,...
            'TableValues',this.LUTData,...
            'TableDataType',this.TableValuesType,...
            'IsEvenSpacing',isEvenSpacing(this.Spacing),...
            'Interpolation',this.InterpMethod);


            generator=FunctionApproximation.internal.LUTVectorizedScriptGenerator(tableData,this.InputType,this.OutputType,this.Spacing);
            codeString=generator.getMATLABScript();

            [headerString,probDefString]=getCommentstoAddString(this);
            codeString=strrep(codeString,'#HEADER_COMMENT',headerString);
            codeString=strrep(codeString,'#PROBLEM_DEFINITION_COMMENT',[probDefString{:},'%']);
        end

        function[headerString,probDefString]=getCommentstoAddString(~)

            headerString='';
            probDefString={''};
        end

    end
end

