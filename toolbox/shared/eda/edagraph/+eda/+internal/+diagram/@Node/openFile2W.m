function[fileId,fileName]=openFile2W(this,dir,type,Name)







    if nargin<3
        Name='';
    end

    MakeCodegendir(dir);
    if strcmpi(type,'HDL')
        mode='w';
        fileName=[this.UniqueName,fileExtension];
    elseif strcmpi(type,'SIM')
        mode='w';
        fileName=[this.Name,'.do'];
        if exist(['./script/',fileName],'file')==2
            delete(['./script/',fileName]);
        end
    elseif strcmpi(type,'SYNTH')
        mode='w';
        fileName=[Name,'.ucf'];
    end

    filename=fullfile(dir,fileName);

    fileId=fopen(filename,mode);
    if fileId==-1
        error(message('EDALink:Node:openFile2W:fileerror',filename));
    end

    s=['Generating ',type,' file for: ',hdlgetfilelink(filename)];
    if hdlgetparameter('verbose')==1
        hdldisp(s,1);
    end

end


function MakeCodegendir(dirName)


    codegendir=dirName;

    [s,~,messid]=mkdir(codegendir);
    if s==0
        switch lower(messid)
        case 'matlab:mkdir:directoryexists',
        otherwise
            error(message('EDALink:Node:openFile2W:directoryfailure',codegendir));
        end
    end

end


function str=fileExtension
    if strcmpi(hdlgetparameter('target_lang'),'verilog')
        str=hdlgetparameter('verilog_file_ext');
    else
        str=hdlgetparameter('vhdl_file_ext');
    end

end

