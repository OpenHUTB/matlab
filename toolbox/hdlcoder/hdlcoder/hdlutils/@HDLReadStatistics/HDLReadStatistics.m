classdef HDLReadStatistics<handle











































































































































































































































































































































































































    properties

summary
    end

    properties(Hidden=true)

loadFromMAT
    end

    properties(Access=private)

mdlName
dutName


MATFileName


synthTool


targetDir


readTiming
readResources
testMode
    end

    methods




        function this=HDLReadStatistics(dutName,varargin)

            if mod(length(varargin),2)~=0||nargin<1
                error('HDLReadStatistics:InvalidInputArgsCount','Invalid number of input arguments.');
            end

            if~isa(dutName,'char')
                error('HDLReadStatistics:InvalidDUTName','DUT name has to be of the type ''char''.');
            end


            this.resetVariables;


            this.dutName=dutName;


            this.assignPVConstructor(true,varargin);
        end





        function resetVariables(this)

            this.synthTool='';
            this.targetDir='';

            this.mdlName='';
            this.MATFileName='';

            this.readTiming=true;
            this.readResources=true;
            this.testMode=false;

            this.loadFromMAT=false;

            this.summary.Xilinx=[];
            this.summary.Altera=[];
            this.summary.Libero=[];
        end





        function useCustom(this,varargin)


            this.assignPVConstructor(false,varargin);
        end





        function[resultsTable,metadata]=readResults(this,stage,verboseMode,varargin)


            if((nargin>3)&&(mod(length(varargin),2)~=0))||nargin<1
                error('HDLReadStatistics:InvalidInputArgsCount','Invalid number of input arguments.');
            end



            if nargin<3
                verboseMode=true;
            end


            if nargin<2
                stage='';
            end


            this.readTiming=true;
            this.readResources=true;
            this.testMode=false;


            this.assignPVReadFunc(varargin);

            if~islogical(verboseMode)
                error('HDLReadStatistics:InvalidInputType','''verboseMode'' flag is expected to be of type: ''logical''.');
            end

            if isempty(this.synthTool)
                error('HDLReadStatistics:InvalidInputValue','The property: ''SynthTool'' cannot be empty. Please specify a valid ''SynthTool''.');

            elseif contains(this.synthTool,'vivado','IgnoreCase',true)


                stage=this.initializeDefaults('vivado',stage);


                currentDir=pwd;
                restoreCleanup=onCleanup(@()cd(currentDir));


                cd(this.targetDir);


                [resultsTable,metadata]=readVivadoResults(this,stage,verboseMode);

            elseif contains(this.synthTool,'quartus','IgnoreCase',true)


                stage=this.initializeDefaults('quartus',stage);


                currentDir=pwd;
                restoreCleanup=onCleanup(@()cd(currentDir));


                cd(this.targetDir);


                if contains(this.synthTool,'pro','IgnoreCase',true)
                    [resultsTable,metadata]=readQuartusProResults(this,stage,verboseMode);
                else
                    [resultsTable,metadata]=readQuartusResults(this,stage,verboseMode);
                end


            elseif contains(this.synthTool,'libero','IgnoreCase',true)


                this.initializeDefaults('libero',stage);


                currentDir=pwd;
                restoreCleanup=onCleanup(@()cd(currentDir));


                cd(this.targetDir);


                [resultsTable,metadata]=readLiberoResults(this,verboseMode);

            else
                error('HDLReadStatistics:InvalidInputValue',['Invalid synthesis tool ''',this.synthTool,''' specified. The valid inputs are: ''Xilinx Vivado'', ''Altera QUARTUS'' and ''Libero''.']);
            end
        end
    end

end