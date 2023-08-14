classdef ScriptInfo<handle






    properties(SetAccess=private)
        TempDirHandler;
        FunctionHandle;
    end

    properties(SetAccess=private)
        Filename=['approximateFunction_',datestr(now,'yyyymmddTHHMMSSFFF')]
    end

    properties(SetAccess=private)
        CodeString;
        Counter=FunctionApproximation.internal.utilities.Counter();
    end

    methods
        function this=ScriptInfo()

            this.Counter.getNext();
            this.Filename=[this.Filename,num2str(this.Counter.Count)];

            this.TempDirHandler=FunctionApproximation.internal.TempDirectoryHandler();
            this.TempDirHandler.createDirectoryOnPath();
        end

        function update(this,data)

            if strcmp(char(data.InterpolationMethod),'previous')
                data.InterpolationMethod='flat';
            elseif contains(char(data.InterpolationMethod),'Linear')
                data.InterpolationMethod='linear';
            end

            tableData=struct('BreakpointValues',{data.Data(1:end-1)},...
            'BreakpointDataTypes',data.StorageTypes(1:end-1),...
            'TableValues',data.Data{end},...
            'TableDataType',data.StorageTypes(end),...
            'IsEvenSpacing',data.Spacing,...
            'Interpolation',FunctionApproximation.InterpolationMethod(data.InterpolationMethod));

            generator=FunctionApproximation.internal.LUTVectorizedScriptGenerator(tableData,data.InputTypes,data.OutputType,data.Spacing);
            this.CodeString=generator.getMATLABScript();
            stringToLoadMatFile=FunctionApproximation.internal.getStringToLoadMatFile(tableData.TableValues,this.Filename);
            currDir=pwd;

            cd(this.TempDirHandler.TempDir);
            this.CodeString=strrep(this.CodeString,'#FILENAME',this.Filename);
            this.CodeString=strrep(this.CodeString,'#LOAD_MAT_FILE',stringToLoadMatFile);

            FunctionApproximation.internal.Utils.convertStringToFile(this.CodeString,this.Filename);
            this.FunctionHandle=str2func(this.Filename);








            if numel(tableData.TableValues)>=1000
                FunctionApproximation.internal.generateMatFile(tableData,data.InputTypes,this.Filename);
            end
            cd(currDir);
        end

        function setCodeString(this,codeString)
            this.CodeString=codeString;
        end

        function show(this)
            open(fullfile(this.TempDirHandler.TempDir,this.Filename));
        end
    end
end


