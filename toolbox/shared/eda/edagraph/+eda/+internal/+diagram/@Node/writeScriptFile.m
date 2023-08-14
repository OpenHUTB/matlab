
function writeScriptFile(this)





    rtlDir=regexprep(this.HDLFileDir,'^./','');
    simDir=fullfile(rtlDir,'sim');

    [simFileId,simFileName]=this.openFile2W(simDir,'SIM');

    this.SimScript=simFileName;

    fullpath=pwd;

    simCommand='vsim';

    if strcmpi(this.Partition.Lang,'VERILOG')
        compileCommand='vlog';
    else
        compileCommand='vcom';
    end

    fprintf(simFileId,'%s',['set SRCDIR ',strrep(fullfile(fullpath,rtlDir),'\','/'),char(10),...
    'set SIMDIR ',strrep(fullfile(fullpath,simDir),'\','/'),char(10),...
    'set COMPILE ',compileCommand,char(10),char(10),...
    'set SIM ',simCommand,char(10),char(10)]);

    fprintf(simFileId,'%s',['vlib ',strrep(fullfile('$SIMDIR','work'),'\','/'),char(10),...
    'vmap work ',strrep(fullfile('$SIMDIR','work'),'\','/'),char(10),char(10)]);







    dutFilterList={};
    for cn=this.ChildNode
        if(isa(cn{1},'eda.internal.component.DUT'))
            dutChild=cn{1};


            dutFilterList=[dutFilterList{:},...
            dutChild.HDLFiles(~strncmp(dutChild.InstName,dutChild.HDLFiles,length(dutChild.InstName)))];
        end
    end

    for ii=1:length(this.HDLFiles)
        if(~any(strcmp(this.HDLFiles{ii},dutFilterList)))
            fprintf(simFileId,'%s',['$COMPILE ',strrep(fullfile('$SRCDIR',this.HDLFiles{ii}),'\','/'),char(10)]);
        end
    end





    if simFileId>0
        fclose(simFileId);
    end

end































