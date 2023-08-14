function onAddFile(this,dlg)



    this.Status='';

    switch(this.BuildInfo.BoardObj.Component.PartInfo.FPGAVendor)
    case{'Xilinx','Microsemi'}
        filterspec={
        '*.vhd;*.vhdl;*.v;*.verilog',[this.getCatalogMsgStr('HdlFiles_Dialog'),' (*.vhd,*.vhdl,*.v,*.verilog)'];...
        '*.edf;*.edif;*.edn;*.ngc;*.ngo',[this.getCatalogMsgStr('Netlists_Dialog'),' (*.edf,*.edif,*.edn,*.ngc,*.ngo)'];...
        '*.ucf',[this.getCatalogMsgStr('ConstraintFiles_Dialog'),' (*.ucf)'];...
        '*.xdc',[this.getCatalogMsgStr('ConstraintFiles_Dialog'),' (*.xdc)'];...
        '*.tcl',[this.getCatalogMsgStr('TclScripts_Dialog'),' (*.tcl)'];...
        '*.*',[this.getCatalogMsgStr('AllFiles_Dialog'),' (*.*)']};
    otherwise
        filterspec={
        '*.vhd;*.vhdl;*.v;*.verilog',[this.getCatalogMsgStr('HdlFiles_Dialog'),' (*.vhd,*.vhdl,*.v,*.verilog)'];...
        '*.edf;*.edif;*.edn;*.vqm',[this.getCatalogMsgStr('Netlists_Dialog'),' (*.edf,*.edif,*.edn,*.vqm)'];...
        '*.sdc',[this.getCatalogMsgStr('ConstraintFiles_Dialog'),' (*.sdc)'];...
        '*.qsf',[this.getCatalogMsgStr('QsfFiles_Dialog'),' (*.qsf)'];...
        '*.*',[this.getCatalogMsgStr('AllFiles_Dialog'),' (*.*)']};
    end


    onCleanupObj=this.disableWidgets(dlg);

    [filename,pathname,index]=uigetfile(filterspec,...
    this.getCatalogMsgStr('BrowseFileTitle_Dialog'),...
    this.PrevBrowsePath,...
    'MultiSelect','on');

    delete(onCleanupObj);


    if(index)
        this.PrevBrowsePath=pathname;
        if(~iscell(filename))
            filename={filename};
        end

        newfilename=cell(1,numel(filename));
        n=0;
        for m=1:numel(filename)
            fullFileName=fullfile(pathname,filename{m});
            r=strcmpi(fullFileName,this.BuildInfo.SourceFiles.FilePath);
            if(isempty(find(r,1,'first')))
                newfilename{n+1}=filename{m};
                n=n+1;
            else
                this.Status=[this.Status,sprintf('File ''%s'' already exists in file list.\n',fullFileName)];
            end
        end
        if(n<m)
            newfilename(n+1:m)=[];
        end

        FPGAVendor=this.BuildInfo.BoardObj.Component.PartInfo.FPGAVendor;
        for m=1:numel(newfilename)
            fullFileName=fullfile(pathname,newfilename{m});
            if(this.ShowFullFilePath)
                dispFileName=fullFileName;
            else
                dispFileName=newfilename{m};
            end

            filetypeint=l_getFileType(newfilename{m},FPGAVendor);
            filetypeenum=this.BuildInfo.FileTypeEnum;
            filetypestr=filetypeenum{filetypeint+1};
            this.BuildInfo.addSourceFile(fullFileName,filetypestr,{});
            this.addNewFile(dispFileName,filetypeint,filetypeenum);

        end

        dlg.refresh;



        if this.IsInHDLWA
            taskObj=Advisor.Utils.convertMCOS(dlg.getSource);
            hdlwa.setOptionsCallBack(taskObj);
            dlg.enableApplyButton(true);
        end
    end

end



function type=l_getFileType(filename,fpgavendor)

    [~,~,ext]=fileparts(filename);
    ext=lower(ext);
    switch(fpgavendor)
    case{'Xilinx','Microsemi'}
        switch(ext)
        case '.vhd'
            type=0;
        case '.v'
            type=1;
        case{'.edif','.edf','.ngc'}
            type=2;
        case '.tcl'
            type=3;
        case '.ucf'
            type=4;
        otherwise
            type=5;
        end
    otherwise
        switch(ext)
        case '.vhd'
            type=0;
        case '.v'
            type=1;
        case{'.edif','.edf'}
            type=2;
        case '.vqm'
            type=3;
        case '.hex'
            type=4;
        case '.qsf'
            type=5;
        case '.tcl'
            type=6;
        case '.sdc'
            type=7;
        otherwise
            type=8;
        end
    end
end


