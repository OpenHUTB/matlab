function writeSynthesisFile(this,SynthesisTool)


    if(nargin<2)

        SynthesisTool=this.HdlSynthTool;
    end


    topname=this.TopLevelName;
    fname=fullfile(this.CodeGenDirectory,[topname,this.SynthesisFilePostFix]);
    fid=fopen(fname,'w');
    if fid==-1
        error(message('HDLShared:hdlshared:synthopenfile'));
    end

    numSubModels=numel(this.SubModelData);
    if strcmpi(SynthesisTool,'libero')
        initStr=this.HdlSynthInit;
        for ii=1:numSubModels

            initStr=strrep(initStr,'import_files',...
            sprintf([this.HdlSynthLibCmd,'\\nimport_files'],this.SubModelData(1).LibName));
        end
        fprintf(fid,initStr,topname,this.TargetLanguage);
    else
        fprintf(fid,this.HdlSynthInit,topname);
    end

    for ii=1:numSubModels
        smd=this.SubModelData(ii);
        subMdlName=smd.ModelName;
        fnames=fullfile(subMdlName,smd.FileNames);
        createSynthLib(this,fid,smd.LibName,SynthesisTool);
        if strcmp(this.TargetLanguage,'VHDL')
            if strcmpi(SynthesisTool,'libero')
                synthCmd=this.HdlSynthCmd;
            else
                if strcmpi(SynthesisTool,'vivado')
                    synthCmd=[this.HdlSynthCmd...
                    ,sprintf(regexprep(this.HdlSynthLibSpec,'\\n',''),smd.LibName),' %s\n'];
                else
                    synthCmd=regexprep(this.HdlSynthCmd,'\\n',...
                    sprintf([' ',this.HdlSynthLibSpec,'\\\\n'],smd.LibName));
                end
            end
        else
            synthCmd=this.HdlSynthCmd;
        end
        for jj=1:numel(fnames)
            addFileToSynthScript(this,fid,fnames{jj},synthCmd,SynthesisTool,true);
        end
    end

    hdlnames=this.entityFileNames;
    for n=1:length(hdlnames)
        addFileToSynthScript(this,fid,hdlnames{n},this.HdlSynthCmd,SynthesisTool);
    end

    if strcmpi(SynthesisTool,'libero')
        for ii=1:numSubModels
            smd=this.SubModelData(ii);
            libName=smd.LibName;
            fileNames=fullfile(smd.ModelName,smd.FileNames);
            for jj=1:numel(fileNames)
                fprintf(fid,['\n',this.HdlSynthLibSpec],libName,fileNames{jj});
            end
        end
        fprintf(fid,'\n');
    end


    insertDSPBASynthesisScripts(this,fid);
    insertXSGSynthesisScripts(this,fid);
    fprintf(fid,this.HdlSynthTerm);
    fclose(fid);
end


function addFileToSynthScript(this,fid,fname,synthCmd,SynthesisTool,library)

    fname=regexprep(fname,'\','/');

    if nargin<6
        library=false;
    end

    switch lower(SynthesisTool)
    case 'quartus'
        fprintf(fid,synthCmd,upper(this.TargetLanguage),fname);
    case 'vivado'
        if library==true
            fprintf(fid,synthCmd,fname,['[get_files -regex "',fullfile('.*',fname),'"]']);
        else
            fprintf(fid,synthCmd,fname);
        end
    otherwise
        fprintf(fid,synthCmd,fname);
    end
end

function createSynthLib(this,fid,libName,SynthesisTool)
    switch lower(SynthesisTool)
    case 'quartus'
        fprintf(fid,[this.HdlSynthLibCmd,'\n'],libName);
    case 'ise'
        fprintf(fid,[this.HdlSynthLibCmd,'\n'],libName);
    case 'synplify'
        fprintf(fid,[this.HdlSynthLibCmd,'\n'],libName);
    otherwise


    end
end


