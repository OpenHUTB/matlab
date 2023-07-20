function generateFILHDL(h)




    h.displayStatus('Generating code for FPGA-in-the-Loop ...');


    oldCodeGenMode=hdlcodegenmode;
    codeGenModeCleanup=onCleanup(@()hdlcodegenmode(oldCodeGenMode));

    oldPropSet=PersistentHDLPropSet;
    hprop=hdlcoderprops.HDLProps;
    hprop.updateINI;
    PersistentHDLPropSet(hprop);

    try
        hdlcodegenmode('filtercoder');
        hdlsetparameter('entity_conflict_postfix','_inst');
        hdlsetparameter('codegendir',h.FilHdlDir);
        hdlsetparameter('verbose',0);

        if isprop(h.mBuildInfo.BoardObj,'ConnectionOptions')...
            &&isfield(h.mBuildInfo.BoardObj.ConnectionOptions,'GenerateOnlyChIf')...
            &&h.mBuildInfo.BoardObj.ConnectionOptions.GenerateOnlyChIf
            fil=eda.internal.filhdl.mwfil_chiftop(h.mBuildInfo);
            fil.Partition.Name=h.mBuildInfo.FPGAProjectName;
            fil.Partition.Lang='VHDL';
            fil.HDLFileDir=h.FilHdlDir;
            eda.internal.workflow.makeDir(h.FilHdlDir);
            fil.gBuild;
            fil.gUnify;
            fil.propagateCodeGenProp;
            hdlsetparameter('verbose',1);
            fil.hdlCodeGen(hprop);

            hdlFiles=fil.HDLFiles;
            hdlFiles=removeDUTfiles(hdlFiles,h.mBuildInfo.SourceFiles.FilePath);

            if~isempty(h.mBuildInfo.BoardObj.ConnectionOptions.PostCodeGenerationFcn)
                genfiles=feval(h.mBuildInfo.BoardObj.ConnectionOptions.PostCodeGenerationFcn,h.mBuildInfo);
                hdlFiles=[hdlFiles,genfiles];
            end
            h.FilGenFiles.HdlFiles=hdlFiles;
        elseif isprop(h.mBuildInfo.BoardObj,'ConnectionOptions')...
            &&isfield(h.mBuildInfo.BoardObj.ConnectionOptions,'Communication_Channel')...
            &&strcmpi(h.mBuildInfo.BoardObj.ConnectionOptions.Communication_Channel,'MicrosemiSGMII')
            fil=eda.internal.filhdl.FILCore(h.mBuildInfo);

            fil.Partition.Name=h.mBuildInfo.FPGAProjectName;
            fil.Partition.Lang='VHDL';
            fil.Partition.Board=h.mBuildInfo.Board;
            fil.Partition.Device=h.mBuildInfo.BoardObj.Component(1);
            fil.Partition.Type='FIL';
            fil.Partition.SynthFreq=str2double(strrep(h.mBuildInfo.FPGASystemClockFrequency,'MHz',''));
            fil.Partition.BoardObj=h.mBuildInfo.BoardObj;
            fil.HDLFileDir=h.FilHdlDir;
            fil.gBuild;
            fil.gUnify;
            fil.propagateCodeGenProp;
            hdlsetparameter('verbose',1);
            fil.hdlCodeGen(hprop);
            hdlFiles=fil.HDLFiles;
            hdlFiles=removeDUTfiles(hdlFiles,h.mBuildInfo.SourceFiles.FilePath);

            if~isempty(h.mBuildInfo.BoardObj.ConnectionOptions.PostCodeGenerationFcn)
                genfiles=feval(h.mBuildInfo.BoardObj.ConnectionOptions.PostCodeGenerationFcn,h.mBuildInfo);
                hdlFiles=[hdlFiles,genfiles];
            end
            h.FilGenFiles.HdlFiles=hdlFiles;
        elseif isprop(h.mBuildInfo.BoardObj,'ConnectionOptions')...
            &&isfield(h.mBuildInfo.BoardObj.ConnectionOptions,'Communication_Channel')...
            &&strcmpi(h.mBuildInfo.BoardObj.ConnectionOptions.Communication_Channel,'PSEthernet')

            fil=eda.internal.filhdl.FILCoreAXI(h.mBuildInfo);
            fil.Partition.Name=h.mBuildInfo.FPGAProjectName;
            fil.Partition.Lang='VHDL';
            fil.HDLFileDir=h.FilHdlDir;
            eda.internal.workflow.makeDir(h.FilHdlDir);
            fil.gBuild;
            fil.gUnify;
            fil.propagateCodeGenProp;
            hdlsetparameter('verbose',1);
            fil.hdlCodeGen(hprop);

            tclFILCore=eda.internal.xilinx.packageFILCoreAXI(fil.HDLFileDir,fil.HDLFiles,h.mBuildInfo);


            tclFILTop=feval(h.mBuildInfo.BoardObj.ConnectionOptions.PostCodeGenerationFcn,h.mBuildInfo);
            h.FilGenFiles.HdlFiles=[tclFILCore,tclFILTop];
        else

            if isprop(h.mBuildInfo.BoardObj,'ConnectionOptions')...
                &&isfield(h.mBuildInfo.BoardObj.ConnectionOptions,'Communication_Channel')...
                &&strcmpi(h.mBuildInfo.BoardObj.ConnectionOptions.Communication_Channel,'Digilent JTAG')

                fil=eda.internal.filhdl.mwfil_xjtagtop(h.mBuildInfo);
                fil.Partition.Name=h.mBuildInfo.FPGAProjectName;
                fil.UniqueName=h.mBuildInfo.FPGAProjectName;
                fil.Partition.Lang='VHDL';
                fil.HDLFileDir=h.FilHdlDir;
                eda.internal.workflow.makeDir(h.FilHdlDir);
                fil.gBuild;
                fil.gUnify;
                fil.propagateCodeGenProp;
                hdlsetparameter('verbose',1);
                fil.hdlCodeGen(hprop);
                top=fil;
            else
                fil=eda.internal.filhdl.FILCore(h.mBuildInfo);

                fil.Partition.Name=h.mBuildInfo.FPGAProjectName;
                fil.Partition.Lang='VHDL';
                fil.Partition.Board=h.mBuildInfo.Board;
                fil.Partition.Device=h.mBuildInfo.BoardObj.Component(1);
                fil.Partition.Type='FIL';
                fil.Partition.SynthFreq=str2double(strrep(h.mBuildInfo.FPGASystemClockFrequency,'MHz',''));
                fil.Partition.BoardObj=h.mBuildInfo.BoardObj;
                fil.HDLFileDir=h.FilHdlDir;




                eda.internal.workflow.makeDir(h.FilHdlDir);
                fil.gCodeGen(hprop);
                top=fil.getParent;
            end

            fil.writeConstraintFile(h.mBuildInfo);
            fil.writeScriptFile;



            hdlFiles=top.HDLFiles;
            hdlFiles=removeDUTfiles(hdlFiles,h.mBuildInfo.SourceFiles.FilePath);
            h.FilGenFiles.HdlFiles=hdlFiles;

            switch(h.mBuildInfo.BoardFPGAVendor)
            case 'Altera'
                h.FilGenFiles.ConstraintsFiles={[h.mBuildInfo.FPGAProjectName,'.qsf'],[h.mBuildInfo.FPGAProjectName,'.sdc']};
                h.FilGenFiles.ConstraintsFileTypes={'QSF file','Constraints'};
            otherwise
                switch h.mBuildInfo.FPGATool
                case 'Xilinx Vivado'
                    extension='.xdc';
                otherwise
                    extension='.ucf';
                end
                h.FilGenFiles.ConstraintsFiles={[h.mBuildInfo.FPGAProjectName,extension]};
                h.FilGenFiles.ConstraintsFileTypes={'Constraints'};
            end
        end

    catch me
        PersistentHDLPropSet(oldPropSet);
        rethrow(me);
    end


    PersistentHDLPropSet(oldPropSet);


    function generatedFiles=removeDUTfiles(allFiles,DUTFiles)
        generatedFiles='';
        [~,fileName,ext]=cellfun(@(x)fileparts(x),DUTFiles,'UniformOutput',false);
        for i=1:length(fileName)
            fileName{i}=[fileName{i},ext{i}];
        end
        for i=1:length(allFiles)
            found=false;
            for j=1:length(fileName)
                if strcmpi(allFiles{i},fileName{j})
                    found=true;
                    break;
                end
            end
            if found==false
                generatedFiles{end+1}=allFiles{i};%#ok<AGROW>
            end
        end
