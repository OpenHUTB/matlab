function actionBrowseCustomFile(taskobj)



    mdladvObj=taskobj.MAObj;


    hMAExplorer=mdladvObj.MAExplorer;
    if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
        currentDialog=hMAExplorer.getDialog;
        currentDialog.apply;
    end


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    customHDLFile=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles'));
    customHDLStr=customHDLFile.Value;


    if~isempty(customHDLStr)&&isempty(regexp(customHDLStr,';$','once'))
        customHDLStr=sprintf('%s;',customHDLStr);
    end



    defaultFileList={'*.vhd;*.vhdl;*.v;*.vlg;*.verilog','All HDL Files (*.vhd, *.vhdl, *.v, *.vlg, *.verilog)';...
    '*.ucf','UCF Files (*.ucf)';...
    '*.sdc','SDC Files (*.sdc)';...
    '*.tcl','Tcl Files (*.tcl)';...
    '*.*','All Files (*.*)'};

    vivadoFileList={'*.vhd;*.vhdl;*.v;*.vlg;*.verilog','All HDL Files (*.vhd, *.vhdl, *.v, *.vlg, *.verilog)';...
    '*.sdc;*.xdc','SDC/XDC Files (*.sdc, *.xdc)';...
    '*.tcl','Tcl Files (*.tcl)';...
    '*.*','All Files (*.*)'};

    validList=defaultFileList;

    hdsi=downstream.handle('Model',mdladvObj.getFullName);

    if~isempty(hdsi)&&strcmpi(hdsi.getToolName(),'Xilinx Vivado')
        validList=vivadoFileList;
    end


    [filename,filepath,filterindex]=uigetfile(...
    validList,...
    'Pick a file','MultiSelect','on');


    if filterindex~=0
        if~iscell(filename)
            filename={filename};
        end
        for ii=1:length(filename)
            customHDLStr=sprintf('%s%s;',customHDLStr,fullfile(filepath,filename{ii}));
        end
        customHDLFile.Value=customHDLStr;


        taskobj.reset;
    end


