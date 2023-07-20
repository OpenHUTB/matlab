function hdlCodeGen(this,config)


    if nargin<2
        config='';
    end

    oldPropSet=PersistentHDLPropSet;
    oldCodeGen=hdlcodegenmode;
    hdlcodegenmode('filtercoder');
    try
        if isempty(config)
            hprop=hdlcoderprops.HDLProps;
            hprop.updateINI;
        else
            hprop=config;
        end
        PersistentHDLPropSet(hprop);
        hdlsetparameter('entity_conflict_postfix','_inst');

        currentTable=hdlgetsignaltable;


        this.gClear('generatedHDLCode');


        generateTop(this);

        this.hdlCodeCleanUp('HDLFile');

        if~isempty(currentTable)&&isa(currentTable,'hdlshared.HDLEntitySignalTable')
            hdlsetsignaltable(currentTable);
        end
    catch ME

        PersistentHDLPropSet(oldPropSet);
        rethrow(ME);
        hdlcodegenmode(oldCodeGen);
    end

    hdlcodegenmode(oldCodeGen);
    PersistentHDLPropSet(oldPropSet);

end


function generateTop(this)


    oldLang=hdlgetparameter('target_language');
    hdlsetparameter('target_language',this.Partition.Lang);
    this.HDLFileDir=hdlGetCodegendir(true);
    oldEntityList=hdlgetparameter('entitynamelist');
    hdlsetparameter('entitynamelist',{});

    this.HDLFiles={};

    device=getDevice(this);
    this.HDL=device.hdlcodeinit;

    if isa(this,'eda.internal.component.WhiteBox')

        this.initSignalTable;
        this.entityDecl;
        this.hdlsignalDecl;

        decldList={};
        recursiveCodeGen(this,decldList);
        signalAssign(this);
    elseif isa(this,'eda.internal.component.BlackBox')
        this.entityDecl;
        this.copyDesignFiles;
    end

    this.HDL=hdlcodeconcat([this.HDL,this.inithdlcodeinit]);
    this.HDLFiles{end+1}=[this.UniqueName,fileExtension];

    this.hdlCodeCleanUp('HDLLib');

    this.writeHDLFile;


    hdlsetparameter('target_language',oldLang);
    hdlsetparameter('entitynamelist',oldEntityList);
end




function decldList=recursiveCodeGen(Obj,decldList)
    comps=Obj.ChildNode;
    if isempty(comps)
        Obj.hdlsignalDecl;
        hdlcode=Obj.componentBody;
        if~isempty(hdlcode)
            Obj.HDL=hdlcodeconcat([Obj.HDL,hdlcode]);
        else
            hdlcode=Obj.DescFunc;
            Obj.HDL=hdlcodeconcat([Obj.HDL,hdlcode]);
        end
        signalAssign(Obj);
    else
        for i=1:length(comps)
            comp=comps{i};
            if isa(comp,'eda.internal.component.WhiteBox')
                if comp.flatten
                    comp.hdlsignalDecl;
                    decldList=recursiveCodeGen(comp,decldList);
                    signalAssign(comp);
                    Obj.HDL=hdlcodeconcat([Obj.HDL,comp.HDL]);
                    for j=1:length(comp.HDLFiles)
                        Obj.HDLFiles{end+1}=comp.HDLFiles{j};
                    end
                else
                    if~codeReUse(comp)||~isempty(comp.findprop('forceCodeRegenerate'))

                        currentTable=hdlgetsignaltable;
                        generateTop(comp);

                        if~isempty(currentTable)&&isa(currentTable,'hdlshared.HDLEntitySignalTable')
                            hdlsetsignaltable(currentTable);
                        end
                    end
                    [notDecld,decldList]=needToBeDecld(decldList,comp);
                    if notDecld||~isempty(comp.findprop('forceCodeRegenerate'))
                        compDecl=comp.componentDecl;
                    end
                    sigDecl=comp.hdlsignalDecl;
                    compInst=comp.componentInst;
                    if notDecld||~isempty(comp.findprop('forceCodeRegenerate'))
                        Obj.HDL=hdlcodeconcat([Obj.HDL,compDecl,sigDecl,compInst]);
                    else
                        Obj.HDL=hdlcodeconcat([Obj.HDL,sigDecl,compInst]);
                    end
                    for j=1:length(comp.HDLFiles)
                        Obj.HDLFiles{end+1}=comp.HDLFiles{j};
                    end
                end
            elseif isa(comp,'eda.internal.component.BlackBox')
                if~isempty(comp.findprop('wrapperFileNeeded'))
                    if~codeReUse(comp)
                        generateTop(comp);
                    end
                elseif~isempty(comp.HDLFiles)&&~isempty(comp.findprop('CopyHDLFiles'))
                    comp.copyDesignFiles;
                elseif isempty(comp.findprop('NoHDLFiles'))
                    warning(message('EDALink:Node:hdlCodeGen:legacyhdlfile'));
                end

                [notDecld,decldList]=needToBeDecld(decldList,comp);

                compDecl=comp.componentDecl(notDecld);

                compInst=comp.componentInst;

                Obj.HDL=hdlcodeconcat([Obj.HDL,compDecl,compInst]);

                for j=1:length(comp.HDLFiles)
                    Obj.HDLFiles{end+1}=comp.HDLFiles{j};
                end


                if~isempty(comp.findprop('PostCodeGenFcn'))
                    genFiles=feval(comp.PostCodeGenFcn,comp.PostCodeGenFcnArgs{:});
                    pause(3);
                    for ii=1:numel(genFiles)
                        copyfile(genFiles{ii},Obj.HDLFileDir);
                        [~,genFileName,genFileExt]=fileparts(genFiles{ii});
                        Obj.HDLFiles=[comp.HDLFiles,[genFileName,genFileExt]];
                    end
                end
            end
        end
    end

end



function signalAssign(Obj)
    signals=Obj.ChildEdge;
    for ii=1:length(signals)
        sig=Obj.ChildEdge{ii};
        hdlcode=sig.componentBody(Obj);
        Obj.HDL=hdlcodeconcat([Obj.HDL,hdlcode]);
    end
end


function str=fileExtension

    str=hdlgetparameter('filename_suffix');

end


function status=codeReUse(this)
    status=true;
    if~isempty(this.findprop('enableCodeGen'))
        status=false;
    end
end

function[status,NewList]=needToBeDecld(decldList,comp)
    status=true;
    for i=1:length(decldList)
        if isa(comp,'eda.internal.component.BlackBox')
            if strcmp(comp.UniqueName,decldList{i}.UniqueName)
                status=false;
                break;
            end
        elseif strcmpi(class(comp),class(decldList{i}))
            status=false;
            break;
        end
    end
    if status
        decldList{end+1}=comp;
    end

    NewList=decldList;

end

function device=getDevice(this)
    if isfield(this.Partition,'Device')
        if~isempty(this.Partition.Device)
            device=eda.fpga.(this.Partition.Device.PartInfo.FPGAVendor);
        else
            device=this;
        end
    else
        device=this;
    end
end
