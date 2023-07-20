function[newBlockPath]=addSLBlockSubsystem(this,hC,originalBlkPath,targetBlkPath)


    newBlockPath=addSLBlock(this,hC,'built-in/Subsystem',targetBlkPath,true,true);

    exceptionList=['ReferenceBlock','SourceLibraryInfo'];
    setModelParam(this,originalBlkPath,newBlockPath,exceptionList);

    [turnhilitingon,color]=this.getHiliteInfo(hC);
    if~isempty(color)
        set_param(newBlockPath,'BackgroundColor',color);
        if turnhilitingon
            this.hiliteBlkAncestors(newBlockPath,color);
        end
    end

    for ii=1:length(hC.PirInputPorts)
        inportPath{ii}=[newBlockPath,'/In',num2str(ii)];%#ok
        add_block('built-in/Inport',inportPath{ii});
        set_param(inportPath{ii},'Position',[85,78+((ii-1)*20),115,92+((ii-1)*20)]);
    end

    for ii=1:length(hC.PirOutputPorts)
        outportPath{ii}=[newBlockPath,'/Out',num2str(ii)];%#ok
        add_block('built-in/Outport',outportPath{ii});
        set_param(outportPath{ii},'Position',[395,88+((ii-1)*20),425,102+((ii-1)*20)]);
    end
