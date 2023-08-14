function stageOut=initializeDefaults(this,workflow,stageIn)

    if~isa(stageIn,'char')
        error('HDLReadStatistics:InvalidInputType','''stage'' is expected to be of type: ''char''.');
    end

    stageOut='';


    switch workflow

    case 'vivado'


        stageOut='Implementation';

        if~isempty(stageIn)
            if strcmpi(stageIn,'Synthesis')||strcmpi(stageIn,'Implementation')
                stageOut=stageIn;
            else
                warning('HDLReadStatistics:InvalidInputValue',['The only valid inputs to the ''stage'' option are: ''Synthesis'' or ''Implementation''. Defaulting to ''',stageOut,'''.']);
            end
        end


        if this.testMode
            tempTargetDir=fullfile('hdl_prj');
        else
            tempTargetDir=fullfile('hdl_prj','vivado_prj');
        end

        if~isempty(this.targetDir)
            if exist(this.targetDir,'dir')
                tempTargetDir=this.targetDir;
            else
                warning('HDLReadStatistics:InvalidTargetDir',['The specified target directory: ''',strrep(this.targetDir,'\','\\'),''' does not exist on the current path. Defaulting to ''',strrep(tempTargetDir,'\','\\'),'''.']);
            end
        end

        this.targetDir=tempTargetDir;


        this.MATFileName=[this.dutName,'_xilinxResults.mat'];


        if~isempty(this.synthTool)&&~contains(this.synthTool,'vivado','IgnoreCase',true)
            error('HDLReadStatistics:InvalidWorkflow','Only ''Xilinx Vivado'' synthesis tool is supported for ''Xilinx'' workflow.');
        end

        this.synthTool='Xilinx Vivado';

    case 'quartus'


        stageOut='PAR';

        if~isempty(stageIn)
            if strcmpi(stageIn,'Synthesis')||strcmpi(stageIn,'Map')||strcmpi(stageIn,'PAR')
                stageOut=stageIn;
            else
                warning('HDLReadStatistics:InvalidInputValue',['The only valid inputs to the ''stage'' option are: ''Synthesis'' or ''Map'' or''PAR''. Defaulting to ''',stageOut,'''.']);
            end
        end


        if this.testMode
            tempTargetDir=fullfile('hdl_prj');
        else
            tempTargetDir=fullfile('hdl_prj','quartus_prj');
        end

        if~isempty(this.targetDir)
            if exist(this.targetDir,'dir')
                tempTargetDir=this.targetDir;
            else
                warning('HDLReadStatistics:InvalidTargetDir',['The specified target directory: ''',strrep(this.targetDir,'\','\\'),''' does not exist on the current path. Defaulting to ''',strrep(tempTargetDir,'\','\\'),'''.']);
            end
        end

        this.targetDir=tempTargetDir;


        this.MATFileName=[this.dutName,'_alteraResults.mat'];


        if~isempty(this.synthTool)&&~contains(this.synthTool,'quartus','IgnoreCase',true)
            error('HDLReadStatistics:InvalidWorkflow','Only ''Altera QUARTUS II'' synthesis tool is supported for ''Altera'' workflow.');
        end

        if contains(this.synthTool,'pro','IgnoreCase',true)
            this.synthTool='Intel Quartus Pro';
        else
            this.synthTool='Altera QUARTUS II';
        end


    case 'libero'

        if isempty(this.mdlName)
            error('HDLReadStatistics:EmptyModelName','The property: ''ModelName'' cannot be empty for ''Libero'' workflow. Please enter a valid model name as a property-value pair.');
        end


        tempTargetDir=fullfile('hdl_prj_libero',[this.mdlName,'_',this.dutName]);

        if~isempty(this.targetDir)
            if exist(this.targetDir,'dir')
                tempTargetDir=this.targetDir;
            else
                warning('HDLReadStatistics:InvalidTargetDir',['The specified target directory: ''',strrep(this.targetDir,'\','\\'),''' does not exist on the path. Defaulting to ''',strrep(tempTargetDir,'\','\\'),'''.']);
            end
        end

        this.targetDir=tempTargetDir;


        this.MATFileName=[this.dutName,'_liberoResults.mat'];


        if~isempty(this.synthTool)&&~contains(this.synthTool,'libero','IgnoreCase',true)
            error('HDLReadStatistics:InvalidWorkflow','Only ''Libero'' synthesis tool is supported for ''Libero'' workflow.');
        end

        this.synthTool='Libero';
    end
end