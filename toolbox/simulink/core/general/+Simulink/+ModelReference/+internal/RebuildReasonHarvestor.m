classdef RebuildReasonHarvestor<handle




    properties(GetAccess=public,SetAccess=private)
PathToSearch
OutputFile
Verbose
DataTable
ProcessedRecords
VariableNames
    end

    methods(Access=public)
        function this=RebuildReasonHarvestor(varargin)
            this.resetProperties();
            this.parseInputs(varargin{:});
        end



        function harvest(this)
            this.dispInfo('Simulink:slbuild:rrhSearchStart',this.PathToSearch);
            binfoFiles=dir(fullfile(this.PathToSearch,'**','binfo_mdlref.mat'));

            this.dispInfo('Simulink:slbuild:rrhHarvestStart',numel(binfoFiles));
            this.DataTable=table('Size',[numel(binfoFiles),4],...
            'VariableTypes',{'string','string','datetime','string'},...
            'VariableNames',this.VariableNames);
            arrayfun(@(x)this.processBinfoFile(x),binfoFiles);



            if~isequal(numel(binfoFiles),this.ProcessedRecords)
                this.DataTable=this.DataTable(1:this.ProcessedRecords,:);
            end

            this.writeTable();
            this.dispInfo('Simulink:slbuild:rrhDone');
        end

        function result=getTable(this)
            result=this.DataTable;
        end
    end

    methods(Access=private)
        function resetProperties(this)
            this.PathToSearch=pwd;
            this.OutputFile='';
            this.Verbose=true;
            this.DataTable=[];
            this.ProcessedRecords=0;
            this.VariableNames={DAStudio.message('Simulink:slbuild:rrhModel'),...
            DAStudio.message('Simulink:slbuild:rrhTarget'),...
            DAStudio.message('Simulink:slbuild:rrhDate'),...
            DAStudio.message('Simulink:slbuild:rrhReason')};
        end

        function parseInputs(this,varargin)
            p=inputParser();
            p.addParameter('PathToSearch',pwd,@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('OutputFile','',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('Verbose',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));

            p.parse(varargin{:});
            this.PathToSearch=p.Results.PathToSearch;
            this.OutputFile=p.Results.OutputFile;
            this.Verbose=p.Results.Verbose;
        end

        function processBinfoFile(this,binfoFile)
            fileName=fullfile(binfoFile.folder,binfoFile.name);
            try
                fileContents=load(fileName);
                binfo=fileContents.infoStruct;
                targetType=this.getTargetType(binfo.matFileName);
                this.storeReasons(binfo.modelName,binfo.rebuildReason,targetType);
            catch ME
                warning(ME.identifier,'%s',ME.message);
            end
        end

        function storeReasons(this,model,reasonStruct,targetType)
            index=this.ProcessedRecords+1;
            this.DataTable{index,this.VariableNames{1}}=string(model);
            this.DataTable{index,this.VariableNames{2}}=string(targetType);
            if isempty(reasonStruct)
                this.DataTable{index,this.VariableNames{4}}=...
                string(DAStudio.message('Simulink:slbuild:rrhNoReason'));
            else
                this.DataTable{index,this.VariableNames{3}}=reasonStruct.date;
                this.DataTable{index,this.VariableNames{4}}=string(reasonStruct.reason);
            end
            this.ProcessedRecords=index;
        end

        function result=getTargetType(~,binfoFileName)
            if contains(binfoFileName,fullfile('slprj','sim'))
                result=DAStudio.message('Simulink:slbuild:rrhSimulation');
            else
                result=DAStudio.message('Simulink:slbuild:rrhCodeGen');
            end
        end

        function dispInfo(this,msgID,varargin)
            sl('sl_disp_info',DAStudio.message(msgID,varargin{:}),...
            this.Verbose);
        end

        function writeTable(this)
            if isempty(this.OutputFile)||this.ProcessedRecords==0
                return;
            end
            this.dispInfo('Simulink:slbuild:rrhWritingFile',this.OutputFile);
            writetable(this.DataTable,this.OutputFile,...
            'Encoding','UTF-8','Delimiter','|','DateLocale','system');
        end
    end
end


